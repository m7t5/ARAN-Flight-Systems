%% SAMPLING MODEL
% Signal Sampling and Reconstruction
% MATLAB Simulation

clc;
clear;
close all;

%% 1. SIGNAL PARAMETERS

A = 1;                  % Signal Amplitude
fm = 10;                % Message Frequency (Hz)

fs = 100;               % Sampling Frequency (Hz)
fs_high = 10000;        % High Sampling Frequency

T = 1;                  % Simulation Duration

fprintf('===== SAMPLING PARAMETERS =====\n');

fprintf('Signal Frequency = %.2f Hz\n',fm);
fprintf('Sampling Frequency = %.2f Hz\n',fs);
fprintf('Nyquist Frequency = %.2f Hz\n',fs/2);

%% 2. ORIGINAL CONTINUOUS-TIME SIGNAL

t = 0:1/fs_high:T;

x = A*sin(2*pi*fm*t);

figure('Name','Original Signal');

plot(t,x,'LineWidth',1.5);

grid on;

title('Original Continuous-Time Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

%% 3. SAMPLING PROCESS

Ts = 1/fs;

n = 0:floor(T/Ts);

ts = n*Ts;

xs = A*sin(2*pi*fm*ts);

figure('Name','Sampled Signal');

stem(ts,xs,'filled');

grid on;

title('Sampled Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

%% 4. ORIGINAL AND SAMPLED SIGNAL

figure('Name','Original vs Sampled Signal');

plot(t,x,'b','LineWidth',1.5);

hold on;

stem(ts,xs,'r','filled');

grid on;

title('Original and Sampled Signal');

xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('Original Signal','Sampled Signal');

%% 5. SIGNAL RECONSTRUCTION

xr = interp1(ts,xs,t,'spline');

figure('Name','Signal Reconstruction');

plot(t,x,'b','LineWidth',1.5);

hold on;

plot(t,xr,'r--','LineWidth',1.5);

grid on;

title('Signal Reconstruction');

xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('Original Signal','Reconstructed Signal');

%% 6. ALIASING EFFECT

fs_low = 15;

Ts_low = 1/fs_low;

n_low = 0:floor(T/Ts_low);

ts_low = n_low*Ts_low;

xs_low = A*sin(2*pi*fm*ts_low);

figure('Name','Aliasing Effect');

plot(t,x,'b','LineWidth',1.5);

hold on;

stem(ts_low,xs_low,'r','filled');

grid on;

title('Aliasing Effect');

xlabel('Time (Seconds)');
ylabel('Amplitude');

legend('Original Signal','Undersampled Signal');

%% 7. FREQUENCY SPECTRUM

N = length(x);

Y = fft(x);

P2 = abs(Y/N);

P1 = P2(1:floor(N/2)+1);

P1(2:end-1) = 2*P1(2:end-1);

f = fs_high*(0:floor(N/2))/N;

figure('Name','Frequency Spectrum');

plot(f,P1,'LineWidth',1.5);

grid on;

title('Original Signal Frequency Spectrum');

xlabel('Frequency (Hz)');
ylabel('Magnitude');

xlim([0 100]);

%% 8. NYQUIST ANALYSIS

fprintf('\n===== NYQUIST ANALYSIS =====\n');

if fs >= 2*fm

    fprintf('Sampling Condition: Satisfied\n');

    fprintf('Sampling frequency is sufficient.\n');

else

    fprintf('Sampling Condition: Not Satisfied\n');

    fprintf('Aliasing may occur.\n');

end

%% 9. FINAL RESULTS

fprintf('\n===== SIMULATION COMPLETED =====\n');

fprintf('Signal Frequency = %.2f Hz\n',fm);

fprintf('Sampling Frequency = %.2f Hz\n',fs);

fprintf('Sampling Period = %.4f seconds\n',Ts);

fprintf('\nSampling Simulation Finished Successfully!\n');