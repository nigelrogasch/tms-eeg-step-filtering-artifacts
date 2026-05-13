%%
% Robust detrend and modified filter on TEPOPT data
% Author: Nigel Rogasch

%%
clear; close all; clc;

% % --- Paths ---
% addpath('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0');
addpath('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\FastICA_25');
% eeglabPath = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0';
% eeglab; close all;

%% IDENTIFY PARTICIPANTS CONTAINING A FOLLOW UP FOLDER
DataIn = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data';
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_TEPOPT';

P_ID = {'P001','P002','P003','P004','P006','P007','P009','P010',...
    'P011','P012','P013','P014','P015','P016','P017'};

%% Loop over P_ID
% Define different settings
condition = {'_mri_120_custom'};

% Open a figure
fig1 = figure('color','w');
set(gcf,'position',[20,20,1200,1200]);

% Set counter
n = 1;

for P_IDX = 1:length(P_ID)

    % Load Data
    filename = [P_ID{P_IDX}, '_Savepoint2_standard.set'];
    EEG = pop_loadset('filename',filename,'filepath',DataOut);

    % Detrend the data
    EEG = pop_tesa_robustdetrend(EEG, [-1000,-2], 3, 1);
    EEG = pop_tesa_robustdetrend(EEG, [11,999], 3, 1);

    % Modified high-pass filter
    EEG = pop_tesa_modifiedbandpassfilter( EEG, 'lowCutoff', 1, 'pieceWiseTimeToExtend', 0.9 );

    % Apply Filters
    EEG = pop_tesa_filtbutter(EEG, [], 80, 2, 'lowpass');
    EEG = pop_tesa_modifiedbandpassfilter( EEG, 'lowCutoff', 48, 'highCutoff', 52, 'pieceWiseTimeToExtend', 0.9, 'filtType', 'bandstop' );

    % Remove missing data
    EEG = pop_tesa_removedata( EEG, [-2 10], [-500 -10], {'S127'} );
    EEG = pop_select(EEG, 'nochannel', EEG.badChan);

    % --- FastICA #2: eye blinks/movement, ongoing muscle ---
    % ICA
    EEG = pop_tesa_fastica(EEG, 'approach','symm','g','tanh','stabilization','off');

    % Automatically select and remove TMS-evoked muscle
    EEG = pop_tesa_compselect(EEG, 'compCheck','off','remove','on','saveWeights','off','figSize','medium', 'plotTimeX',[-200 500],'plotFreqX',[1 100],'freqScale','log',...
        'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off',...
        'blink','on','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off', ...
        'move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off', ...
        'muscle','on','muscleThresh',-0.31,'muscleFreqIn',[7 70],'muscleFreqEx',[48 52],'muscleFeedback','off',...
        'elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off');

    % Interpolate missing data
    EEG = pop_tesa_interpdata(EEG, 'cubic', [5 5]);
    EEG = pop_interp(EEG, EEG.chansAll, 'spherical');

    % Rereference to average
    EEG = pop_reref( EEG, []);

    % --- Save point final
    savename_3 = [P_ID{P_IDX}, '_Savepoint3_modified_notch.set'];
    EEG = pop_saveset(EEG, 'filename', savename_3, 'filepath', DataOut);

    % Plot
    subplot(4,4,n)
    plot(EEG.times,mean(EEG.data,3),'k');
    set(gca,'box','off','tickdir','out');
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(sprintf('%s cleaned\n',P_ID{P_IDX}));

    % Advance counter
    n = n+1;

end
