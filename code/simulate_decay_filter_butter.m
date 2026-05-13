% Evaluate filter on discharge artifact

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Load the absolute ground truth
tep_gt_abs = load('ground_truth_tep.mat');

%%

% Parameters
fs = 1000;          % sampling frequency (Hz)
tmax = 0.5;         % duration (s)
A = 0.005;             % amplitude (microvolts)
t0 = 0.0001;          % offset to avoid singularity at t=0 (s)
alpha = 2;          % power-law exponent (2nd order)

% Time vector
t = 0:1/fs:tmax;

% Power law decay artifact
artifact = A ./ ((t + t0).^alpha);

% Optionally add polarity (positive/negative discharge)
% artifact = artifact .* sign(randn);

% % Plot
% figure;
% plot(t*1000, artifact, 'LineWidth', 2);
% xlabel('Time (ms)');
% ylabel('Amplitude (\muV)');
% title(sprintf('TMS-EEG Artifact (Power-law decay, \\alpha = %.1f)', alpha));
% set(gca,'xlim',[0,100]);
% grid on;

%% Add artifact to ground truth

% Discharge artifact
dischargeArt = tep_gt_abs.tep_gt;
time = tep_gt_abs.time;

% Find the timepoints
[~,tp1] = min(abs(t(1) - time));
[~,tp2] = min(abs(t(end) - time));

% Add the artifact
dischargeArt(tp1:tp2) = dischargeArt(tp1:tp2) + artifact;

% Plot the outcomes
fig = figure('color','w');
plot(time,dischargeArt,'k'); hold on;
plot(time,tep_gt_abs.tep_gt,'r');
set(gca,'YLim',[-50,50]);

% Plot the outcomes
fig = figure('color','w');
plot(time,dischargeArt,'k'); hold on;
plot(time,tep_gt_abs.tep_gt,'r');
set(gca,'YLim',[-20,20],'xlim',[-0.3,0.3]);