function [pos vel Px att_est Patt] = DvKalman(z, u, att_meas, dt)

persistent A_p H_p Q_p R_p x_p P_p  %_p for position 
persistent A_a H_a Q_a R_a x_a P_a  %_a for attitude
persistent x_z P_z Q_z              %_z for azimuth
persistent firstRun


if isempty(firstRun)
  firstRun = 1;
  
  %position
  H_p = [1 0]; 
  R_p = 0.3^2;      % measurement noise variance 
  x_p = [ 0 0 ]';
  P_p = 5 * eye(2); % uncertainty matrix, initial guess (will get corrected)

  %attitude
  H_a = [1 0]; 
  R_a = 1.0;        % measurement noise variance
  x_a = [ 90 0 ]';  % initial zenith
  P_a = 5 * eye(2);
    
  x_z = [0 0]';     % initial azimuth
  P_z = 5 * eye(2);

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

xp_p = A_p * x_p;  % xp is x_(k+1)
Pp_p = A_p * P_p * A_p' + Q_p;    

K_p = Pp_p * H_p' * inv(H_p * Pp_p * H_p' + R_p); 

x_p = xp_p + K_p * (z - H_p * xp_p);
P_p = Pp_p - K_p * H_p * Pp_p;   

  
pos = x_p(1);
vel = x_p(2);
Px  = P_p ;

%kalman filter alg for attitude

A_a = [ 1 dt ;
        0 1 ];

Q_a = dt * [0.1, 0;
            0, 1];

%zenith
xp_a = A_a * x_a;
Pp_a = A_a * P_a * A_a' + Q_a;

K_a = Pp_a * H_a' * inv(H_a * Pp_a * H_a' + R_a);

x_a = xp_a + K_a * (att_meas(1) - H_a * xp_a);
P_a = Pp_a - K_a * H_a * Pp_a;

%azimuth
xp_z = A_a * x_z;
Pp_z = A_a * P_z * A_a' + Q_a;

K_z = Pp_z * H_a' * inv(H_a * Pp_z * H_a' + R_a);

x_z = xp_z + K_z * (att_meas(2) - H_a * xp_z);
P_z = Pp_z - K_z * H_a * Pp_z;

att_est = [x_a(1), x_z(1)];
Patt    = [P_a(1,1), P_z(1,1)];

end