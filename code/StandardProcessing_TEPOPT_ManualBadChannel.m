%% 
% Run standard processing on TEPOPT data
% Author: Nigel Rogasch

%%
clear; close all; clc;

% % --- Paths ---
% addpath('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0');
addpath('R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\FastICA_25');
eeglabPath = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0';
% eeglab; close all;

%% IDENTIFY PARTICIPANTS CONTAINING A FOLLOW UP FOLDER
DataIn = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data';
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_TEPOPT';

% P_ID = {'P001','P002','P003','P004','P006','P007','P009','P010',...
%         'P011','P012','P013','P014','P015','P016','P017'};
P_ID = {'P002','P013','P014'};

%% Loop over P_ID
% Define different settings
condition = {'_mri_120_custom'};

% Set counter
n = 1;

% Set the figures
f1 = figure('Name', 'TEP before ICA');
set(gcf,'position',[20,20,1200,1200]);
f2 = figure('Name', 'TEP cleaned');
set(gcf,'position',[20,20,1200,1200]);

for P_IDX = 1:length(P_ID)

    % Load Data
    filename = [P_ID{P_IDX}, condition{1}, '.vhdr'];
    dataDir  = fullfile(DataIn, P_ID{P_IDX});
    EEG = pop_loadbv(dataDir, filename);

    % --- Add electrode locations ---
    EEG = pop_chanedit(EEG, 'lookup', fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));

    % --- Remove unused channels (31 & 32) ---
    EEG = pop_select(EEG, 'rmchannel', [31 32]);

    % --- Save current channel structure for later interpolation ---
    EEG.chansAll = EEG.chanlocs;

    % --- Remove TMS pulse window (-2 to 10 ms), then interpolate it
    EEG = pop_tesa_removedata( EEG, [-2 10], [-500 -10], {'S127'} );
    EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

    % --- Downsample to 1000 Hz ---
    EEG = pop_resample(EEG, 1000);

    % --- AUTO bad-channel removal
    EEG = pop_clean_rawdata(EEG,'FlatlineCriterion',4, 'ChannelCriterion','off', 'LineNoiseCriterion','off', 'Highpass','off', 'BurstCriterion','off', 'WindowCriterion','off', 'BurstRejection','off', 'Distance','Euclidian');

    % --- Record bad channels
    origChan = {EEG.chansAll.labels};
    newChan = {EEG.chanlocs.labels};
    LIA = ismember(origChan,newChan);
    EEG.badChan = origChan(~LIA);

    % --- Epoch (event 'S127', -1 to 1 s) ---
    EEG = pop_epoch(EEG, {'S127'}, [-1 1], 'newname', 'Raw epochs', 'epochinfo', 'yes');

    % --- Baseline remove (-500 to -10 ms) ---
    EEG = pop_rmbase(EEG, [-500 -10], []);

    % --- AUTO bad-trial rejection (joint probability)
    EEG = pop_jointprob(EEG, 1, 1:EEG.nbchan, 3, 3, 0, 0);

    % Find indices of bad trials
    EEG.badTr = find(EEG.reject.rejjp == 1);

    % Record bad trials before removal
    if ~isempty(EEG.badTr)
        EEG.badTrList = EEG.badTr;  % save a copy into a dedicated field
        EEG.badTrCount = numel(EEG.badTr); % also store number of bad trials

        % Remove bad trials from the data
        EEG = pop_rejepoch(EEG, EEG.badTr, 0);
    else
        EEG.badTrList = [];
        EEG.badTrCount = 0;
    end

    % Interpolate missing channels
    EEG = pop_interp(EEG, EEG.chansAll, 'spherical');

    % Rereference to average
    EEG = pop_reref( EEG, []);

    % Manual channel check and removal
    EEG.badChans = EEG.badChan;
    EEG = pop_tesa_interactivechanreject(EEG);
    EEG.badChan = EEG.badChans;

    % --- Save point one
    savename_1 = [P_ID{P_IDX}, '_Savepoint1_standard.set'];
    EEG = pop_saveset(EEG, 'filename', savename_1, 'filepath', DataOut);
    
    % Plot
    figure(f1)
    subplot(4,4,n)
    plot(EEG.times,mean(EEG.data,3),'k');
    set(gca,'box','off','tickdir','out');
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(sprintf('%s before ICA\n',P_ID{P_IDX}));

    % --- FastICA #1: TMS-muscle ---
    %Replace pulse artefacts with 0s
    EEG = pop_tesa_removedata(EEG, [-2 10]);
    EEG = pop_select(EEG, 'nochannel', EEG.badChan);

    % ICA
    EEG = pop_tesa_fastica(EEG, 'approach','symm','g','tanh','stabilization','off');

    % Automatically select and remove TMS-evoked muscle
    EEG = pop_tesa_compselect(EEG, 'compCheck','off','remove','on','saveWeights','off','figSize','medium', 'plotTimeX',[-200 500],'plotFreqX',[1 100],'freqScale','log',...
        'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off',...
        'blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off', ...
        'move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off', ...
        'muscle','off','muscleThresh',-0.31,'muscleFreqIn',[7 70],'muscleFreqEx',[48 52],'muscleFeedback','off',...
        'elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off');

    % Extend removal, interpolate pulse artefact and channels
    EEG = pop_tesa_removedata(EEG, [-2 10]);
    EEG = pop_tesa_interpdata(EEG, 'cubic', [5 5]);
    EEG = pop_interp(EEG, EEG.chansAll, 'spherical');

    % --- Save point 2
    savename_2 = [P_ID{P_IDX}, '_Savepoint2_standard.set'];
    EEG = pop_saveset(EEG, 'filename', savename_2, 'filepath', DataOut);

    % Apply Filters
    EEG = pop_tesa_filtbutter(EEG, 1, 80, 2, 'bandpass');
    EEG = pop_tesa_filtbutter(EEG, 48, 52, 2, 'bandstop');

    % Remove missing data
    EEG = pop_tesa_removedata(EEG, [-2 10]);
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
    savename_3 = [P_ID{P_IDX}, '_Savepoint3_standard.set'];
    EEG = pop_saveset(EEG, 'filename', savename_3, 'filepath', DataOut);

    % Plot
    figure(f2)
    subplot(4,4,n)
    plot(EEG.times,mean(EEG.data,3),'k');
    set(gca,'box','off','tickdir','out');
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(sprintf('%s cleaned\n',P_ID{P_IDX}));

    % Advance counter
    n = n+1;

end