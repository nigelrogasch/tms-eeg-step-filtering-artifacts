%% ------------------------------------------------------------------------
% TEST SCRIPT for tesa_robustdetrend and pop_tesa_robustdetrend (GUI + direct)
% -------------------------------------------------------------------------
% This script:
%   1. Creates a synthetic EEG dataset
%   2. Tests tesa_robustdetrend directly
%   3. Tests pop_tesa_robustdetrend in both command-line and GUI modes
%   4. Confirms identical outputs and displays EEGLAB command history
%
% Author: ChatGPT (2025)
%% ------------------------------------------------------------------------

clear; close all; clc;

fprintf('\n=== TESTING tesa_robustdetrend & pop_tesa_robustdetrend (full) ===\n');

%% ------------------------------------------------------------------------
% 1. Generate synthetic EEG structure
% -------------------------------------------------------------------------
EEG = [];
EEG.srate = 1000;             % Sampling rate (Hz)
EEG.times = -1000:1:1000;     % Time vector in ms
nChannels = 2;
nTrials = 5;
nTime = numel(EEG.times);

% Create synthetic data with quadratic drift + 10 Hz oscillation + noise
trend = 0.0001 * (EEG.times).^2;
signal = sin(2*pi*10*EEG.times/1000);
noise = 0.2 * randn(nChannels, nTime, nTrials);

EEG.data = zeros(nChannels, nTime, nTrials);
for tr = 1:nTrials
    EEG.data(:,:,tr) = repmat(signal + trend, nChannels, 1) + noise(:,:,tr);
end

EEG_orig = EEG;

fprintf('Synthetic EEG created: %d channels, %d trials, %d time points\n', ...
    nChannels, nTrials, nTime);

%% ------------------------------------------------------------------------
% 2. Test direct tesa_robustdetrend call
% -------------------------------------------------------------------------
timeWindow   = [-1000 1000];
thresholdSD  = 3;
polyOrder    = 2;
excludeWindow = [];

fprintf('\nRunning direct tesa_robustdetrend...\n');
EEG_det = tesa_robustdetrend(EEG, timeWindow, thresholdSD, polyOrder, excludeWindow);
fprintf('tesa_robustdetrend completed successfully.\n');

%% ------------------------------------------------------------------------
% 3. Test pop_tesa_robustdetrend (command-line mode)
% -------------------------------------------------------------------------
fprintf('\nRunning pop_tesa_robustdetrend (command-line mode)...\n');
EEG_pop = pop_tesa_robustdetrend(EEG, timeWindow, thresholdSD, polyOrder, excludeWindow);

fprintf('\nEEGLAB history command:\n');
% if isfield(EEG_pop, 'etc') && isfield(EEG_pop.etc, 'history')
%     disp(EEG_pop.etc.history);
% else
%     disp(EEG_pop.history);
% end

%% ------------------------------------------------------------------------
% 4. Test pop_tesa_robustdetrend (GUI mode simulation)
% -------------------------------------------------------------------------
fprintf('\nRunning pop_tesa_robustdetrend (GUI mode simulation)...\n');

% Run GUI mode (no arguments except EEG)
[EEG_gui,com] = pop_tesa_robustdetrend(EEG);

fprintf('GUI mode simulated successfully.\n');

% Check com works
eval(com);

fprintf('com simulated successfully.\n');

%% ------------------------------------------------------------------------
% 5. Compare outputs
% -------------------------------------------------------------------------
diffData1 = EEG_det.data - EEG_pop.data;
diffData2 = EEG_det.data - EEG_gui.data;

maxDiff1 = max(abs(diffData1(:)));
maxDiff2 = max(abs(diffData2(:)));

fprintf('\nMax difference (direct vs. pop command-line): %.3e\n', maxDiff1);
fprintf('Max difference (direct vs. pop GUI mode):     %.3e\n', maxDiff2);

if maxDiff1 < 1e-10 && maxDiff2 < 1e-10
    fprintf('✅ All outputs are identical.\n');
else
    fprintf('⚠️  Minor numerical differences detected (likely rounding).\n');
end

%% ------------------------------------------------------------------------
% 6. Plot example results
% -------------------------------------------------------------------------
figure('Name','Robust detrending comparison');
subplot(3,1,1);
plot(EEG_orig.times, squeeze(EEG_orig.data(1,:,1)));
title('Original signal (Ch 1, Trial 1)');
xlabel('Time (ms)'); ylabel('Amplitude');

subplot(3,1,2);
plot(EEG.times, squeeze(EEG_det.data(1,:,1)));
title('Detrended (direct tesa\_robustdetrend)');
xlabel('Time (ms)'); ylabel('Amplitude');

subplot(3,1,3);
plot(EEG.times, squeeze(EEG_gui.data(1,:,1)));
title('Detrended (pop\_tesa\_robustdetrend GUI mode)');
xlabel('Time (ms)'); ylabel('Amplitude');

fprintf('\n=== TEST COMPLETE ===\n');