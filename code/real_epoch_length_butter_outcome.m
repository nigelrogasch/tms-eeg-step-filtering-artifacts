% Check the impact of epoch length on filter artifacts - evaluate outcomes

%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Merrick_temp\TMSEEG_DS\analysis\line_offset_check\TMSEEG_senstim\';

%% Load individual

% % Individual to plot
% id = 'P010';
% 
% % Load the data
% fileName = [id, '_optimal_120_custom_no_artefact_removed.set'];
% EEG = pop_loadset('filename',fileName,'filepath',pathDataInd);

%% Plot the edge error for different epoch lengths

% % Find the channel of interest
% chan = 'F1';
% labels = {EEG.chanlocs.labels}';
% chani = find(strcmp(labels,chan));
chani = 1;

% Load data
load('epoch_length_butter.mat');

% Mean rmse
errMean = mean(rmse(chani,:,:),3);
errSem = std(rmse(chani,:,:), [], 3) / sqrt(size(rmse,3));

% Collate data for TEP plot
for idx = 1:length(id)
    tep_data.butter(idx,:) = EEGfilt{idx}{1};
end

fig = figure('color','w');

subplot(1,2,1)
% Shaded area
fill([epLength*1000, fliplr(epLength*1000)], ...
     [errMean - errSem, fliplr(errMean + errSem)], ...
     'b', 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

% Mean line
plot(epLength*1000, errMean, 'b', 'LineWidth', 1.5);
set(gca,'xlim',[500,1500],'tickdir','out','box','off');
xlabel('Epoch length (ms)');
ylabel('Root mean square error (\muV)');

%% Load data 
load('epoch_length_butter_mirror.mat');

% Mean rmse
errMean = mean(rmse(chani,:,:),3);
errSem = std(rmse(chani,:,:), [], 3) / sqrt(size(rmse,3));

% Collate data for TEP plot
for idx = 1:length(id)
    tep_data.mirror(idx,:) = EEGfilt{idx}{1};
end

% Shaded area
fill([epLength*1000, fliplr(epLength*1000)], ...
     [errMean - errSem, fliplr(errMean + errSem)], ...
     'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% Mean line
plot(epLength*1000, errMean, 'r', 'LineWidth', 1.5);
set(gca,'xlim',[500,1500],'tickdir','out','box','off');
xlabel('Epoch length (ms)');
ylabel('Root mean square error (\muV)');

%% TEP plot

subplot(1,2,2)

% Time
time = EEGfiltTime{1}{1};

% First data set
data = tep_data.butter;
errMean = mean(data,1);
errSem = std(data, [], 1) / sqrt(size(data,1));

% Shaded area
fill([time, fliplr(time)], ...
     [errMean - errSem, fliplr(errMean + errSem)], ...
     'b', 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

% Mean line
plot(time, errMean, 'b', 'LineWidth', 1.5);

% Second data set
data = tep_data.mirror;
errMean = mean(data,1);
errSem = std(data, [], 1) / sqrt(size(data,1));

% Shaded area
fill([time, fliplr(time)], ...
     [errMean - errSem, fliplr(errMean + errSem)], ...
     'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% Mean line
plot(time, errMean, 'r', 'LineWidth', 1.5);

% Plot 0 line
plot([-500,500],[0,0],'k--');

% Settings
set(gca,'xlim',[-500,500],'tickdir','out','box','off');
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
