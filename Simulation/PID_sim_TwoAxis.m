%{
TVR-1: Two-axis TVC PID control loop simulation
Simulates both pitch and yaw during the G61W burn (0 to 2.04s), using
moment-of-inertia data pulled from the OpenRocket sim, and checks
whether a chosen set of PID gains can correct an initial disturbance
on both axes at once before the motor burns out.

This is the two-axis follow-up to pid_sim.m (the single-axis version).
Every line below marked "% ***" is either an update or addition from that
file, everything else (thrust model, torque model, gains, timestep)
carried over unchanged since the one-axis run already checked out
(final tilt -0.027 deg, matched the Python cross-check).
%}

clear; clc; close all;

% Load moment-of-inertia data (burn phase only)
BURNOUT_TIME = 2.04;  % seconds, from OpenRocket event log

fid = fopen('Moment_of_Intertia_TVR-1_data.csv', 'r');
longitudinal_I = [];
while true
    line = fgetl(fid);
    if ~ischar(line)
        break
    end
    line = strtrim(line);
    if isempty(line) || startsWith(line, '#')
        if contains(line, 'BURNOUT')
            break
        end
        continue
    end
    parts = strsplit(line, ',');
    longitudinal_I(end+1) = str2double(parts{1});
end
fclose(fid);

i_sample_times = linspace(0, BURNOUT_TIME, length(longitudinal_I));

%{
***: same "Longitudinal moment of inertia" column is used for both the
pitch axis and the yaw axis. OpenRocket's "Longitudinal" MOI is about
an axis perpendicular to the rocket's long axis (ex. it's already the
pitch/yaw MOI, not roll). Since the airframe is round and axisymmetric
about its long axis, pitch and yaw see the same moment of inertia, so
one column correctly feeds both loops below. Flagging this the same
way the timestep-spacing approximation was flagged in v1.0 it's an
assumption, not a measurement, and would break if the rocket picks up
meaningfully asymmetric mass (ex. fins with very different chord, or
off-axis avionics).
%}

% Motor thrust model (G61W)

PEAK_THRUST = 63.2;   % Newtons
AVG_THRUST  = 61.0;   % Newtons
BURN_TIME   = 2.0;    % seconds published burn time on AeroTech ~ OpenRocket's 2.04s

% Gimbal geometry
CG_TO_NOZZLE       = 0.394;  % m, distance from CG to nozzle/pivot
MAX_DEFLECTION_DEG = 5.0;    % degrees, physical servo/gimbal limit (now a CONE limit, see below)

%{ 
   PID gains: same starting-point gains as the one-axis run, applied
   independently to both axes. NOT re-tuned for two-axis yet, this run
   is to confirm the two-axis loop and cone-limiting logic work first.
%}
KP = 0.8;
KI = 0.05;
KD = 0.15;

% ***: separate initial disturbance per axis, instead of one angle.
initial_pitch_deg = 2.0;   % initial pitch disturbance
initial_yaw_deg   = 1.5;   % initial yaw disturbance (different value on purpose, so the plots clearly show two independent axes)
              
dt = 0.001;                % integration timestep, seconds - unchanged

% Run sim
n_steps = floor(BURN_TIME / dt) + 1;
t_arr = zeros(1, n_steps);

% ***: separate state arrays for pitch and yaw instead of one set
pitch_deg_arr = zeros(1, n_steps);
yaw_deg_arr   = zeros(1, n_steps);
defl_pitch_arr = zeros(1, n_steps);
defl_yaw_arr   = zeros(1, n_steps);
defl_total_arr = zeros(1, n_steps);  % ***: combined deflection magnitude, for the cone check

% ***: independent rigid-body state per axis
pitch = deg2rad(initial_pitch_deg);
yaw   = deg2rad(initial_yaw_deg);
pitch_rate = 0.0;
yaw_rate   = 0.0;

% ***: independent PID state per axis (integral + previous error each)
integral_pitch = 0.0;
integral_yaw   = 0.0;
prev_error_pitch = 0.0;
prev_error_yaw   = 0.0;

