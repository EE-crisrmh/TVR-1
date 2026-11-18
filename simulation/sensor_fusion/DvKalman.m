function [pos, vel, Px, att_est, Patt] = DvKalman(z, u, att_meas, gyro_rates, azimuth, dt)

persistent H_p Q_p R_p x_p P_p  %_p for position 
persistent H_a Q_a R_a          %_a for attitude
persistent x_tx P_tx x_ty P_ty  %_t for tilt x/y
persistent firstRun


if isempty(firstRun)
  firstRun = 1;
  
  %position
  H_p = [1 0]; 
  R_p = 0.3^2;          % measurement noise variance 
  x_p = [ 0 0 ]';
  P_p = 5 * eye(2);     % uncertainty matrix, initial guess (will get corrected)

  %attitude
  H_a = [1 0]; 
  R_a = 0.7^2;          % measurement noise variance
  x_tx = [ 0 0 ]';      % initial tilt
  x_ty = [ 0 0 ]';
  P_tx = diag([5,1]);
  P_ty = diag([5,1]);
    
end


A_p = [ 1 dt ;
        0 1  ];

B_p = [ 0.5 * dt^2;
        dt];

% Q if using fixed dt (like from sims)
% dt = 0.05;
% Q = [ 6.25, 0 ;
%       0,    12.5 ];


% dt dependent Q
Q_p = dt * [1, 0; 
            0, 5]; % process noise covariance

% kalman filter algorithm for position

xp_p = A_p * x_p + B_p * u;  
Pp_p = A_p * P_p * A_p' + Q_p;    

K_p = (Pp_p * H_p') / (H_p * Pp_p * H_p' + R_p); 

x_p = xp_p + K_p * (z - H_p * xp_p);
P_p = Pp_p - K_p * H_p * Pp_p;   

  
pos = x_p(1);
vel = x_p(2);
Px  = P_p ;

%kalman filter alg for attitude

A_a = [ 1 -dt ;
        0 1 ];
B_a = [dt;
        0];

Q_a = dt * [0.1, 0;
            0, 0.05];

pitch_rate  = -gyro_rates(1);    %deg/s
yaw_rate    = gyro_rates(2);     %""

u_tx = pitch_rate * cosd(azimuth) - yaw_rate * sind(azimuth);
u_ty = pitch_rate * sind(azimuth) - yaw_rate * cosd(azimuth);

%tilt X prediction
xp_tx = A_a * x_tx + B_a * u_tx;
Pp_tx = A_a * P_tx * A_a' + Q_a;

K_tx = (Pp_tx * H_a') / (H_a * Pp_tx * H_a' + R_a);

x_tx = xp_tx + K_tx * (att_meas(1) - H_a * xp_tx);
P_tx = Pp_tx - K_tx * H_a * Pp_tx;

%tilt Y prediction
xp_ty = A_a * x_ty + B_a * u_ty;
Pp_ty = A_a * P_ty * A_a' + Q_a;

K_ty = (Pp_ty * H_a') / (H_a * Pp_ty * H_a' + R_a);

x_ty = xp_ty + K_ty * (att_meas(2) - H_a * xp_ty);
P_ty = Pp_ty - K_ty * H_a * Pp_ty;

att_est = [x_tx(1), x_ty(1)];
Patt    = [P_tx(1,1), P_ty(1,1)];

end