%% ------------------------------------------------------------------------
% Test script for tesa_robustdemean and pop_tesa_robustdemean
% -------------------------------------------------------------------------
% This script:
%   1. Creates a simulated EEG dataset with slow drifts
%   2. Tests tesa_robustdemean directly
%   3. Tests pop_tesa_robustdemean programmatically (with inputs)
%   4. Allows manual GUI testing of pop_tesa_robustdemean
%   5. Checks that results and com outputs make sense
%
% To test the GUI manually:
%   - Run this script
%   - When prompted, uncomment the "manual GUI test" section
%   - Enter desired parameters in the dialog box
% -------------------------------------------------------------------------

clear; clc;
fprintf('--- Testing tesa_robustdemean and pop_tesa_robustdemean ---\n');

%% 1. Simulate EEG data
EEG = [];
EEG.nbchan = 4;                         % Number of channels
EEG.pnts   = 2001;                      % Number of time points
EEG.trials = 5;                         % Number of trials
EEG.srate  = 1000;                      % Sampling rate (Hz)
EEG.times  = linspace(-1000, 1000, EEG.pnts); % ms

% Simulate slow drift + noise
t = EEG.times / 1000; % convert ms → s
EEG.data = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
for ch = 1:EEG.nbchan
    for tr = 1:EEG.trials
        slowDrift = 50 * sin(0.5 * 2 * pi * t); % slow drift component
        noise     = randn(size(t)) * 5;         % white noise
        EEG.data(ch,:,tr) = slowDrift + noise + 10;
    end
end
fprintf('Simulated EEG data created: %d channels × %d points × %d trials.\n', ...
    EEG.nbchan, EEG.pnts, EEG.trials);

EEG_orig = EEG;

%% 2. Test tesa_robustdemean directly
timeWindow   = [-500 500];
thresholdSD  = 3;
excludeWindow = [];

fprintf('\nRunning tesa_robustdemean directly...\n');
EEG_out1 = tesa_robustdemean(EEG, timeWindow, thresholdSD, excludeWindow);
fprintf('Direct function call successful.\n');


%% 3. Test pop_tesa_robustdemean programmatically
fprintf('\nRunning pop_tesa_robustdemean (programmatic call)...\n');

[EEG_out2, com] = pop_tesa_robustdemean(EEG, timeWindow, thresholdSD, excludeWindow);

fprintf('pop_tesa_robustdemean executed successfully.\n');
fprintf('Generated command:\n%s\n', com);


%% 4. Optional: Test the GUI manually
% -------------------------------------------------------------------------
% Uncomment the following lines to test the GUI:
%
% fprintf('\n--- Manual GUI test ---\n');
% fprintf('When the dialog appears, enter e.g.:\n');
% fprintf('  Time window: [-500 500]\n');
% fprintf('  Threshold: 3\n');
% fprintf('  Exclude window: [-50 100]\n');
% fprintf('(Press OK to run)\n\n');
%
[EEG_gui, com_gui] = pop_tesa_robustdemean(EEG);
fprintf('Manual GUI call finished.\n');

eval(com_gui);
% fprintf('Generated command:\n%s\n', com_gui);
% -------------------------------------------------------------------------


%% 5. Check results
fprintf('\n--- Verifying outputs ---\n');

diff_direct = EEG_orig.data - EEG_out1.data;
diff_pop    = EEG_orig.data - EEG_out2.data;

fprintf('Mean absolute change (direct): %.4f µV\n', mean(abs(diff_direct(:))));
fprintf('Mean absolute change (pop):    %.4f µV\n', mean(abs(diff_pop(:))));

if isequal(size(EEG_out1.data), size(EEG_out2.data))
    fprintf('✅ Output dimensions match original EEG.\n');
else
    warning('❌ Output dimensions mismatch!');
end

if exist('com', 'var') && ischar(com)
    fprintf('✅ "com" output successfully generated.\n');
else
    warning('❌ "com" output not found or invalid.');
end

fprintf('\nAll tests completed.\n');

%% 6. Plot results

meanRaw  = mean(EEG_orig.data, 3);      % Average over trials
meanDemean = mean(EEG_out1.data, 3);
meanPop  = mean(EEG_out2.data, 3);

% Difference signals
diff_direct = meanRaw - meanDemean;
diff_pop    = meanRaw - meanPop;
chToPlot = 1; % Choose a channel to visualise
t = EEG.times;

figure('Name', 'tesa_robustdemean Visualisation', 'Position', [200 100 1200 700]);

subplot(3,1,1)
plot(t, meanRaw(chToPlot,:), 'k', 'LineWidth', 1.2); hold on;
xline(timeWindow(1), '--r'); xline(timeWindow(2), '--r');
if ~isempty(excludeWindow)
    xline(excludeWindow(1), ':b'); xline(excludeWindow(2), ':b');
end
title(sprintf('Raw EEG (Channel %d)', chToPlot));
ylabel('Amplitude (µV)');
grid on;

subplot(3,1,2)
plot(t, meanDemean(chToPlot,:), 'LineWidth', 1.2); hold on;
plot(t, meanPop(chToPlot,:), '--', 'LineWidth', 1.2);
xline(timeWindow(1), '--r'); xline(timeWindow(2), '--r');
if ~isempty(excludeWindow)
    xline(excludeWindow(1), ':b'); xline(excludeWindow(2), ':b');
end
title('After Robust Demean');
ylabel('Amplitude (µV)');
legend({'tesa\_robustdemean','pop\_tesa\_robustdemean'}, 'Location', 'best');
grid on;

subplot(3,1,3)
plot(t, diff_direct(chToPlot,:), 'b', 'LineWidth', 1.2); hold on;
plot(t, diff_pop(chToPlot,:), 'r--', 'LineWidth', 1.2);
xline(timeWindow(1), '--r'); xline(timeWindow(2), '--r');
if ~isempty(excludeWindow)
    xline(excludeWindow(1), ':b'); xline(excludeWindow(2), ':b');
end
title('Difference from Raw Signal');
xlabel('Time (ms)');
ylabel('Δ Amplitude (µV)');
legend({'Direct - Raw','Pop - Raw'}, 'Location', 'best');
grid on;

sgtitle('Robust Demeaning of Simulated EEG');

fprintf('\nPlots generated. Red dashed lines = timeWindow, blue dotted lines = excludeWindow.\n');
fprintf('Use these plots to confirm the expected baseline shift removal.\n');
