% Figure comparing different filtering approaches

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

%%

cmap = brewermap(6,'Dark2');
cmap2 = brewermap(8,'Set3');

fig1 = figure('color','w');
set(gcf,'Position',[100,100,900,1100]);

% Load the butter worth data 
load('real_filter_butter.mat');

subplot(3,2,1)

% Loop and plot
for cx = 1:length(stepLevel)
     
    data = eegraw.(['step',num2str(stepLevel(cx))]);

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(time, errMean,'Color',cmap(cx,:), 'LineWidth', 1.5); hold on;

    % Shaded area
    fill([time, fliplr(time)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3,'HandleVisibility','off');

end

plot([0,0],[-20,20],'k--','linewidth',1.5);

set(gca,'xlim',[-300,300],'ylim',[-20,20],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Raw simulated TEP');
legNames = {'Step = 0 \muV','Step = 2 \muV','Step = 4 \muV','Step = 6 \muV','Step = 8 \muV','Step = 10 \muV'};
legend(legNames,'Location','southeast','box','off','fontsize',8);

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'A', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%%
subplot(3,2,2)

% Loop and plot
for cx = 1:length(stepLevel)
     
    data = eegfilt.(['step',num2str(stepLevel(cx))]);

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(time, errMean,'Color',cmap(cx,:), 'LineWidth', 1.5); hold on;

    % Shaded area
    fill([time, fliplr(time)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);

end

plot([0,0],[-20,20],'k--','linewidth',1.5);

% Create box
xBox = [10 300 300 10];
yBox = [-20 -20 -18 -18];
h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey
h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

set(gca,'xlim',[-300,300],'ylim',[-20,20],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Butterworth filter');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'B', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Butterworth comparisons

% Load the butter worth data 
load('real_filter_butter_all.mat');

% Get the condition names
cleaningVar = fieldnames(rmseAll);

% Make cmap
cmapIn = cmap2([4,5,6],:);

subplot(3,2,3)

% Loop and plot
for cx = 1:length(cleaningVar)
     
    data = rmseAll.(cleaningVar{cx}).rmse;
    steps = rmseAll.(cleaningVar{cx}).stepLevel;

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(steps, errMean,'Color',cmapIn(cx,:), 'LineWidth', 2); hold on;

    % Shaded area
    fill([steps, fliplr(steps)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmapIn(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3,'HandleVisibility','off'); 

end


set(gca,'xlim',[-0.5,10.5],'ylim',[-0.5,3],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Step artifact amplitude (\muV)');
ylabel('Root mean square error (\muV)');
legNames = {'Butter','Demean + Butter','Detrend + Butter'};
legend(legNames,'Location','northwest','box','off','fontsize',8);

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'C', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


%% Load the butterworth detrended data 
load('real_filter_butter_detrend.mat');

subplot(3,2,4)

% Loop and plot
for cx = 1:length(stepLevel)
     
    data = eegfilt.(['step',num2str(stepLevel(cx))]);

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(time, errMean,'Color',cmap(cx,:), 'LineWidth', 1.5); hold on;

    % Shaded area
    fill([time, fliplr(time)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);

end

plot([0,0],[-20,20],'k--','linewidth',1.5);

% Create box
xBox = [10 300 300 10];
yBox = [-20 -20 -18 -18];
h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey
h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

set(gca,'xlim',[-300,300],'ylim',[-20,20],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Detrend + Butterworth filter');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'D', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Modified Butterworth comparisons

% Load the butter worth data 
load('real_filter_buttermod_all.mat');

% Get the condition names
cleaningVar = fieldnames(rmseAll);

% Make cmap
cmapIn = cmap2([4,1,7,8],:);

subplot(3,2,5)

% Loop and plot
for cx = 1:length(cleaningVar)
     
    data = rmseAll.(cleaningVar{cx}).rmse;
    steps = rmseAll.(cleaningVar{cx}).stepLevel;

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(steps, errMean,'Color',cmapIn(cx,:), 'LineWidth', 2); hold on;

    % Shaded area
    fill([steps, fliplr(steps)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmapIn(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3,'HandleVisibility','off'); 

end

set(gca,'xlim',[-0.5,10.5],'ylim',[-0.5,3],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Step artifact amplitude (\muV)');
ylabel('Root mean square error (\muV)');
legNames = {'Butter','ButterMod','Demean + ButterMod','Detrend + ButterMod'};
legend(legNames,'Location','northwest','box','off','fontsize',8);

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'E', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Load the butterworth modified detrended data 
load('real_filter_butter_modified_detrend.mat');

subplot(3,2,6)

% Loop and plot
for cx = 1:length(stepLevel)
     
    data = eegfilt.(['step',num2str(stepLevel(cx))]);

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Mean line
    plot(time, errMean,'Color',cmap(cx,:), 'LineWidth', 1.5); hold on;

    % Shaded area
    fill([time, fliplr(time)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);

end

plot([0,0],[-20,20],'k--','linewidth',1.5);

% Create box
xBox = [10 300 300 10];
yBox = [-20 -20 -18 -18];
h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey
h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

set(gca,'xlim',[-300,300],'ylim',[-20,20],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Detrend + Butterworth filter modified');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.25, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'F', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Save the figure

print(fig1,'-dpng',[pathFigures,'figure_compare_filtering_approaches']);