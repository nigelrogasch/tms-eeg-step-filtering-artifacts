%% 
% Extracts the first 30 pulses and then runs the automated processing
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
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_AMPRANGE';

% %Extract PIDs AUTOMATED
% findID = {dir(fullfile(DataIn,'P???')).name};
% findID = findID(~startsWith(findID,'.'));
% folder_name = {'follow-up'};
% hasFU = cellfun(@(pid) any(cellfun(@(n) isfolder(fullfile(DataIn,pid,n)), folder_name)), findID);
% P_ID    = findID(hasFU);

P_ID = {'P012'};

%% Loop over P_ID
% Define different settings
condition = {'_mri_120_custom'};
pulse_shape = {'_biphasic', '_monophasic'};
filter = {'_lowres','_highres'};

% Open a figure
fig1 = figure('color','w');
set(gcf,'position',[20,20,1200,1200]);

% Set counter
n = 1;

for P_IDX = 1:length(P_ID)
    
    for pulse_shapeX = 1:length(pulse_shape)
        
        for filterX = 1:length(filter)
            
            % Load Data
            filename = [P_ID{P_IDX}, condition{1}, pulse_shape{pulse_shapeX},'_dc', filter{filterX}, '.vhdr'];
            dataDir  = fullfile(DataIn, P_ID{P_IDX}, 'follow-up2');
            EEG = pop_loadbv(dataDir, filename);
            
            % --- Add electrode locations ---
            EEG = pop_chanedit(EEG, 'lookup', fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));
            
            % --- Remove unused channels (31 & 32) ---
            EEG = pop_select(EEG, 'rmchannel', [31 32]);
            
            % --- Save current channel structure for later interpolation ---
            EEG.chansAll = EEG.chanlocs;

            % --- Shorten the data to the first 30 pulses ---
            num = 1;
            evLat = [];
            for eventx = 1:length(EEG.event)
                if strcmp(EEG.event(eventx).type,'S127')
                    evLat(num,1) = EEG.event(eventx).latency;
                    num = num +1;
                end
            end

            timeEnd = evLat(30)./5000 + 2;
            
            EEG = pop_select( EEG, 'time',[0 timeEnd] );

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
            
            % % --- Remove TMS pulse window (-2 to 10 ms), then interpolate it
            % EEG = pop_tesa_removedata(EEG, [-2 10]);
            % EEG = pop_tesa_interpdata(EEG, 'cubic', [1 1]);
            
            % % --- Downsample to 1000 Hz ---
            % EEG = pop_resample(EEG, 1000);
            
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

            % --- Save point one
            savename_1 = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_Savepoint1_short.set'];
            EEG = pop_saveset(EEG, 'filename', savename_1, 'filepath', DataOut);
            
            
            % --- FastICA #1: TMS-muscle, eye blinks and movements ---
            %Replace pulse artefacts with 0s
            EEG = pop_tesa_removedata(EEG, [-2 10]);
            EEG = pop_select(EEG, 'nochannel', EEG.badChan);

            % ICA
            EEG = pop_tesa_fastica(EEG, 'approach','symm','g','tanh','stabilization','off');

            % --- Save point two
            savename_2 = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_Savepoint2_short.set'];
            EEG = pop_saveset(EEG, 'filename', savename_2, 'filepath', DataOut);

            % Automatically select and remove TMS-evoked muscle
            EEG = pop_tesa_compselect(EEG, 'compCheck','off','remove','on','saveWeights','off','figSize','medium', 'plotTimeX',[-200 500],'plotFreqX',[1 100],'freqScale','log',...
                'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off',...
                'blink','on','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off', ...
                'move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off', ...
                'muscle','off','muscleThresh',-0.31,'muscleFreqIn',[7 70],'muscleFreqEx',[48 52],'muscleFeedback','off',...
                'elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off');

            % Interpolate missing channels
            EEG = pop_interp(EEG, EEG.chansAll, 'spherical');

            % --- Save point three
            savename_3 = [P_ID{P_IDX}, pulse_shape{pulse_shapeX}, filter{filterX}, '_Savepoint3_short.set'];
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



