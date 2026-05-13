%% 
% Finalise standard processing on AC-DC data
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
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_ACDC';

P_ID = {'P002','P004','P012','P014'};

%% Loop over P_ID
% Define different settings
condition = {'_mri_120_custom'};
pulse_shape = {'_biphasic', '_monophasic'};
filter = {'_highpass','_DC'};

% Open a figure
fig1 = figure('color','w');
set(gcf,'position',[20,20,1200,1200]);

% Set counter
n = 1;

for P_IDX = 1:length(P_ID)
    
    for pulse_shapeX = 1:length(pulse_shape)
        
        for filterX = 1:length(filter)
            
            % Load Data
            filename = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_Savepoint1_short.set'];
            EEG = pop_loadset('filename',filename,'filepath',DataOut);

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
            EEG = pop_tesa_removedata(EEG, [-2 15]);
            EEG = pop_tesa_interpdata(EEG, 'cubic', [5 5]);
            EEG = pop_interp(EEG, EEG.chansAll, 'spherical');

            % --- Save point 2
            savename_2 = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_mid_short.set'];
            EEG = pop_saveset(EEG, 'filename', savename_2, 'filepath', DataOut);

            % Apply Filters
            EEG = pop_tesa_filtbutter(EEG, 1, 80, 2, 'bandpass');
            EEG = pop_tesa_filtbutter(EEG, 48, 52, 2, 'bandstop');

            % Remove missing data
            EEG = pop_tesa_removedata(EEG, [-2 15]);
            EEG = pop_select(EEG, 'nochannel', EEG.badChan);

            % --- FastICA #2: eye blinks/movement, ongoing muscle ---
            % ICA
            EEG = pop_tesa_fastica(EEG, 'approach','symm','g','tanh','stabilization','off');

            % Automatically select and remove TMS-evoked muscle
            EEG = pop_tesa_compselect(EEG, 'compCheck','off','remove','on','saveWeights','off','figSize','medium', 'plotTimeX',[-200 500],'plotFreqX',[1 100],'freqScale','log',...
                'tmsMuscle','off','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off',...
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
            savename_3 = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_cleanedStandard_short.set'];
            EEG = pop_saveset(EEG, 'filename', savename_3, 'filepath', DataOut);

            % Plot
            subplot(4,4,n)
            plot(EEG.times,mean(EEG.data,3),'k');
            set(gca,'box','off','tickdir','out');
            xlabel('Time (ms)');
            ylabel('Amplitude (\muV)');
            title(sprintf('%s %s %s\n',P_ID{P_IDX},pulse_shape{pulse_shapeX},filter{filterX}));
            
            % Advance counter
            n = n+1;

        end 
    end
end

