clear all
close all

filename = 'Sensor_Fusion_OR_Data_updated.csv'; %wtv the file name for the data is
       
%skip comment lines in the csv files using 
%filetype: text and commentstyle: #
opts = detectImportOptions(filename, 'FileType', 'text', 'CommentStyle', '#');
T = readtable(filename, opts);
        
%time and altitude
time = T{:, 1};       %time in seconds
position = T{:, 2};   %altitude in meters
vert_acc = T{:,4};    %vertical accel in m/s^2
zenith = T{:,9};      %vertical orientation (deg from y axis)
azimuth = T{:,10};    %lateral orientation (deg from north horizontal axis)

Nsamples = length(time); 

Xsaved = zeros(Nsamples, 2);
Zsaved = zeros(Nsamples, 1);
Psaved = zeros(Nsamples, 2);
AttSaved = zeros(Nsamples, 2);
AttMeas = zeros(Nsamples, 2);
PattSaved = zeros(Nsamples, 2);

%baro noise
rng(40); %noise seed for reproducibility 
baro_sigma = 0.3;
noise_position = position + baro_sigma * randn(Nsamples, 1);

dt_prev = time(2) - time(1); %dynamic dt, can be changed to dt = 0.05; if using data from OpenRocket

for k = 1:Nsamples

  if k > 1
      dt = time(k) - time(k-1);
      if dt <= 0
          dt = dt_prev;
      end
      dt_prev = dt;
  else 
      dt = dt_prev;
  end

  z = noise_position(k);
  u = vert_acc(k);
  att_meas = [zenith(k), azimuth(k)];
  [pos, vel, P, att_est, Patt] = DvKalman(z, u, att_meas, dt);

  Xsaved(k, :)      = [pos, vel];
  Zsaved(k)         = z;
  Psaved(k, :)      = [P(1,1), P(2,2)];
  AttSaved(k, :)    = att_est;
  AttMeas(k, :)     = att_meas;
  PattSaved(k, :)   = Patt;
end

writematrix([Xsaved Psaved AttSaved PattSaved], 'kf_vectors.csv');

t = time';

%pos + velo
fig1 = figure;
left_color = [0 0 0]; % black
right_color= [0 0 1]; % blue
set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
hold on
yyaxis left
plot(t, Zsaved(:), 'r.','markersize',20)
plot(t, Xsaved(:, 1),'w-','linewidth',4)
ylabel('position (m)')

yyaxis right
plot(t, Xsaved(:, 2),'b-','linewidth',4)
xlabel('time (s)'); ylabel('velocity (m/s)')
title('Position and Velocity')
legend('Raw Position','Kalman Position','Kalman Velocity')
set(gca,'fontsize',18); grid on
set(gcf, 'Position', [10, 100, 1200, 500])

%zen + azi
fig2 = figure;
hold on
plot(t, AttMeas(:, 1), 'r.', 'markersize', 15)
plot(t, AttSaved(:, 1), 'w-', 'linewidth', 3)
plot(t, AttSaved(:, 2), 'g-', 'linewidth', 3)
xlabel('time (s)')
ylabel('Angle (degrees)')
title('Rocket Attitude Estimation')
legend('Raw Zenith', 'Kalman Zenith', 'Kalman Azimuth')
set(gca, 'fontsize', 18); grid on
set(gcf, 'Position', [1310, 100, 1200, 500])

