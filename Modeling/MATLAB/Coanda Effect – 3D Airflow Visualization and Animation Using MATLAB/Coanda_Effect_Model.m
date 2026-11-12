clc;
clear;
close all;

%% 1. Physical Parameters

rho_air = 1.225;       % Air density (kg/m^3)
rho_jet = 1.225;       % Jet air density (kg/m^3)

U_inf = 20;            % Free-stream velocity (m/s)
U_jet = 40;            % Jet velocity (m/s)

b = 0.05;              % Jet slot width (m)
c = 0.5;               % Reference chord length (m)

h = 0.01;              % Distance between jet and surface (m)
R = 0.15;              % Surface radius of curvature (m)

CL0 = 0.4;             % Initial lift coefficient
K_CL = 0.8;            % Lift model coefficient
K_CP = 1.2;            % Pressure model coefficient

Cmu_sat = 1.0;         % Saturation parameter
R_min = 0.03;          % Minimum reference curvature radius (m)

%% 2. Momentum Coefficient

q_inf = 0.5 * rho_air * U_inf^2;

Cmu = (rho_jet * U_jet^2 * b) / (q_inf * c);

%% 3. Coanda Attachment Model

% Effect of jet momentum
jet_effect = 1 - exp(-Cmu / Cmu_sat);

% Effect of surface distance
distance_effect = exp(-h / R);

% Effect of surface curvature
curvature_effect = 1 - exp(-R_min / R);

% Overall flow attachment factor
attachment = jet_effect * distance_effect * curvature_effect;

%% 4. Lift and Pressure Coefficients

CL = CL0 + K_CL * Cmu * attachment;

Cp_min = -K_CP * Cmu * attachment;

%% 5. Display Results

fprintf('-----------------------------------\n');
fprintf('       COANDA EFFECT MODEL\n');
fprintf('-----------------------------------\n');

fprintf('Jet Velocity       = %.2f m/s\n', U_jet);
fprintf('Surface Radius     = %.3f m\n', R);
fprintf('Jet Momentum Cmu   = %.4f\n', Cmu);
fprintf('Flow Attachment    = %.4f\n', attachment);
fprintf('Lift Coefficient   = %.4f\n', CL);
fprintf('Minimum Pressure Cp= %.4f\n', Cp_min);

%% 6. Effect of Jet Velocity

U_range = linspace(5, 80, 100);

Cmu_range = (rho_jet .* U_range.^2 .* b) ./ (q_inf .* c);

jet_effect_range = 1 - exp(-Cmu_range ./ Cmu_sat);

attachment_range = jet_effect_range .* ...
                   distance_effect .* curvature_effect;

CL_range = CL0 + K_CL .* Cmu_range .* attachment_range;

%% 7. Effect of Surface Curvature

R_range = linspace(0.03, 0.5, 100);

curvature_range = 1 - exp(-R_min ./ R_range);

attachment_R = jet_effect .* distance_effect .* curvature_range;

CL_R = CL0 + K_CL .* Cmu .* attachment_R;

%% 8. Effect of Jet-Surface Distance

h_range = linspace(0.001, 0.08, 100);

distance_range = exp(-h_range ./ R);

attachment_h = jet_effect .* distance_range .* curvature_effect;

CL_h = CL0 + K_CL .* Cmu .* attachment_h;

%% 9. Plot Results

figure('Name','Coanda Effect Modeling','Color','w');

% Plot 1: Jet Velocity
subplot(2,2,1);

plot(U_range, CL_range, 'b', 'LineWidth', 2);

xlabel('Jet Velocity (m/s)');
ylabel('Lift Coefficient (C_L)');
title('Effect of Jet Velocity');

grid on;

% Plot 2: Surface Curvature
subplot(2,2,2);

plot(R_range, CL_R, 'r', 'LineWidth', 2);

xlabel('Surface Radius (m)');
ylabel('Lift Coefficient (C_L)');
title('Effect of Surface Curvature');

grid on;

% Plot 3: Jet-Surface Distance
subplot(2,2,3);

plot(h_range, CL_h, 'm', 'LineWidth', 2);

xlabel('Jet-Surface Distance (m)');
ylabel('Lift Coefficient (C_L)');
title('Effect of Surface Distance');

grid on;

% Plot 4: Flow Attachment
subplot(2,2,4);

plot(U_range, attachment_range, 'k', 'LineWidth', 2);

xlabel('Jet Velocity (m/s)');
ylabel('Attachment Factor');
title('Flow Attachment Behavior');

grid on;

sgtitle('Coanda Effect - Mathematical Modeling');
