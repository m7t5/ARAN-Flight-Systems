%% AMPLITUDE MODULATION (AM)
% Generation, Modulation, Demodulation and Spectrum Analysis

clc;
clear;
close all;

%% 1. PARAMETERS

Am = 1;             % Message Amplitude
Ac = 2;             % Carrier Amplitude

fm = 100;           % Message Frequency (Hz)
fc = 1000;          % Carrier Frequency (Hz)

mu = 0.5;           % Modulation Index

fs = 100000;        % Sampling Frequency
duration = 0.05;    % Simulation Duration

t = 0:1/fs:duration-1/fs;

fprintf('===== AM SYSTEM PARAMETERS =====\n');

fprintf('Message Frequency = %.2f Hz\n',fm);
fprintf('Carrier Frequency = %.2f Hz\n',fc);
fprintf('Modulation Index = %.2f\n',mu);

%% 2. MESSAGE SIGNAL

message = Am*cos(2*pi*fm*t);

figure;

plot(t,message,'LineWidth',1.5);

grid on;

title('Message Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

%% 3. CARRIER SIGNAL

carrier = Ac*cos(2*pi*fc*t);

figure;

plot(t,carrier,'LineWidth',1.2);

grid on;

title('Carrier Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

%% 4. AM MODULATION

% AM Equation:
% s(t) = Ac[1 + mu*cos(2*pi*fm*t)]cos(2*pi*fc*t)

AM_signal = Ac*(1 + mu*cos(2*pi*fm*t)) ...
            .* cos(2*pi*fc*t);

figure;

plot(t,AM_signal,'LineWidth',1.2);

grid on;

title('Amplitude Modulated Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

%% 5. AM ENVELOPE

upper_envelope = Ac*(1 + mu*cos(2*pi*fm*t));

lower_envelope = -upper_envelope;

figure;

plot(t,AM_signal,'b');

hold on;

plot(t,upper_envelope,'r--','LineWidth',1.5);

plot(t,lower_envelope,'r--','LineWidth',1.5);

grid on;

title('AM Signal Envelope');

xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('AM Signal','Upper Envelope','Lower Envelope');

%% 6. DEMODULATION
% Coherent Demodulation

demod_product = AM_signal .* cos(2*pi*fc*t);

% Frequency Domain Processing

N = length(demod_product);

Y = fft(demod_product);

f = (0:N-1)*(fs/N);

% Low Pass Filter in Frequency Domain

cutoff = 300;

filter_mask = (f <= cutoff) | (f >= fs-cutoff);

Y_filtered = Y .* filter_mask;

% Convert Back to Time Domain

baseband = real(ifft(Y_filtered));

% Remove DC Component and Recover Message

demodulated = (baseband - Ac/2)/(Ac*mu/2);

figure;

plot(t,message,'b','LineWidth',1.5);

hold on;

plot(t,demodulated,'r--','LineWidth',1.5);

grid on;

title('AM Demodulation');

xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('Original Message','Recovered Message');

%% 7. FREQUENCY SPECTRUM

N = length(AM_signal);

Y = fft(AM_signal);

P2 = abs(Y/N);

P1 = P2(1:floor(N/2)+1);

P1(2:end-1) = 2*P1(2:end-1);

f_axis = fs*(0:floor(N/2))/N;

figure;

plot(f_axis,P1,'LineWidth',1.5);

grid on;

title('AM Frequency Spectrum');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

xlim([0 2000]);

%% 8. MODULATION INDEX ANALYSIS

fprintf('\n===== MODULATION ANALYSIS =====\n');

fprintf('Modulation Index = %.2f\n',mu);

if mu < 1

    fprintf('Condition: Under Modulation\n');

elseif mu == 1

    fprintf('Condition: 100%% Modulation\n');

else

    fprintf('Condition: Over Modulation\n');

end

%% 9. FINAL RESULTS

fprintf('\n===== SIMULATION COMPLETED =====\n');

fprintf('Message Frequency = %.2f Hz\n',fm);

fprintf('Carrier Frequency = %.2f Hz\n',fc);

fprintf('Modulation Index = %.2f\n',mu);

fprintf('Lower Sideband = %.2f Hz\n',fc-fm);

fprintf('Upper Sideband = %.2f Hz\n',fc+fm);

fprintf('Bandwidth = %.2f Hz\n',2*fm);

fprintf('\nAM Simulation Finished Successfully!\n');