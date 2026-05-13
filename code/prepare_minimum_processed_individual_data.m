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
    EEG = pop_epoch( EEG, {  'S127'  }, [-1.6         1.6], 'epochinfo', 'yes');

    % Remove baseline
    EEG = pop_rmbase( EEG, [-500 -10] ,[]);

    % Remove and interpolate pulse artifact
    EEG = pop_tesa_removedata( EEG, [-2 10] );
    EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

    % Downsample the data
    EEG = pop_resample( EEG, 1000);

    % Save the data set
    fileName = [id{idx}, '_optimal_120_custom_processed'];
    filePath = ['R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\projects\2025-tms-eeg-step-artifact\data\minimum_processed_individual_data' ,filesep];
    EEG = pop_saveset( EEG, 'filename',fileName,'filepath',filePath);

end