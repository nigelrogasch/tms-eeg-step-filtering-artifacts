% Compare different filtering approaches

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Load the absolute ground truth
tep_gt_abs = load('ground_truth_tep.mat');

% Time window for calculating RMSE
tp1 = 10;
tp2 = 50;

%% Loop and plot RMSE

% Approach names
cleaningName = {'raw','butter','butter_modified_detrend'};
cleaningVar = {'Raw','Butter','DetrendButterMod'};

cmap = brewermap(8,'Set3');
cmap = cmap([1 2 3 4 8 6 7 5],:);

% Loop and save the rmse
for cx = 1:length(cleaningName)

    % Load the data
    load(['real_decay_filter_',cleaningName{cx},'.mat']);

    % Save the output
    rmseAll.(cleaningVar{cx}).rmse = rmse;
    rmseAll.(cleaningVar{cx}).stepLevel = stepLevel;

    % Data 
    dataAll.(cleaningVar{cx}) = eegfilt;

end

%%
% Find time point 0
[~,t0] = min(abs(0-time));

% Find time points 10 and 300
[~,t10] = min(abs(tp1-time));
[~,t300] = min(abs(tp2-time));

% Find time points 10 and 300
[~,tg10] = min(abs(tp1-tep_gt_abs.time*1000));
[~,tg300] = min(abs(tp2-tep_gt_abs.time*1000));

%%

fig2 = figure('color','w');
set(gcf,'position',[20,20,1200,1000]);

errMean = mean(dataAll.Raw.step0,3);
errSem = std(dataAll.Raw.step0, [], 3) / sqrt(size(dataAll.Raw.step0,3));
h1 = plot(time,errMean,'Color',cmap(1,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

errMean = mean(dataAll.Butter.step0,3);
errSem = std(dataAll.Butter.step0, [], 3) / sqrt(size(dataAll.Butter.step0,3));
h2 = plot(time,errMean,'Color',cmap(4,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(4,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

errMean = mean(dataAll.DetrendButterMod.step0,3);
errSem = std(dataAll.DetrendButterMod.step0, [], 3) / sqrt(size(dataAll.DetrendButterMod.step0,3));
h3 = plot(time,errMean,'Color',cmap(8,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(8,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

h4 = plot(tep_gt_abs.time*1000,tep_gt_abs.tep_gt,'k','LineWidth',1.5);

plot([0,0],[-20,20],'k--','linewidth',1.5);

set(gca,'xlim',[-300,300],'ylim',[-18,18],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);

xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
legend([h1,h2,h3,h4],'Raw','Butter','Detrend + ButterMod','Ground truth','location','southwest','box','off');
title('Simulated TEPs (step = 0 \muV)');

xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.18,ylimits(2)+(ylimits(2)-ylimits(1))*0.05,'C','FontSize',24,'FontWeight','bold');
