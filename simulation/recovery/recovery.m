%% recovery_calc.m  -  TVR-1 parachute sizing, descent, drift, shock load
clear; clc;

%% ---------- INPUTS: change these, nothing else is hardcoded below ----------
M_LOADED   = 1.150;   % kg, OpenRocket mass with motor (no recovery gear)
M_PROP     = 0.062;   % kg, G61W propellant (my estimate; check in OpenRocket)
M_RECOVERY = 0.28;    % kg, chute + cord + protector + bulkhead + anchor (estimate; weigh parts)
APOGEE     = 265.8;   % m
V_MAX      = 72.8;    % m/s
BURNOUT_T  = 2.04;    % s
CD_CHUTE   = 0.80;    % parachute Cd (NOT the 0.423 airframe Cd)
D_REF      = 0.1016;  % m, airframe diameter (for the no-chute check)
CHUTES_IN  = [30 34 36 40];
WINDS_MPH  = [0 5 10 15];
RHO = 1.225;  G = 9.81;  SHEAR = 1/7;
CSV_FILE   = '';      % e.g. 'export.csv' to read from OpenRocket; '' = use inputs above
%% ---------------------------------------------------------------------------

m_desc = M_LOADED - M_PROP + M_RECOVERY;
if ~isempty(CSV_FILE)
    [APOGEE, V_MAX, m_burnout] = fromOpenRocketCSV(CSV_FILE, BURNOUT_T);
    m_desc = m_burnout + M_RECOVERY;
    fprintf('From CSV: apogee %.1f m, vmax %.1f m/s, burnout mass %.3f kg\n', ...
            APOGEE, V_MAX, m_burnout);
end

area = @(d) pi * (d/2).^2;
v_t  = @(m, d, cd) sqrt(2*m*G ./ (RHO * cd * area(d)));

fprintf('\nDescent mass %.3f kg | apogee %.0f m | Cd %.2f\n', m_desc, APOGEE, CD_CHUTE);
fprintf('\nChute | v (m/s) | KE (J) | t (s) | open load @vmax (kN) | drift flat/shear @10 mph (m)\n');
w10 = 10 * 0.44704;
for din = CHUTES_IN
    d = din * 0.0254;
    v = v_t(m_desc, d, CD_CHUTE);
    load = 2 * 0.5 * RHO * V_MAX^2 * CD_CHUTE * area(d);
    fprintf('%4d in | %6.2f | %5.1f | %5.1f | %5.2f | %4.0f / %4.0f\n', ...
            din, v, 0.5*m_desc*v^2, APOGEE/v, load/1000, ...
            drift(w10, APOGEE, v, 0), drift(w10, APOGEE, v, SHEAR));
end

fprintf('\nDiameter needed for target speed:\n');
for v = [6.0 6.5 7.0]
    A = 2 * m_desc * G / (RHO * CD_CHUTE * v^2);
    fprintf('  %.1f m/s -> %.1f in\n', v, sqrt(4*A/pi) / 0.0254);
end

fprintf('\n36 in speed vs mass (+/-10%%) and Cd:\n');
d36 = 36 * 0.0254;
for f = [0.9 1.0 1.1]
    fprintf('  m=%.2f kg: Cd 0.8 -> %.2f, Cd 0.75 -> %.2f m/s\n', ...
            m_desc*f, v_t(m_desc*f, d36, 0.80), v_t(m_desc*f, d36, 0.75));
end

fprintf('\nDrift table, 36 in:\n');
v36 = v_t(m_desc, d36, CD_CHUTE);
for mph = WINDS_MPH
    w = mph * 0.44704;
    fprintf('  %2d mph: flat %4.0f m, shear %4.0f m\n', mph, ...
            drift(w, APOGEE, v36, 0), drift(w, APOGEE, v36, SHEAR));
end

% No-chute check using OpenRocket's ground-hit speed (17.526 m/s)
m_nochute = M_LOADED - M_PROP;  v_hit = 17.526;
cda_eff = 2 * m_nochute * G / (RHO * v_hit^2);
cda_nose = 0.423 * area(D_REF);
fprintf('\nNo-chute check: effective CdA from 17.5 m/s = %.4f m^2\n', cda_eff);
fprintf('  nose-on (Cd 0.423 x A_ref) = %.4f m^2 -> terminal %.0f m/s\n', ...
        cda_nose, sqrt(2*m_nochute*G / (RHO*cda_nose)));
fprintf('  KE at 17.5 m/s = %.0f J vs chute ~%.0f J\n', ...
        0.5*m_nochute*v_hit^2, 0.5*m_desc*v36^2);

%% Local functions (same style as PID_sim.m: must stay at the end of the file)
function s = drift(w, h, v, a)
    % w = 10 m reference wind (m/s), h = fall height (m), v = descent speed (m/s)
    % a = wind shear exponent; a = 0 gives flat wind
    if a == 0
        s = w * h / v;
    else
        s = (w / 10^a) * h^(1 + a) / ((1 + a) * v);
    end
end

function [apogee, vmax, m_burnout] = fromOpenRocketCSV(path, burnoutT)
    % Pull apogee, max speed and burnout mass from an OpenRocket CSV export.
    txt = strtrim(splitlines(string(fileread(path))));
    txt = txt(txt ~= "");
    hdrIdx = find(startsWith(erase(txt, " "), "#Time"), 1);
    if isempty(hdrIdx)
        error('Could not find the header row (a line starting with "# Time"). Check the export.');
    end
    names = strtrim(strsplit(erase(txt(hdrIdx), "#"), ","));
    rows  = txt(~startsWith(txt, "#"));
    M = zeros(numel(rows), numel(names));
    for i = 1:numel(rows)
        M(i, :) = str2double(strsplit(rows(i), ","));
    end
    iT  = find(startsWith(lower(names), "time"), 1);
    iA  = find(startsWith(lower(names), "altitude"), 1);
    iV  = find(startsWith(lower(names), "vertical velocity"), 1);
    iM  = find(startsWith(lower(names), "mass"), 1);   % total mass, not "Propellant mass"
    if any([isempty(iT) isempty(iA) isempty(iV) isempty(iM)])
        error('Missing a column. Need Time, Altitude, Vertical velocity and Mass in the export.');
    end
    scale = 1;
    if contains(names(iM), "(g)"), scale = 0.001; end   % grams -> kg
    apogee = max(M(:, iA));
    vmax   = max(abs(M(:, iV)));
    k = find(M(:, iT) >= burnoutT, 1);
    m_burnout = M(k, iM) * scale;
end