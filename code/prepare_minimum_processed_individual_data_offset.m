% Perform minimal processing pipeline on data

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
    fileName = [id{idx}, '_optimal_120_custom.vhdr'];
    filePath = [pathDataInd,id{idx} ,filesep];
    EEG = pop_loadbv(filePath, fileName);

    % Add electrode locations
    eeglabPath = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0\';
    EEG = pop_chanedit(EEG, 'lookup',fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));

    % Remove unused channels
    EEG = pop_select( EEG, 'rmchannel',{'31','32'});

    % Epoch the data with wide epoch
    EEG = pop_epoch( EEG, {  'S127'  }, [-3.5         1], 'epochinfo', 'yes');

    % Remove the later time points and shift the time range
    % Find time points 10 and 300
    [~,t1] = min(abs(-500-EEG.times));
    [~,t2] = min(abs(EEG.xmax*1000-EEG.times));
    EEG.data(:,t1:t2,:) = [];
    EEG.times = -1500:0.2:1499.8;
    EEG.xmin = EEG.times(1)/1000;
    EEG.xmax = EEG.times(end)/1000;
    EEG.pnts = length(EEG.times);
    EEG.event = [];
    EEG.urevent = [];

    % Loop to create 
    timeAll = [];
    for tx = 1:size(EEG.data,3)
        timeAll = [timeAll,EEG.times];
    end
    
    % Find all of the 0s points
    timeInd = 1:length(timeAll);
    zeroPoints = timeInd(timeAll < 0.01 & timeAll > -0.001);

    % Create dummy event structure
    for tx = 1:length(zeroPoints)
        EEG.event(tx).latency = zeroPoints(tx);
        EEG.event(tx).type = 'S127';
        EEG.event(tx).epoch = tx;
    end

    % Remove baseline
    EEG = pop_rmbase( EEG, [-500 -10] ,[]);

    % Remove and interpolate pulse artifact
    EEG = pop_tesa_removedata( EEG, [-2 10] );
    EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

    % Downsample the data
    EEG = pop_resample( EEG, 1000);

    % Save the data set
    fileName = [id{idx}, '_optimal_120_custom_processed_offset'];
    filePath = ['R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\projects\2025-tms-eeg-step-artifact\data\minimum_processed_individual_data' ,filesep];
    EEG = pop_saveset( EEG, 'filename',fileName,'filepath',filePath);

end