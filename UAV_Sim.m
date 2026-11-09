function UAV_Sim()
% ARAN Flight Systems - 6-DOF UAV Simulation
clc; close all;

%% CONFIG
V_trim     = 18;
h0         = 100;
t_end      = 20;
use_inputs = true;
animate    = true;
save_video = true;

dist.v     = 0.0;
dist.phi   = 0.0;
dist.theta = 0.0;

%% MODEL
P = uav_params();
[alpha_t, de_t, T_t] = uav_trim(P, V_trim);

trim.alpha = alpha_t;
trim.de    = de_t;
trim.T     = T_t;
trim.on    = use_inputs;

fprintf('--------- TRIM RESULT ---------\n');
fprintf('Airspeed        : %6.2f m/s\n', V_trim);
fprintf('Angle of attack : %6.2f deg\n', alpha_t*180/pi);
fprintf('Elevator        : %6.2f deg\n', de_t*180/pi);
fprintf('Thrust          : %6.2f N\n',   T_t);
fprintf('------------------------------\n');

%% INITIAL STATE
th0 = alpha_t + dist.theta*pi/180;
x0  = [V_trim*cos(alpha_t); dist.v; V_trim*sin(alpha_t); ...
       0; 0; 0; dist.phi*pi/180; th0; 0; 0; 0; -h0];

%% SOLVE
opts = odeset('RelTol',1e-7,'AbsTol',1e-9,'MaxStep',0.05);
[t, X] = ode45(@(t,x) uav_eom(t,x,P,trim), [0 t_end], x0, opts);

%% POST-PROCESS
n = length(t);
de = zeros(n,1); da = zeros(n,1); dr = zeros(n,1);
alpha = zeros(n,1); beta = zeros(n,1); Vt = zeros(n,1);
for i = 1:n
    [de(i), da(i), dr(i)] = uav_controls(t(i), trim);
    Vt(i)    = sqrt(X(i,1)^2 + X(i,2)^2 + X(i,3)^2);
    alpha(i) = atan2(X(i,3), X(i,1));
    beta(i)  = asin(X(i,2) / max(Vt(i), 0.5));
end

R2D = 180/pi;
S_ = struct('t',t,'u',X(:,1),'v',X(:,2),'w',X(:,3), ...
            'p',X(:,4),'q',X(:,5),'r',X(:,6), ...
            'phi',X(:,7)*R2D,'theta',X(:,8)*R2D,'psi',X(:,9)*R2D, ...
            'Xe',X(:,10),'Ye',X(:,11),'Ze',X(:,12), ...
            'de',de*R2D,'da',da*R2D,'dr',dr*R2D, ...
            'alpha',alpha*R2D,'beta',beta*R2D,'V',Vt);

%% PLOTS
uav_plots(S_);

%% ANIMATION
if animate
    uav_animate(t, X, save_video);
end

end