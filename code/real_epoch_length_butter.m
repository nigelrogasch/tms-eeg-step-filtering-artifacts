% Check the impact of epoch length on filter artifacts

%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\';

% Time window for calculating RMSE
tp1 = 10;
tp2 = 499;

%% Butterfly plot

% Load real simulated TEP data
load('real_ground_truth_step_artifact.mat');

% Epoch lengths
epLength = 0.5:0.1:1.5;

for idx = 1:length(id)    

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
        EEGnew = pop_tesa_filtbutter( EEGnew, 1, [], 2, 'highpass' );
%         x_filt = tesa_highpass_edge_step(EEGnew.data, EEGnew.srate, 'RemoveStep', false, 'RemoveTrend', false,...
%             'FilterOrder',2,'PadLength',1);

%         EEGnew.data = x_filt;

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
        [~,t10] = min(abs(tp1-time_gt{idx}));
        [~,t300] = min(abs(tp2-time_gt{idx}));

        % Find time points 10 and 300
        [~,tb10] = min(abs(-tp1-time_gt{idx}));
        [~,tb300] = min(abs(-tp2-time_gt{idx}));

        % Time points
        [~,te10] = min(abs(tp1-EEGfiltTime{idx}{ex}));
        [~,te300] = min(abs(tp2-EEGfiltTime{idx}{ex}));

        % Time points
        [~,teb10] = min(abs(-tp1-EEGfiltTime{idx}{ex}));
        [~,teb300] = min(abs(-tp2-EEGfiltTime{idx}{ex}));

        % Root Mean Square Error
        rmse(:,ex,idx) = sqrt(mean((tep_gt{idx}(:,t10:t300) - EEGfilt{idx}{ex}(:,te10:te300)).^2,2));
        rmseBase(:,ex,idx) = sqrt(mean((tep_gt{idx}(:,tb300:tb10) - EEGfilt{idx}{ex}(:,teb300:teb10)).^2,2));
    end
end

% Save the data
save([pathData,'epoch_length_butter'],'rmse','rmseBase','epLength','id','EEGfilt','EEGfiltTime','tep_gt','time_gt');
