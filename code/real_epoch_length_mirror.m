% Check the impact of epoch length on filter artifacts

%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\';

%% Butterfly plot

% Load absolute ground truth
% load('ground_truth_tep.mat');
% time_gt = time;

% Load real simulated TEP data
load('real_ground_truth_step_artifact.mat');



% Epoch lengths
epLength = 0.5:0.1:1.5;

for idx = 1:length(id)
    
%     % Load the data
%     fileName = [id{idx}, '_optimal_120_custom.vhdr'];
%     filePath = [pathDataInd,id{idx} ,filesep];
%     EEG = pop_loadbv(filePath, fileName);
% 
%     % Add electrode locations
%     eeglabPath = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0\';
%     EEG = pop_chanedit(EEG, 'lookup',fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));
% 
%     % Remove unused channels
%     EEG = pop_select( EEG, 'rmchannel',{'31','32'});
% 
%     % Epoch the data with wide epoch
%     EEG = pop_epoch( EEG, {  'S127'  }, [-1.6         1.6], 'epochinfo', 'yes');
% 
%     % Remove baseline
%     EEG = pop_rmbase( EEG, [-500 -10] ,[]);
% 
%     % Remove and interpolate pulse artifact
%     EEG = pop_tesa_removedata( EEG, [-2 10] );
%     EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );
% 
%     % Downsample the data
%     EEG = pop_resample( EEG, 1000);
% 
%     % Filter the data
%     EEGgt = pop_tesa_filtbutter( EEG, 1, [], 2, 'highpass' );
% 
%     % Find the channel of interest
%     chan = 'F1';
%     labels = {EEGgt.chanlocs.labels}';
%     chani = find(strcmp(labels,chan));
% 
%     % Extract ground truth
%     % tep_gt = mean(EEGgt.data(chani,:,:),3);
%     tep_gt{idx} = mean(EEGgt.data,3);
% 
%     % Find time points 10 and 300
%     [~,t10] = min(abs(10-EEG.times));
%     [~,t300] = min(abs(300-EEG.times));
% 
%     % Find time points 10 and 300
%     [~,tb10] = min(abs(-10-EEG.times));
%     [~,tb300] = min(abs(-300-EEG.times));

    for ex = 1:length(epLength)
        
        % Extract data
        EEGnew = eegdatastep.step0.(id{idx}).EEG;

        % Epoch
        if epLength(ex) == 1.5
            EEGnew = pop_epoch( EEGnew, {  'S127'  }, [-epLength(ex)         1.499], 'epochinfo', 'yes');
        else
            EEGnew = pop_epoch( EEGnew, {  'S127'  }, [-epLength(ex)         epLength(ex)], 'epochinfo', 'yes');
        end

        % Filter the data
%         EEGnew = pop_tesa_filtbutter( EEGnew, 1, [], 2, 'highpass' );
        x_filt = tesa_highpass_edge_step(EEGnew.data, EEGnew.srate, 'RemoveStep', false, 'RemoveTrend', false,...
            'FilterOrder',2,'PadLength',1);

        EEGnew.data = x_filt;

        % Epoched data
        %     EEGfilt{ex} = mean(EEGnew.data(chani,:,:),3);
        EEGfilt{idx}{ex} = mean(EEGnew.data,3);
        EEGfiltTime{idx}{ex} = EEGnew.times;

    end
    
    % Save ground truth as the widest epoch
    tep_gt{idx} = EEGfilt{idx}{11};
    time_gt{idx} = EEGfiltTime{idx}{11};
end

for idx = 1:length(id)
    for ex = 1:length(epLength)

        % Find time points 10 and 300 for ground truth
        [~,t10] = min(abs(10-time_gt{idx}));
        [~,t300] = min(abs(499-time_gt{idx}));

        % Find time points 10 and 300
        [~,tb10] = min(abs(-10-time_gt{idx}));
        [~,tb300] = min(abs(-499-time_gt{idx}));

        % Time points
        [~,te10] = min(abs(10-EEGfiltTime{idx}{ex}));
        [~,te300] = min(abs(499-EEGfiltTime{idx}{ex}));

        % Time points
        [~,teb10] = min(abs(-10-EEGfiltTime{idx}{ex}));
        [~,teb300] = min(abs(-499-EEGfiltTime{idx}{ex}));

        % Root Mean Square Error
        rmse(:,ex,idx) = sqrt(mean((tep_gt{idx}(:,t10:t300) - EEGfilt{idx}{ex}(:,te10:te300)).^2,2));
        rmseBase(:,ex,idx) = sqrt(mean((tep_gt{idx}(:,tb300:tb10) - EEGfilt{idx}{ex}(:,teb300:teb10)).^2,2));
    end
end

% Save the data
save([pathData,'epoch_length_butter_mirror'],'rmse','rmseBase','epLength','id','EEGfilt','EEGfiltTime','tep_gt','time_gt');

% % Plot the outcomes
% fig = figure('color','w');

% fig = figure('color','w');
% plot(times_gt,tep_gt,'k'); hold on;
% for ex = 1:length(epLength)
%     plot(EEGfiltTime{ex},EEGfilt{ex});
% end