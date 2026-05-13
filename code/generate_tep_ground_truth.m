% Code for generating the ground truth TEP

%% Reset

clear; close all; clc;

% Load paths
load('pathInfo.mat');

%% Generate the epoch with a flat line

% General settings
fs = 1000;           % Sampling frequency in Hz

% Epoch timing
preTime = -1;         % Start of epoch (relative to 0)
postTime = 1;         % End of epoch (relative to 0)

% Time vector for entire epoch
time = preTime : 1/fs : postTime;

% Initialize signal with zeros (flat line)
y = zeros(size(time));

%% Generate a beta oscillation

% Parameters
A = 5;               % Initial amplitude
f = 25;               % Frequency in Hz
tau = 0.1;           % Time constant of decay (seconds)
nCycles = 1.5;        % Number of cycles
phi_deg = 270;        % Starting phase in degrees

% Oscillation onset time
startTime = 0.01;     % Oscillation onset time (seconds)

% Convert phase to radians
phi = deg2rad(phi_deg);

% Derived duration based on number of cycles
t_end = nCycles / f;

% Time vector
t = 0:1/fs:t_end;

% Damped oscillation with starting phase
yosc = A * exp(-t / tau) .* cos(2 * pi * f * t + phi);

% Derived duration of oscillation
oscDuration = nCycles / f;

% Find indices for oscillation
[~,oscStartIdx] = min(abs(time - startTime));
oscEndTime = startTime + oscDuration;
[~,oscEndIdx] = min(abs(time - oscEndTime));

% Generate oscillation time vector
t_osc = time(oscStartIdx:oscEndIdx) - startTime; % Local time for oscillation

% Insert oscillation into flat signal
y(oscStartIdx:oscEndIdx) = y(oscStartIdx:oscEndIdx) + yosc;

% Plot
figure;
subplot(1,2,1)
plot(t, yosc, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Amplitude');
title(['Damped Oscillation with Phase Offset: ', num2str(phi_deg), '°']);
grid on;

%% Generate a theta oscillation

% Parameters
A = 3;               % Initial amplitude
f = 5;               % Frequency in Hz
tau = 0.1;           % Time constant of decay (seconds)
nCycles = 1.5;        % Number of cycles
phi_deg = 90;        % Starting phase in degrees

% Oscillation onset time
startTime = 0.06;     % Oscillation onset time (seconds)

% Convert phase to radians
phi = deg2rad(phi_deg);

% Derived duration based on number of cycles
t_end = nCycles / f;

% Time vector
t = 0:1/fs:t_end;

% Damped oscillation with starting phase
yosc = A * exp(-t / tau) .* cos(2 * pi * f * t + phi);

% Derived duration of oscillation
oscDuration = nCycles / f;

% Find indices for oscillation
[~,oscStartIdx] = min(abs(time - startTime));
oscEndTime = startTime + oscDuration;
[~,oscEndIdx] = min(abs(time - oscEndTime));

% Generate oscillation time vector
t_osc = time(oscStartIdx:oscEndIdx) - startTime; % Local time for oscillation

% Insert oscillation into flat signal
y(oscStartIdx:oscEndIdx) = y(oscStartIdx:oscEndIdx) + yosc;

% Plot
subplot(1,2,2)
plot(t, yosc, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Amplitude');
title(['Damped Oscillation with Phase Offset: ', num2str(phi_deg), '°']);
grid on;

%% Filter the data and then plot

% Plot
figure;
plot(time*1000, y, 'b-', 'LineWidth', 1.5); hold on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Simulated TEP');

% Generate a dummy EEG structure
EEG.srate = 1000;
EEG.times = time*1000;
EEG.pnts = length(EEG.times);
EEG.event.latency = 1001;
EEG.event.type = 'tms';
EEG.data = y;

% Run filter
EEG = pop_tesa_filtbutter( EEG, [], 40, 2, 'lowpass' );

% Plot filtered signal
plot(EEG.times, EEG.data, 'r-', 'LineWidth', 1.5);
set(gca,'xlim',[-100,300]);

% Save the ground truth
tep_gt = EEG.data;

save([pathData,'ground_truth_tep'],'tep_gt','time');
