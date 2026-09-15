% TVR-1 - Single-axis TVC PID control loop simulation
% Simulates one pitch/yaw axis of the rocket during the G61W burn
% (0 to 2.04s), using moment-of-inertia data pulled from the
% OpenRocket sim, and checks whether a chosen set of PID gains can
% correct an initial disturbance before the motor burns out.
%
% First-pass, single-axis model. Known simplifications are listed in
% the comments at the bottom - good enough to start comparing gain
% sets before committing anything to a real flight.

clear; clc; close all;

% 1. Load moment-of-inertia data (burn phase only)
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
            break  % stop reading once we hit burnout - only need the burn phase
        end
        continue
    end
    parts = strsplit(line, ',');
    longitudinal_I(end+1) = str2double(parts{1});
end
fclose(fid);

% OpenRocket's timestep isn't uniform (adaptive), but we only have the
% two real anchor points (t=0, t=burnout) plus the ordered sequence in
% between. Approximation: spread the samples evenly across the known
% burn duration. Flagged again in the notes at the bottom.
i_sample_times = linspace(0, BURNOUT_TIME, length(longitudinal_I));

% 2. Motor thrust model (G61W) - see local function thrustFcn() below

PEAK_THRUST = 63.2;   % Newtons
AVG_THRUST  = 61.0;   % Newtons
BURN_TIME   = 2.0;    % seconds published burn time on AeroTech ~ OpenRocket's 2.04s

% 3. Gimbal geometry from the calcs worked in mech channel
CG_TO_NOZZLE       = 0.394;  % m, distance from CG to nozzle/pivot
MAX_DEFLECTION_DEG = 5.0;    % degrees, physical servo/gimbal limit

% 4. PID gains and simulation settings
% Starting-point gains - NOT TUNED, just a first guess to see the
% simulation working. Will change these and re run until we reach an optimal one.
KP = 0.8;
KI = 0.05;
KD = 0.15;

initial_angle_deg = 2.0;   % initial disturbance
dt = 0.001;                % integration timestep, seconds

%% 6. Run the simulation
n_steps = floor(BURN_TIME / dt) + 1;
t_arr = zeros(1, n_steps);
angle_deg_arr = zeros(1, n_steps);
defl_deg_arr = zeros(1, n_steps);

angle = deg2rad(initial_angle_deg);  % rocket tilt from vertical (rad)
angular_velocity = 0.0;

integral = 0.0;
prev_error = 0.0;

t = 0.0;
for k = 1:n_steps
    error_deg = -rad2deg(angle);  % want angle -> 0

    % PID update
    integral = integral + error_deg * dt;
    derivative = (error_deg - prev_error) / dt;
    prev_error = error_deg;
    deflection_cmd = KP * error_deg + KI * integral + KD * derivative;

    % Physics update
    I = interp1(i_sample_times, longitudinal_I, t, 'linear', 'extrap');
    torque = correctiveTorque(t, deflection_cmd, MAX_DEFLECTION_DEG, PEAK_THRUST, AVG_THRUST, BURN_TIME, CG_TO_NOZZLE);
    angular_accel = torque / I;

    angular_velocity = angular_velocity + angular_accel * dt;
    angle = angle + angular_velocity * dt;

    % Record
    t_arr(k) = t;
    angle_deg_arr(k) = rad2deg(angle);
    defl_deg_arr(k) = max(min(deflection_cmd, MAX_DEFLECTION_DEG), -MAX_DEFLECTION_DEG);

    t = t + dt;
end

%% 7. Plot results
figure('Position', [100, 100, 900, 700]);

subplot(2,1,1);
plot(t_arr, angle_deg_arr, 'Color', [0.043, 0.114, 0.227], 'LineWidth', 2);
hold on;
yline(0, '--', 'Color', [0.5 0.5 0.5]);
ylabel('Rocket tilt angle (deg)');
title(sprintf('TVR-1 single-axis correction  |  Kp=%.2f, Ki=%.2f, Kd=%.2f', KP, KI, KD));
grid on;

subplot(2,1,2);
plot(t_arr, defl_deg_arr, 'Color', [1.0, 0.42, 0.21], 'LineWidth', 2);
hold on;
yline(MAX_DEFLECTION_DEG, ':', 'Color', [0.5 0.5 0.5]);
yline(-MAX_DEFLECTION_DEG, ':', 'Color', [0.5 0.5 0.5]);
ylabel('Gimbal deflection (deg)');
xlabel('Time since ignition (s)');
grid on;

saveas(gcf, 'tvr1_pid_sim_matlab.png');

fprintf('Final tilt angle at burnout: %.3f deg\n', angle_deg_arr(end));
fprintf('Max deflection commanded: %.2f deg (limit is %.1f deg)\n', ...
        max(abs(defl_deg_arr)), MAX_DEFLECTION_DEG);
fprintf('Saved plot to tvr1_pid_sim_matlab.png\n');

%% Local functions

function trust_val = thrustFcn(t, peak, avg, burn_time)
    % Simplified thrust curve: quick rise to peak, settle to the
    % published average for the remainder of the burn. NOT the real
    % digitized curve - see notes at the bottom for how to improve this.
    rise_time = 0.15;  % seconds to reach peak - a rough, typical assumption
    if t < 0 || t > burn_time
        trust_val = 0.0;
    elseif t < rise_time
        trust_val = peak * (t / rise_time);
    else
        trust_val = avg;
    end
end

function torque = correctiveTorque(t, deflection_deg, max_defl, peak, avg, burn_time, lever_arm)
    % Torque about the CG produced by gimballing the motor.
    deflection_deg = max(min(deflection_deg, max_defl), -max_defl);
    torque = thrustFcn(t, peak, avg, burn_time) * sind(deflection_deg) * lever_arm;
end

%{
NOTES:

1. Moment of inertia timing: OpenRocket's timestep isn't evenly spaced
   (it's adaptive). We only have two confirmed real timestamps (t=0 and
   t=2.04s burnout) from the event log, so the samples in between are
   assumed evenly spaced across that duration. The values are data,
   their exact timing is an approximation.

2. Thrust curve: this uses peak/average thrust with a rough linear
   rise, not G61W's actual digitized thrust curve. A real eng thrust
   curve file (from ThrustCurve.org) would replace this with the real
   shape and meaningfully improve accuracy, especially in the first
   0.1-0.2s.

3. Single axis only: real flight needs this on two perpendicular axes
   simultaneously. This model is deliberately simplified to one axis
   to make gain-tuning intuition easier to build first.

4. No aerodynamic effects (drag, wind gusts) or gimbal actuator
   dynamics (servo speed/response lag) are modeled yet - this is
   pure rigid-body torque response, which is optimistic vs. a real
   flight.

5. PID output is used directly as "commanded deflection in degrees".
   A firmware implementation needs a mapping from this command to actual
   servo angle, which depends on final gimbal linkage ratio.
%}
