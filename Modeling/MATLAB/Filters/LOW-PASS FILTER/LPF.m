
%% RC LOW-PASS FILTER MODEL
% MATLAB & Simulink Simulation
% First-Order Passive Low-Pass Filter

clc;
clear;
close all;

%% 1. FILTER PARAMETERS

R = 1000;       % Resistance (Ohm)
C = 1e-6;       % Capacitance (Farad)

tau = R * C;                % Time Constant
fc = 1 / (2*pi*R*C);        % Cutoff Frequency

fprintf('===== RC LOW PASS FILTER =====\n');
fprintf('Resistance = %.2f Ohm\n', R);
fprintf('Capacitance = %.2e F\n', C);
fprintf('Time Constant = %.6f s\n', tau);
fprintf('Cutoff Frequency = %.2f Hz\n', fc);

%% 2. TRANSFER FUNCTION

% H(s) = 1 / (RC*s + 1)

num = [1];
den = [R*C 1];

G = tf(num, den);

disp('Transfer Function:');
G

%% 3. STEP RESPONSE

figure('Name','Step Response');

step(G, 0.01);

grid on;

title('RC Low-Pass Filter - Step Response');
xlabel('Time (seconds)');
ylabel('Output Voltage (V)');

%% 4. FREQUENCY RESPONSE

figure('Name','Bode Plot');

bode(G);

grid on;

title('RC Low-Pass Filter - Bode Plot');

%% 5. SIMULINK MODEL CREATION

model = 'RC_LowPass_Filter_Model';

if bdIsLoaded(model)
    close_system(model, 0);
end

new_system(model);
open_system(model);

set_param(model, 'StopTime', '0.01');
set_param(model, 'Solver', 'ode45');

%% 6. ADD SIMULINK BLOCKS

% Step Input
add_block('simulink/Sources/Step', ...
    [model '/Step Input'], ...
    'Position', [50 100 100 130], ...
    'Time', '0', ...
    'Before', '0', ...
    'After', '1');

% Transfer Function
add_block('simulink/Continuous/Transfer Fcn', ...
    [model '/Low Pass Filter'], ...
    'Position', [200 95 350 135], ...
    'Numerator', mat2str(num), ...
    'Denominator', mat2str(den));

% Scope
add_block('simulink/Sinks/Scope', ...
    [model '/Output Scope'], ...
    'Position', [470 100 510 130]);

% To Workspace
add_block('simulink/Sinks/To Workspace', ...
    [model '/Output Data'], ...
    'Position', [450 190 550 220], ...
    'VariableName', 'LPF_Output', ...
    'SaveFormat', 'Timeseries');

%% 7. CONNECT BLOCKS

add_line(model, 'Step Input/1', ...
    'Low Pass Filter/1', 'autorouting', 'on');

add_line(model, 'Low Pass Filter/1', ...
    'Output Scope/1', 'autorouting', 'on');

add_line(model, 'Low Pass Filter/1', ...
    'Output Data/1', 'autorouting', 'on');

%% 8. SAVE SIMULINK MODEL

save_system(model);

%% 9. RUN SIMULATION

simOut = sim(model);

LPF_Output = simOut.get('LPF_Output');

%% 10. PLOT SIMULATION RESULTS

figure('Name','Simulink Output');

plot(LPF_Output.Time, LPF_Output.Data, ...
    'LineWidth', 2);

grid on;

title('RC Low-Pass Filter - Simulink Output');
xlabel('Time (seconds)');
ylabel('Output Voltage (V)');

%% 11. INPUT AND OUTPUT COMPARISON

t = LPF_Output.Time;
Vin = ones(size(t));
Vout = squeeze(LPF_Output.Data);

figure('Name','Input vs Output');

plot(t, Vin, '--', 'LineWidth', 1.5);
hold on;

plot(t, Vout, 'LineWidth', 2);

grid on;

title('Input and Output Comparison');
xlabel('Time (seconds)');
ylabel('Voltage (V)');

legend('Input Voltage', 'Output Voltage');

%% 12. FINAL RESULTS

fprintf('\n===== SIMULATION RESULTS =====\n');

fprintf('Cutoff Frequency = %.2f Hz\n', fc);

fprintf('Time Constant = %.6f seconds\n', tau);

fprintf('Theoretical Output at t = tau: %.4f V\n', ...
    1-exp(-1));

fprintf('\nSimulation Completed Successfully!\n');

fprintf('Simulink Model Saved: %s.slx\n', model);
