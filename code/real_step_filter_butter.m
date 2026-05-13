% Simulate step artifact and filter effects using robust demeaning to remove 
% the step and modified butterworth filter.

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Load simulated TEP
load('real_ground_truth_step_artifact.mat');

%% Generate TEPs with step artifacts

% Step levels
stepLevel = 0:2:10;

% Time 
time = eegdatastep.step0.P001.EEG.times;

% Time window for calculating RMSE
tp1 = 10;
tp2 = 300;

% Find time point 0
[~,t0] = min(abs(0-time));

% Find time points 10 and 300
[~,t10] = min(abs(tp1-time));
[~,t300] = min(abs(tp2-time));

%% Apply high-pass butterworth filter at 1 Hz (order = 2)


% % Settings
% epochTimespan = [EEG.xmin,EEG.xmax];
% bandpassFreqSpan = [1,80];
% filterPrePostExtrapolationDurations = [0,0];
% timeToExtend = 0.9;

% Filter over each simulated TEP
for idx = 1:length(id)
    for sx = 1:length(stepLevel)

        % Get the data
        EEGnew = eegdatastep.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG;

        % Filter the data
        EEGnew = pop_tesa_filtbutter( EEGnew, 1, [], 2, 'highpass' );

        % Save out
        eegfilt.(['step',num2str(stepLevel(sx))])(:,:,idx) = mean(EEGnew.data,3);
        eegfilttime.(['step',num2str(stepLevel(sx))]) = EEGnew.times;

        % Low-pass and notch
        EEGnew = pop_tesa_filtbutter( EEGnew, [], 80, 2, 'lowpass' );
        EEGnew = pop_tesa_filtbutter( EEGnew, 48, 50, 2, 'bandstop' );

        % Save that out
        eegfiltband.(['step',num2str(stepLevel(sx))])(:,:,idx) = mean(EEGnew.data,3);

    end
end

% Save ground truth as step 0
tep_gt = eegfilt.step0;
time_gt = time;

for idx = 1:length(id)
    for sx = 1:length(stepLevel)

        % Calculate the RMS error
        rmse(:,sx,idx) = sqrt(mean((tep_gt(:,t10:t300,idx) - eegfilt.(['step',num2str(stepLevel(sx))])(:,t10:t300,idx)).^2,2));

    end
end

% Summarise EEG raw data
for sx = 1:length(stepLevel)
    for idx = 1:length(id)
        eegraw.(['step',num2str(stepLevel(sx))])(:,:,idx) = mean(eegdatastep.(['step',num2str(stepLevel(sx))]).(id{idx}).EEG.data,3);
    end
end

%%

% Save the data
save([pathData,'real_filter_butter'],'rmse','stepLevel','eegraw','eegfilt','eegfiltband','time','tep_gt','time_gt');

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
