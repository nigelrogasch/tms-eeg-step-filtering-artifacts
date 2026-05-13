% Simulate step artifact and filter effects using modified butterworth filter

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

for sx = 1:length(stepLevel)

    stepDataTmp = tep_gt;

    % Add step to data beginning at 0 
    step = ones(1,length(stepDataTmp(t0:end)))*stepLevel(sx);
    stepDataTmp(t0:end) = tep_gt(t0:end)+step;
    stepData(sx,:) = stepDataTmp;

end

fig = figure;
subplot(1,3,1)
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
timeToExtend = [0.5:0.1:1];

% Filter over each simulated TEP
for sx = 1:length(stepLevel)
    for fx = 1:length(timeToExtend)

        % Input data
        EEG.data = stepData(sx,:);

        % Remove artifact
        EEG = pop_tesa_removedata( EEG, [-2 12] );

        % Interpolate artifact
        EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

        % Run filter
        artifactTimespan = EEG.tmscut(1).cutTimesTMS * 0.001;
        EEG = tesa_modifiedbandpassfilter(EEG,...
        	'piecewiseTimeToExtend', timeToExtend(fx),...
        	'lowCutoff', bandpassFreqSpan(1),...
        	'artifactTimespan', artifactTimespan*3,...
        	'prePostExtrapolationDurations', filterPrePostExtrapolationDurations,...
            'doDebug',true);

        % Save out
        stepDataFilt(sx,fx,:) = EEG.data;

        % Calculat the RMS error
        rmseAll(sx,fx) = sqrt(mean((squeeze(tep_gt(t10:t300)) - squeeze(stepDataFilt(sx,fx,t10:t300))').^2));
    end
end

% Plot the results
subplot(1,3,2)
plot(time,squeeze(stepDataFilt(:,5,:))); hold on;
plot(time,tep_gt,'r','lineWidth',1.5);

% Plot the RMSE
subplot(1,3,3)
imagesc(rmseAll);

% Find the best filter order
outcome = sum(rmseAll);

% Best for baseline = 0.9;
% Extract this.
rmse = rmseAll(:,5)';

% Save the data
save([pathData,'filter_butter_modified'],'rmse','stepLevel');