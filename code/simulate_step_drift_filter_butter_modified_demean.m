% Simulate step artifact and filter effects using robust demeaning to remove 
% the step and modified butterworth filter.

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Load simulated TEP
load("ground_truth_tep.mat");

%% Generate TEPs with step artifacts

% Step levels
stepLevel = 0:1:5;

% Find time point 0
[~,t0] = min(abs(0-time));

% Find time points 10 and 300
[~,t10] = min(abs(0.01-time));
[~,t300] = min(abs(0.3-time));

% Parameters
fs = 1000;                  % Sampling rate in Hz
t = -1:1/fs:1;              % Time vector from -1 to 1 seconds
drift_rate = -1e-6;          % Drift rate in V/s (1 µV/s = 1e-6 V/s)

% Create drift artifact (linear increase)
drift = drift_rate * t;     % Drift in Volts

% Convert to microvolts for display
drift_uV = drift * 1e6;

for sx = 1:length(stepLevel)

    stepDataTmp = tep_gt;

    % Add step to data beginning at 0 
    step = ones(1,length(stepDataTmp(t0:end)))*stepLevel(sx);
    stepDataTmp(t0:end) = tep_gt(t0:end)+step;
    stepData(sx,:) = stepDataTmp;

    % Add drift
    stepData(sx,:) = stepData(sx,:) + drift_uV;

    % Baseline correct (-1000 to 0)
    [~,t1] = min(abs(-1-time));
    [~,t2] = min(abs(0-time));
    stepData(sx,:) = stepData(sx,:) - mean(stepData(sx,t1:t2),2);

end

fig = figure;
subplot(1,5,1)
plot(time,stepData);

%% Apply high-pass butterworth filter at 1 Hz (order = 2)

% Generate a dummy EEG structure
EEG.srate = 1000;
EEG.times = time*1000;
EEG.pnts = length(EEG.times);
EEG.xmin = -1;
EEG.xmax = 1;
EEG.trials = 1;
EEG.event.latency = 1001;
EEG.event.type = 'tms';

% Settings
epochTimespan = [EEG.xmin,EEG.xmax];
bandpassFreqSpan = [1,80];
filterPrePostExtrapolationDurations = [0,0];
timeToExtend = 0.9;

% Filter over each simulated TEP
for sx = 1:length(stepLevel)

    % Input data
    EEG.data = stepData(sx,:);

    % Remove artifact
    EEG = pop_tesa_removedata( EEG, [-2 12] );

    % Interpolate artifact
    EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

    % Save interpolated data
    stepDataInterp(sx,:) = EEG.data;

    % Perform robust demean
    EEG = tesa_robustdemean(EEG,[12,1000],3);

    % Remove artifact
    EEG = pop_tesa_removedata( EEG, [-2 12] );

    % Interpolate artifact
    EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

    % Save demeaned data
    stepDataDemeaned(sx,:) = EEG.data;

    % Run filter
    artifactTimespan = EEG.tmscut(1).cutTimesTMS * 0.001;
    EEG = tesa_modifiedbandpassfilter(EEG,...
    	'piecewiseTimeToExtend', timeToExtend,...
    	'lowCutoff', bandpassFreqSpan(1),...
    	'artifactTimespan', artifactTimespan*3,...
    	'prePostExtrapolationDurations', filterPrePostExtrapolationDurations);

    % Save out
    stepDataFilt(sx,:) = EEG.data;

    % Calculat the RMS error
    rmse(sx) = sqrt(mean((tep_gt(t10:t300) - stepDataFilt(sx,t10:t300)).^2));

end

% Plot the results
figure(fig);

subplot(1,5,2)
plot(time,stepDataInterp);

subplot(1,5,3)
plot(time,stepDataDemeaned);

subplot(1,5,4)
plot(time,stepDataFilt); hold on;
plot(time,tep_gt,'r','lineWidth',1.5);

% Plot the RMSE
subplot(1,5,5)
plot(rmse);

% Save the data
save([pathData,'filter_step_drift_butter_modified_demean'],'rmse','stepLevel');
