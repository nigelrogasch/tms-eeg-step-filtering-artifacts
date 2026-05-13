% Check the impact of epoch length on filter artifacts

%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\';

%% Butterfly plot

% Individual to plot
id = {'P001','P002','P003','P004','P006','P007','P009','P010','P011','P012','P013','P014','P015','P016','P017'};

for idx = 1:length(id)
    % Load the data
    fileName = [id{idx}, '_optimal_120_custom_processed.set'];
    filePath = 'R:\\Low_Cost_Storage\\healthsciences\\SPRH\\NeuroPAD\\projects\\2025-tms-eeg-step-artifact\\data\\minimum_processed_individual_data\\';
    EEG = pop_loadset('filename',fileName,'filepath',filePath);

    % Filter the data
    epochTimespan = [EEG.xmin,EEG.xmax];
    bandpassFreqSpan = [1,80];
    filterPrePostExtrapolationDurations = [0,0];
    timeToExtend = 0.5;

    artifactTimespan = EEG.tmscut(1).cutTimesTMS * 0.001;
    EEGgt = tesa_modifiedbandpassfilter(EEG,...
        'piecewiseTimeToExtend', timeToExtend,...
        'lowCutoff', bandpassFreqSpan(1),...
        'artifactTimespan', artifactTimespan*3,...
        'prePostExtrapolationDurations', filterPrePostExtrapolationDurations,...
        'doDebug',false);

%     EEGgt = pop_tesa_filtbutter( EEG, 1, [], 2, 'highpass' );

    % Find the channel of interest
    chan = 'F1';
    labels = {EEGgt.chanlocs.labels}';
    chani = find(strcmp(labels,chan));

    % Extract ground truth
    % tep_gt = mean(EEGgt.data(chani,:,:),3);
    tep_gt = mean(EEGgt.data,3);

    % Find time points 10 and 300
    [~,t10] = min(abs(10-EEG.times));
    [~,t500] = min(abs(499-EEG.times));

    % Find time points 10 and 300
    [~,tb10] = min(abs(-10-EEG.times));
    [~,tb500] = min(abs(-500-EEG.times));

    % Epoch lengths
    epLength = 0.5:0.1:1.5;

    for ex = 1:length(epLength)

        % Epoch
        EEGnew = pop_epoch( EEG, {  'S127'  }, [-epLength(ex)         epLength(ex)], 'epochinfo', 'yes');

        % Filter the data
        epochTimespan = [EEGnew.xmin,EEGnew.xmax];
        bandpassFreqSpan = [1,80];
        filterPrePostExtrapolationDurations = [1.6-epLength(ex),1.6-epLength(ex)];
        filterPrePostExtrapolationDurations = [0.1,0.1];
        timeToExtend = 0.5;

        artifactTimespan = EEGnew.tmscut(1).cutTimesTMS * 0.001;
        EEGnew = tesa_modifiedbandpassfilter(EEGnew,...
            'piecewiseTimeToExtend', timeToExtend,...
            'lowCutoff', bandpassFreqSpan(1),...
            'artifactTimespan', artifactTimespan*3,...
            'prePostExtrapolationDurations', filterPrePostExtrapolationDurations,...
            'doDebug',false);

%         EEGnew = pop_tesa_filtbutter( EEGnew, 1, [], 2, 'highpass' );

        % Epoched data
        %     EEGfilt{ex} = mean(EEGnew.data(chani,:,:),3);
        EEGfilt{ex} = mean(EEGnew.data,3);
        EEGfiltTime{ex} = EEGnew.times;

        % Time points
        [~,te10] = min(abs(10-EEGnew.times));
        [~,te500] = min(abs(499-EEGnew.times));

        % Time points
        [~,teb10] = min(abs(-10-EEGnew.times));
        [~,teb500] = min(abs(-500-EEGnew.times));

        % Root Mean Square Error
        rmse(:,ex,idx) = sqrt(mean((tep_gt(:,t10:t500) - EEGfilt{ex}(:,te10:te500)).^2,2));
        rmseBase(:,ex,idx) = sqrt(mean((tep_gt(:,tb500:tb10) - EEGfilt{ex}(:,teb500:teb10)).^2,2));

    end
end

% Save the data
save([pathData,'epoch_length_butter_modified'],'rmse','rmseBase','epLength','id');

% % Plot the outcomes
% fig = figure('color','w');
% plot(EEG.times,tep_gt,'k'); hold on;
% for ex = 1:length(epLength)
%     plot(EEGfiltTime{chani,ex},EEGfilt{chani,ex});
% end