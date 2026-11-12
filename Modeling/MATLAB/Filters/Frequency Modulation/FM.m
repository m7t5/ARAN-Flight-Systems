clc;
clear;
close all;

%% 1. Parameters
Am = 1;          % Message signal amplitude
Ac = 2;          % Carrier signal amplitude
fm = 100;        % Message frequency (Hz)
fc = 1000;       % Carrier frequency (Hz)
fs = 100000;     % Sampling frequency (Hz)
T = 0.05;        % Simulation time (s)

delta_f = 500;   % Frequency deviation (Hz)
beta = delta_f / fm;  % Modulation index

%% 2. Time Vector
t = 0:1/fs:T-1/fs;

%% 3. Message Signal
message = Am * cos(2*pi*fm*t);

%% 4. Carrier Signal
carrier = Ac * cos(2*pi*fc*t);

%% 5. Frequency Modulation
fm_signal = Ac * cos(2*pi*fc*t + beta*sin(2*pi*fm*t));

%% 6. Plot Time Domain Signals
figure;

subplot(3,1,1);
plot(t, message, 'b', 'LineWidth', 1.5);
grid on;
title('Message Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, carrier, 'r', 'LineWidth', 1);
grid on;
title('Carrier Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, fm_signal, 'k', 'LineWidth', 1);
grid on;
title('Frequency Modulated Signal (FM)');
xlabel('Time (s)');
ylabel('Amplitude');

%% 7. Frequency Spectrum
N = length(fm_signal);

Y = fft(fm_signal);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:N/2)/N;

figure;
plot(f, P1, 'LineWidth', 1.5);
grid on;
title('FM Signal Frequency Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 3000]);

%% 8. Display Results
fprintf('Frequency Modulation Results:\n');
fprintf('Carrier Frequency = %d Hz\n', fc);
fprintf('Message Frequency = %d Hz\n', fm);
fprintf('Frequency Deviation = %d Hz\n', delta_f);
fprintf('Modulation Index = %.2f\n', beta);