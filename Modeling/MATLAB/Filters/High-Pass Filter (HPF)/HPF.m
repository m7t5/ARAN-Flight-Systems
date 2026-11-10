
clc;
clear;
close all;

%% High Pass Filter (HPF) Modeling

% Circuit Parameters
R = 1000;          % Resistance (Ohm)
C = 10e-6;         % Capacitance (Farad)

% Cutoff Frequency
fc = 1/(2*pi*R*C);
wc = 2*pi*fc;

fprintf('High Pass Filter Model\n');
fprintf('----------------------\n');
fprintf('Resistance = %.2f Ohm\n', R);
fprintf('Capacitance = %.8f F\n', C);
fprintf('Cutoff Frequency = %.2f Hz\n', fc);

%% Transfer Function

s = tf('s');
H = (R*C*s)/(R*C*s + 1);

disp('Transfer Function:');
H

%% Frequency Response

f = logspace(0,5,1000);
w = 2*pi*f;

[mag,phase] = bode(H,w);

mag = squeeze(mag);
phase = squeeze(phase);

Magnitude_dB = 20*log10(mag);

%% Plot Magnitude Response

figure;

semilogx(f,Magnitude_dB,'b','LineWidth',2);
grid on;
hold on;

xline(fc,'r--','Cutoff Frequency');

yline(-3,'k--','-3 dB');

title('High Pass Filter - Magnitude Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

%% Plot Phase Response

figure;

semilogx(f,phase,'m','LineWidth',2);
grid on;

title('High Pass Filter - Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (Degrees)');

%% Input and Output Signal

Fs = 10000;
t = 0:1/Fs:0.1;

% Input Signal
x = sin(2*pi*20*t) + sin(2*pi*500*t);

% Filter Output
y = lsim(H,x,t);

figure;

plot(t,x,'b','LineWidth',1.2);
hold on;
plot(t,y,'r','LineWidth',1.5);

grid on;

title('HPF Input and Output Signals');
xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('Input Signal','Output Signal');

%% Pole-Zero Map

figure;
pzmap(H);
grid on;

title('HPF Pole-Zero Map');