t = 0.0;
for k = 1:n_steps
    error_pitch_deg = -rad2deg(pitch);  % want pitch -> 0
    error_yaw_deg   = -rad2deg(yaw);    % want yaw -> 0

    % PID ***, pitch axis
    integral_pitch = integral_pitch + error_pitch_deg * dt;
    derivative_pitch = (error_pitch_deg - prev_error_pitch) / dt;
    prev_error_pitch = error_pitch_deg;
    cmd_pitch_raw = KP * error_pitch_deg + KI * integral_pitch + KD * derivative_pitch;

    % PID ***, yaw axis
    integral_yaw = integral_yaw + error_yaw_deg * dt;
    derivative_yaw = (error_yaw_deg - prev_error_yaw) / dt;
    prev_error_yaw = error_yaw_deg;
    cmd_yaw_raw = KP * error_yaw_deg + KI * integral_yaw + KD * derivative_yaw;

    %{
    ***: cone-limited deflection instead of clipping each axis alone.
    A real two-axis gimbal has one physical deflection limit measured
    from centerline in any direction, not a separate 5 deg box on each
    axis. Clipping pitch and yaw independently would let a command like
    4 deg pitch + 4 deg yaw through (a 5.66 deg actual deflection, past
    the real limit). Instead: find the combined magnitude, and if it
    exceeds the limit, scale both components down together so the
    direction of the correction is preserved, just capped in length.
    %}
    cmd_total_mag = sqrt(cmd_pitch_raw^2 + cmd_yaw_raw^2);
    if cmd_total_mag > MAX_DEFLECTION_DEG
        scale = MAX_DEFLECTION_DEG / cmd_total_mag;
        deflection_pitch = cmd_pitch_raw * scale;
        deflection_yaw   = cmd_yaw_raw * scale;
    else
        deflection_pitch = cmd_pitch_raw;
        deflection_yaw   = cmd_yaw_raw;
    end
    deflection_total = sqrt(deflection_pitch^2 + deflection_yaw^2);

    % Physics ***: same I(t) lookup, now reused for both axes (see note above)
    I = interp1(i_sample_times, longitudinal_I, t, 'linear', 'extrap');

    % ***: torque computed per axis, each using its own deflection component
    torque_pitch = correctiveTorque(t, deflection_pitch, PEAK_THRUST, AVG_THRUST, BURN_TIME, CG_TO_NOZZLE);
    torque_yaw   = correctiveTorque(t, deflection_yaw,   PEAK_THRUST, AVG_THRUST, BURN_TIME, CG_TO_NOZZLE);

    pitch_accel = torque_pitch / I;
    yaw_accel   = torque_yaw / I;

    pitch_rate = pitch_rate + pitch_accel * dt;
    yaw_rate   = yaw_rate + yaw_accel * dt;
    pitch = pitch + pitch_rate * dt;
    yaw   = yaw + yaw_rate * dt;

    % Record
    t_arr(k) = t;
    pitch_deg_arr(k) = rad2deg(pitch);
    yaw_deg_arr(k)   = rad2deg(yaw);
    defl_pitch_arr(k) = deflection_pitch;
    defl_yaw_arr(k)   = deflection_yaw;
    defl_total_arr(k) = deflection_total;

    t = t + dt;
end

%{
 Plot results ***: 
 4 subplots instead of 2: pitch angle, yaw angle, per-axis
 deflection, and combined deflection magnitude (to visually confirm
 the cone limit is being respected).
%}
figure('Position', [100, 100, 1000, 900]);

subplot(4,1,1);
plot(t_arr, pitch_deg_arr, 'Color', [0.043, 0.114, 0.227], 'LineWidth', 2);
hold on;
yline(0, '--', 'Color', [0.5 0.5 0.5]);
ylabel('Pitch angle (deg)');
title(sprintf('TVR-1 two-axis correction  |  Kp=%.2f, Ki=%.2f, Kd=%.2f', KP, KI, KD));
grid on;

