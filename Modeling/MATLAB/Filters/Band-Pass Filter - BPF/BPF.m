%% BAND-PASS FILTER (BPF)
% MATLAB and Simulink Modeling and Simulation
% Second-Order Band-Pass Filter

clc;
clear;
close all;

%% 1. FILTER PARAMETERS

R = 1000;          % Resistance (Ohm)
C = 1e-6;           % Capacitance (Farad)

% Lower and Upper Cutoff Frequencies
fL = 100;           % Lower Cutoff Frequency (Hz)
fH = 1000;          % Upper Cutoff Frequency (Hz)

% Angular Frequencies
wL = 2*pi*fL;
wH = 2*pi*fH;

% Center Frequency
f0 = sqrt(fL*fH);
w0 = 2*pi*f0;

% Bandwidth
BW = fH-fL;

% Quality Factor
Q = f0/BW;

fprintf('===== BAND PASS FILTER =====\n');

fprintf('Lower Cutoff Frequency = %.2f Hz\n', fL);
fprintf('Upper Cutoff Frequency = %.2f Hz\n', fH);
fprintf('Center Frequency = %.2f Hz\n', f0);
fprintf('Bandwidth = %.2f Hz\n', BW);
fprintf('Quality Factor = %.4f\n', Q);

%% 2. TRANSFER FUNCTION

% H(s) = (BW*s)/(s^2 + BW*s + w0^2)

num = [BW 0];

den = [1 BW w0^2];

G = tf(num, den);

disp('Transfer Function:');
G

%% 3. STEP RESPONSE

figure('Name','BPF Step Response');

step(G);

grid on;

title('Band-Pass Filter - Step Response');

xlabel('Time (seconds)');

ylabel('Amplitude');

%% 4. FREQUENCY RESPONSE

figure('Name','BPF Bode Plot');

bode(G);

grid on;

title('Band-Pass Filter - Bode Plot');

%% 5. FREQUENCY RESPONSE ANALYSIS

f = logspace(0,4,1000);

w = 2*pi*f;

[mag, phase] = bode(G,w);

mag = squeeze(mag);

phase = squeeze(phase);

figure('Name','Magnitude Response');

semilogx(f,20*log10(mag),'LineWidth',2);

grid on;

hold on;

xline(fL,'--r','Lower Cutoff');

xline(fH,'--r','Upper Cutoff');

xline(f0,'--k','Center Frequency');

title('BPF Magnitude Response');

xlabel('Frequency (Hz)');

ylabel('Magnitude (dB)');

%% 6. SIMULINK MODEL CREATION

model = 'Band_Pass_Filter_Model';

if bdIsLoaded(model)
    close_system(model,0);
end

new_system(model);

open_system(model);

set_param(model,'StopTime','0.1');

set_param(model,'Solver','ode45');

%% 7. ADD SIMULINK BLOCKS

% Sine Wave Input
add_block('simulink/Sources/Sine Wave', ...
    [model '/Sine Input'], ...
    'Position',[50 100 100 130], ...
    'Amplitude','1', ...
    'Frequency',num2str(w0));

% Transfer Function
add_block('simulink/Continuous/Transfer Fcn', ...
    [model '/Band Pass Filter'], ...
    'Position',[200 95 350 135], ...
    'Numerator',mat2str(num), ...
    'Denominator',mat2str(den));

% Scope
add_block('simulink/Sinks/Scope', ...
    [model '/Output Scope'], ...
    'Position',[470 100 510 130]);

% To Workspace
add_block('simulink/Sinks/To Workspace', ...
    [model '/Output Data'], ...
    'Position',[450 190 550 220], ...
    'VariableName','BPF_Output', ...
    'SaveFormat','Timeseries');

%% 8. CONNECT BLOCKS

add_line(model,'Sine Input/1', ...
    'Band Pass Filter/1','autorouting','on');

add_line(model,'Band Pass Filter/1', ...
    'Output Scope/1','autorouting','on');

add_line(model,'Band Pass Filter/1', ...
    'Output Data/1','autorouting','on');

%% 9. SAVE SIMULINK MODEL

save_system(model);

%% 10. RUN SIMULATION

simOut = sim(model);

BPF_Output = simOut.get('BPF_Output');

%% 11. PLOT SIMULATION OUTPUT

figure('Name','BPF Simulink Output');

plot(BPF_Output.Time,BPF_Output.Data, ...
    'LineWidth',2);

grid on;

title('Band-Pass Filter Output');

xlabel('Time (seconds)');

ylabel('Output Amplitude');

%% 12. INPUT AND OUTPUT COMPARISON

t = BPF_Output.Time;

Vin = sin(w0*t);

Vout = squeeze(BPF_Output.Data);

figure('Name','Input vs Output');

plot(t,Vin,'--','LineWidth',1.5);

hold on;

plot(t,Vout,'LineWidth',2);

grid on;

title('Input and Output Comparison');

xlabel('Time (seconds)');

ylabel('Amplitude');

legend('Input Signal','Output Signal');

%% 13. FINAL RESULTS

fprintf('\n===== SIMULATION RESULTS =====\n');

fprintf('Center Frequency = %.2f Hz\n',f0);

fprintf('Bandwidth = %.2f Hz\n',BW);

fprintf('Quality Factor = %.4f\n',Q);

fprintf('\nSimulation Completed Successfully!\n');

fprintf('Simulink Model Saved: %s.slx\n',model);