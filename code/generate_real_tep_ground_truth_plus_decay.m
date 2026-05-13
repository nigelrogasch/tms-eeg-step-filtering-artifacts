% Simulate step artifact and filter effects using robust demeaning to remove 
% the step and modified butterworth filter.

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Load simulated TEP
load("ground_truth_tep.mat");
tep_gt_abs = load('ground_truth_tep.mat');

% Load in the data
% Individuals
id = {'P001','P002','P003','P004','P006','P007','P009','P010','P011','P012','P013','P014','P015','P016','P017'};
% id = {'P010'};


for idx = 1:length(id)

    % Load the data
    fileName = [id{idx}, '_optimal_120_custom_processed_offset.set'];
    filePath = '\\uofa\resources\Low_Cost_Storage\\healthsciences\\SPRH\\NeuroPAD\\projects\\2025-tms-eeg-step-artifact\\data\\minimum_processed_individual_data\\';
    EEG = pop_loadset('filename',fileName,'filepath',filePath);
    eegdata.(id{idx}).EEG = pop_select( EEG, 'channel',{'F1'});

end

%% Generate TEPs with step artifacts

% Step levels
stepLevel = 0:2:10;

% Generate decay artifact
% Parameters
fs = 1000;          % sampling frequency (Hz)
tmax = 0.5;         % duration (s)
A = 0.005;             % amplitude (microvolts)
t0 = 0.0001;          % offset to avoid singularity at t=0 (s)
alpha = 2;          % power-law exponent (2nd order)

% Time vector
t = 0:1/fs:tmax;

% Power law decay artifact
artifact = A ./ ((t + t0).^alpha);

% Add artifact to ground truth

% Discharge artifact
dischargeArt = tep_gt_abs.tep_gt;
time = tep_gt_abs.time;

% Find the timepoints
[~,tp1] = min(abs(t(1) - time));
[~,tp2] = min(abs(t(end) - time));

% Add the artifact
dischargeArt(tp1:tp2) = dischargeArt(tp1:tp2) + artifact;
tep_gt = dischargeArt;

% Add zeros before and after ground truth to match data
preTimes = -1.5:0.001:-1.001;
postTimes = 1.001:0.001:1.499;
preZeros = zeros(1,length(preTimes));
postZeros = zeros(1,length(postTimes));
time = [preTimes,time,postTimes];
tep_gt = [preZeros,tep_gt,postZeros];

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

    for idx = 1:length(id)
        dataTemp = [];
        dataTemp = eegdata.(id{idx}).EEG.data;
        for chanx = 1:size(dataTemp,1)
            for tx = 1:size(dataTemp,3)

                % Add the artifact to the data
                dataTemp(chanx,:,tx) = dataTemp(chanx,:,tx)+stepData(sx,:);

            end
        end
        eegdatadecay.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG = eegdata.(id{idx}).EEG;
        eegdatadecay.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG.data = dataTemp;

        % Get the data
        EEGnew = eegdatadecay.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG;

        % Remove artifact
        EEGnew = pop_tesa_removedata( EEGnew, [-2 10] );

        % Interpolate artifact
        EEGnew = pop_tesa_interpdata( EEGnew, 'cubic', [1 1] );

        % Store the data
        eegdatadecay.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG.data = EEGnew.data;

    end

end

% stepLevel0 = 0;
% 
% % Filter over each simulated TEP
% for idx = 1:length(id)
%     for sx = 1:length(stepLevel0)
% 
%         % Get the data
%         EEGnew = eegdatadecay.(['step',num2str(stepLevel0(sx))]).(id{idx}).EEG;
% 
%         % Filter the data
%         EEGnew = pop_tesa_filtbutter( EEGnew, 1, [], 2, 'highpass' );
% 
%         % Save out
%         eegfilt.(['step',num2str(stepLevel0(sx))])(:,:,idx) = mean(EEGnew.data,3);
%         eegfilttime.(['step',num2str(stepLevel0(sx))]) = EEGnew.times;
% 
%         % Save ground truth (filtered signal with no step)
%         if stepLevel0(sx) == 0
%             tep_gt0{idx} = eegfilt.(['step',num2str(stepLevel0(sx))])(:,:,idx);
%         end
% 
%     end
% end

% Save the data
save([pathData,'real_ground_truth_decay_artifact'],'eegdatadecay','tep_gt','time','id');

%%
% Plot the results


% % Plot the outcomes
% fig = figure('color','w');
% subplot(1,3,1)
% for sx = 1:length(stepLevel)
%     plot(time,mean(eegraw.(['step',num2str(stepLevel(sx))])(31,:,:),3)); hold on;
% end
% 
% subplot(1,3,2)
% for sx = 1:length(stepLevel)
%     plot(time,mean(eegfilt.(['step',num2str(stepLevel(sx))])(31,:,:),3)); hold on;
% end
% 
% subplot(1,3,3)
% for sx = 1:length(stepLevel)
%     plot(time,mean(eegfiltband.(['step',num2str(stepLevel(sx))])(31,:,:),3)); hold on;
% end
% 
% %%
% 
% % Plot the individuals
% fig2 = figure('color','w');
% for idx = 1:length(id)
%     subplot(3,5,idx)
%     for sx = 1:length(stepLevel)
%         plot(time,eegraw.(['step',num2str(stepLevel(sx))])(32,:,idx)); hold on;
%     end
% end
% 
% fig2 = figure('color','w');
% for idx = 1:length(id)
%     subplot(3,5,idx)
%     for sx = 1:length(stepLevel)
%         plot(time,eegfilt.(['step',num2str(stepLevel(sx))])(32,:,idx)); hold on;
%     end
% end
% 
% %% RMSE check
% 
% for idx = 1:length(id)
%     for sx = 1:length(stepLevel)
%         for chanx = 1:size(tep_gt0{1},1)
% 
%                 rmsecheck(chanx,sx,idx) = sqrt(mean((tep_gt0{idx}(chanx,t10:t300) - eegfilt.(['step',num2str(stepLevel(sx))])(chanx,t10:t300,idx)).^2,2));
%         end
%     end
% end
% 
% subplot(1,5,2)
% plot(time,stepDataInterp);
% 
% subplot(1,5,3)
% plot(time,stepDataDemeaned);
% 
% subplot(1,5,4)
% plot(time,stepDataFilt); hold on;
% plot(time,tep_gt,'r','lineWidth',1.5);
% 
% % Plot the RMSE
% subplot(1,5,5)
% plot(rmse);
