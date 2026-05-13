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
cleaningName = {'raw','demean','detrend','butter','butter_demean','butter_detrend','butter_modified_demean','butter_modified_detrend'};
cleaningVar = {'Raw','Demean','Detrend','Butter','DemeanButter','DetrendButter','DemeanButterMod','DetrendButterMod'};

cmap = brewermap(length(cleaningName),'Set3');
cmap = cmap([1 2 3 4 8 6 7 5],:);

% Loop and save the rmse
for cx = 1:length(cleaningName)

    % Load the data
    load(['real_filter_',cleaningName{cx},'.mat']);

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

for cx = 1:length(cleaningName)
    rmse = [];
    for idx = 1:size(tep_gt,3)
        for sx = 1:length(stepLevel)

            % Calculate the RMS error
            rmse(:,sx,idx) = sqrt(mean((tep_gt(:,tg10:tg300,idx) - dataAll.(cleaningVar{cx}).(['step',num2str(stepLevel(sx))])(:,t10:t300,idx)).^2,2));

        end
    end
    rmseTEP.(cleaningVar{cx}).rmse = rmse;
end

%%

fig1 = figure('color','w');

% Loop and plot
for cx = 1:length(cleaningVar)
     
    data = rmseTEP.(cleaningVar{cx}).rmse;
    steps = rmseAll.(cleaningVar{cx}).stepLevel;

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Shaded area
    fill([steps, fliplr(steps)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

    % Mean line
    plot(steps, errMean,'Color',cmap(cx,:), 'LineWidth', 1.5);


end

set(gca,'xlim',[-0.5,10.5],'tickdir','out','box','off');
xlabel('Step artifact amplitude (\muV)');
ylabel('Root mean square error (\muV)');

%%

fig2 = figure('color','w');
set(gcf,'position',[20,20,1200,1000]);

subplot(2,2,1)

dataOut = [];
for cx = 1:length(cleaningVar)
     
    data = rmseTEP.(cleaningVar{cx}).rmse;

    dataOut(cx,:) = data(:,1,:);

end

errMean = mean(dataOut,2);
errSem = std(dataOut, [], 2) / sqrt(size(dataOut,2));

[~,i] = sort(errMean,'descend');
errMean = errMean(i);
errSem = errSem(i);

cmapSet1 = cmap;

% Mean line
% plot(mean(dataOut,2),'.-','Color',cmap(cx,:), 'LineWidth', 1.5);
% boxplot(dataOut', 'Labels', cleaningVar);
errorbar(1:length(cleaningVar),errMean,errSem,'linestyle','none','color','k','linewidth',1.5);hold on; % 'o-' for circles at data points connected by lines
hL = bar(1:length(cleaningVar),errMean,'facecolor',cmapSet1(2,:),'linewidth',1.5);

hL.FaceColor = 'flat';        % allow individual bar colours
hL.CData = cmapSet1(i,:);

set(gca,'xlim',[0,length(cleaningVar)+1],'ylim',[0,16],'tickdir','out','box','off','linewidth',1.5,'fontsize',12,...
    'xticklabel',cleaningVar(i),'xtick',1:length(cleaningVar),'XTickLabelRotation',45);

ylabel('Root mean square error (\muV)');
title('Step = 0 \muV');

xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.18,ylimits(2)+(ylimits(2)-ylimits(1))*0.05,'A','FontSize',24,'FontWeight','bold');

%%
subplot(2,2,2)

dataOut = [];
for cx = 1:length(cleaningVar)
     
    data = rmseTEP.(cleaningVar{cx}).rmse;

    dataOut(cx,:) = data(:,6,:);

end

errMean = mean(dataOut,2);
errSem = std(dataOut, [], 2) / sqrt(size(dataOut,2));

[~,i] = sort(errMean,'descend');
errMean = errMean(i);
errSem = errSem(i);

% Mean line
% plot(mean(dataOut,2),'.-','Color',cmap(cx,:), 'LineWidth', 1.5);
% boxplot(dataOut', 'Labels', cleaningVar);
errorbar(1:length(cleaningVar),errMean,errSem,'linestyle','none','color','k','linewidth',1.5);hold on; % 'o-' for circles at data points connected by lines
hL = bar(1:length(cleaningVar),errMean,'facecolor',cmapSet1(2,:),'linewidth',1.5);

hL.FaceColor = 'flat';        % allow individual bar colours
hL.CData = cmapSet1(i,:);

set(gca,'xlim',[0,length(cleaningVar)+1],'ylim',[0,16],'tickdir','out','box','off','linewidth',1.5,'fontsize',12,...
    'xticklabel',cleaningVar(i),'xtick',1:length(cleaningVar),'XTickLabelRotation',45);

ylabel('Root mean square error (\muV)');
title('Step = 10 \muV');

xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.18,ylimits(2)+(ylimits(2)-ylimits(1))*0.05,'B','FontSize',24,'FontWeight','bold');

%%
subplot(2,2,3)
errMean = mean(dataAll.Raw.step0,3);
errSem = std(dataAll.Raw.step0, [], 3) / sqrt(size(dataAll.Raw.step0,3));
h1 = plot(time,errMean,'Color',cmap(1,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

errMean = mean(dataAll.Butter.step0,3);
errSem = std(dataAll.Butter.step0, [], 3) / sqrt(size(dataAll.Raw.step0,3));
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

% % Create the rectangle object
% r = rectangle('Position', [tp1, ylimits(1), tp2-tp1, ylimits(2)-ylimits(1)], ...
%               'FaceColor', [0 0 1 0.1], ... % Blue color (RGB)
%               'EdgeColor', 'none'); % No edge line

% Create box
xBox = [10 50 50 10];
yBox = [-18 -18 -16 -16];
h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey
h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

% Set the transparency
% r.FaceAlpha = 0.3; % 30% transparent

%%
subplot(2,2,4)
errMean = mean(dataAll.Raw.step10,3);
errSem = std(dataAll.Raw.step10, [], 3) / sqrt(size(dataAll.Raw.step10,3));
h1 = plot(time,errMean,'Color',cmap(1,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

errMean = mean(dataAll.Butter.step10,3);
errSem = std(dataAll.Butter.step10, [], 3) / sqrt(size(dataAll.Raw.step0,3));
h1 = plot(time,errMean,'Color',cmap(4,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(4,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

errMean = mean(dataAll.DetrendButterMod.step10,3);
errSem = std(dataAll.DetrendButterMod.step10, [], 3) / sqrt(size(dataAll.DetrendButterMod.step10,3));
h2 = plot(time,errMean,'Color',cmap(8,:), 'LineWidth', 1.5); hold on;
fill([time, fliplr(time)], ...
    [errMean - errSem, fliplr(errMean + errSem)], ...
    cmap(8,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;

plot(tep_gt_abs.time*1000,tep_gt_abs.tep_gt,'k','LineWidth',1.5);

plot([0,0],[-20,20],'k--','linewidth',1.5);

set(gca,'xlim',[-300,300],'ylim',[-18,18],'box','off','tickdir','out','linewidth',1.5,'fontsize',12);

xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Simulated TEPs (step = 10 \muV)');

xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.18,ylimits(2)+(ylimits(2)-ylimits(1))*0.05,'D','FontSize',24,'FontWeight','bold');

% % Create the rectangle object
% r = rectangle('Position', [tp1, ylimits(1), tp2-tp1, ylimits(2)-ylimits(1)], ...
%               'FaceColor', [0 0 1 0.1], ... % Blue color (RGB)
%               'EdgeColor', 'none'); % No edge line

xBox = [10 50 50 10];
yBox = [-18 -18 -16 -16];

h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey

h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

%% Save the figure

print(fig2,'-dpng',[pathFigures,'figure_compare_methods_abs_ground_truth']);