subplot(4,1,2);
plot(t_arr, yaw_deg_arr, 'Color', [0.043, 0.114, 0.227], 'LineWidth', 2);
hold on;
yline(0, '--', 'Color', [0.5 0.5 0.5]);
ylabel('Yaw angle (deg)');
grid on;

subplot(4,1,3);
plot(t_arr, defl_pitch_arr, 'Color', [1.0, 0.42, 0.21], 'LineWidth', 1.5);
hold on;
plot(t_arr, defl_yaw_arr, 'Color', [0.35, 0.55, 0.72], 'LineWidth', 1.5);
yline(MAX_DEFLECTION_DEG, ':', 'Color', [0.5 0.5 0.5]);
yline(-MAX_DEFLECTION_DEG, ':', 'Color', [0.5 0.5 0.5]);
ylabel('Per-axis deflection (deg)');
legend('Pitch', 'Yaw', 'Location', 'best');
grid on;

subplot(4,1,4);
plot(t_arr, defl_total_arr, 'Color', [1.0, 0.42, 0.21], 'LineWidth', 2);
hold on;
yline(MAX_DEFLECTION_DEG, ':', 'Color', [0.5 0.5 0.5]);
ylabel('Combined deflection (deg)');
xlabel('Time since ignition (s)');
grid on;

saveas(gcf, 'tvr1_pid_sim_2axis_matlab.png');

fprintf('Final pitch angle at burnout: %.3f deg\n', pitch_deg_arr(end));
fprintf('Final yaw angle at burnout: %.3f deg\n', yaw_deg_arr(end));
fprintf('Max combined deflection commanded: %.2f deg (cone limit is %.1f deg)\n', ...
        max(defl_total_arr), MAX_DEFLECTION_DEG);
fprintf('Saved plot to tvr1_pid_sim_2axis_matlab.png\n');

% Local functions

function trust_val = thrustFcn(t, peak, avg, burn_time)
    % Unchanged from v1.0 simplified thrust curve, quick rise to peak
    % then settle to published average.
    rise_time = 0.15;
    if t < 0 || t > burn_time
        trust_val = 0.0;
    elseif t < rise_time
        trust_val = peak * (t / rise_time);
    else
        trust_val = avg;
    end
end

function torque = correctiveTorque(t, deflection_deg, peak, avg, burn_time, lever_arm)
    %{
    *** from v1.0: no internal clipping here anymore. In the one-axis
    version this function clamped deflection_deg to +/- max_defl itself.
    In two-axis, clamping has to happen before this function is called
    (the cone-limit step above), because you can't correctly cone-limit
    pitch and yaw separately after the fact, each axis needs to know
    about the other axis's command first. So this function now just
    trusts the deflection it's given and converts it to torque.
    %}
    torque = thrustFcn(t, peak, avg, burn_time) * sind(deflection_deg) * lever_arm;
end

%{
NOTES: (two-axis specific, in addition to the 5 notes carried over from
the one-axis version - timestep spacing, simplified thrust curve,
single-axis-only, no aero/actuator dynamics, and PID output needing a servo-angle mapping later):

   Axisymmetry assumption: pitch and yaw share one moment-of-inertia
   column from OpenRocket (see note near the CSV load above). Will revisit
   this if the airframe becomes meaningfully asymmetric.

   Cone-limited deflection: the two axes are coupled only at the
   deflection limit (scaling both components down together to respect
   one physical cone angle). The PID loops themselves are still fully
   independent, no cross-axis coupling in the gains or the physics.
   A real gimbal likely has some mechanical cross-coupling between
   pitch and yaw depending on the linkage geometry; not modeled here.

   Different initial disturbances per axis (2.0 deg pitch, 1.5 deg
   yaw) were chosen on purpose just to make the two plots visually
   distinct for this test run, not based on any real expected
   disturbance. Swap these for real numbers once available.
%}