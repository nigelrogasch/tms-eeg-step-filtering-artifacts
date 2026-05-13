%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

eeglabPath = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\MATLAB Toolboxes\eeglab2023.0';

%% Loop and plot for each participant

% ID list
id = {'P002','P004','P012','P014'};

% Condition list
condition = {'monophasic_highpass','biphasic_highpass','monophasic_DC','biphasic_DC'};
conditionName = {'AC mono low','AC bi low','DC mono low','DC bi low'};

% Define amplifier range
minRange = -3276;  % lower limit (µV)
maxRange = 3276;   % upper limit (µV)

% Counter
n = 1;

fig1 = figure('color','w');
set(gcf,'Position',[65,40,1200,800]);

for idx = 1:length(id)
    for conx = 1:length(condition)

        filePath = ['\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\',id{idx},'\Follow-up\'];
        fileName = [id{idx},'_mri_120_custom_',condition{conx},'.vhdr'];
        EEG = pop_loadbv(filePath, fileName);

        % --- Add electrode locations ---
        EEG = pop_chanedit(EEG, 'lookup', fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));

        % --- Remove unused channels (31 & 32) ---
        EEG = pop_select(EEG, 'rmchannel', [31 32]);

        % --- Remove TMS pulse window (-2 to 10 ms), then interpolate it
        EEG = pop_tesa_removedata( EEG, [-2 10], [-500 -10], {'S127'} );
        EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

        % Identify clipped points
        clippedMask = (EEG.data < minRange) | (EEG.data > maxRange);

        % Count number of out-of-range data points
        numClipped = sum(clippedMask(:));
        meanClipped(idx,conx) = 100*numClipped/numel(EEG.data);
        fprintf('Number of clipped points: %d (%.2f%% of all data)\n', ...
            numClipped, 100*numClipped/numel(EEG.data));

        % Plot a heatmap showing clipped points
        subplot(4,4,n);
        imagesc(clippedMask);
        colormap([1 1 1; 1 0 0]);  % white = normal, red = clipped
        xlabel('Time (samples)');
        ylabel('Channels');
        title(sprintf('Participant %g %s',idx,conditionName{conx}));
        colorbar('Ticks',[0,1],'TickLabels',{'In range','Clipped'});

        n = n+1;

    end
end

% Save the data
save([pathData,'individual_clipping.mat'],'meanClipped');

% Save the figure
print(fig1,'-dpng',[pathFigures,'figure_individual_clipping']);

%% Loop and plot for each participant

% ID list
id2 = {'P002','P012'};

% Condition list
condition2 = {'monophasic_dc_lowres','biphasic_dc_lowres','monophasic_dc_highres','biphasic_dc_highres'};
conditionName2 = {'DC mono low','DC bi low','DC mono high','DC bi high'};

% Counter
n = 1;

fig3 = figure('color','w');
set(gcf,'Position',[65,40,1200,800]);

for idx = 1:length(id2)
    for conx = 1:length(condition2)

        filePath = ['\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\',id2{idx},'\Follow-up2\'];
        fileName = [id2{idx},'_mri_120_custom_',condition2{conx},'.vhdr'];
        EEG = pop_loadbv(filePath, fileName);

        % Define amplifier range
        if strcmp(condition2{conx},'monophasic_dc_lowres') || strcmp(condition2{conx},'biphasic_dc_lowres')
            minRange = -3276;  % lower limit (µV)
            maxRange = 3276;   % upper limit (µV)
        elseif strcmp(condition2{conx},'monophasic_dc_highres') || strcmp(condition2{conx},'biphasic_dc_highres')
            minRange = -16380;  % lower limit (µV)
            maxRange = 16380;   % upper limit (µV)
        end

        % Identify clipped points
        clippedMask = (EEG.data < minRange) | (EEG.data > maxRange);

        % Count number of out-of-range data points
        numClipped = sum(clippedMask(:));
        meanClipped2(idx,conx) = 100*numClipped/numel(EEG.data);
        fprintf('Number of clipped points: %d (%.2f%% of all data)\n', ...
            numClipped, 100*numClipped/numel(EEG.data));

        % Plot a heatmap showing clipped points
        subplot(4,4,n);
        imagesc(clippedMask);
        colormap([1 1 1; 1 0 0]);  % white = normal, red = clipped
        xlabel('Time (samples)');
        ylabel('Channels');
        title(sprintf('Participant %g %s',idx,conditionName2{conx}));
        colorbar('Ticks',[0,1],'TickLabels',{'In range','Clipped'});

        numChanClipped = sum(clippedMask,2);

        n = n+1;

    end
end

% Save the data
save([pathData,'individual_clipping_compare_amp.mat'],'meanClipped2');

% Save the figure
print(fig3,'-dpng',[pathFigures,'figure_individual_clipping_compare_amp']);

% %% Double check clipping for each file
% % ID list
% id2 = {'P012'};
% 
% % Condition list
% condition2 = {'monophasic_dc_lowres','biphasic_dc_lowres','monophasic_dc_highres','biphasic_dc_highres'};
% conditionName2 = {'Mono low','Bi low','Mono high','Bi high'};
% 
% % Counter
% n = 1;
% 
% fig4 = figure('color','w');
% set(gcf,'Position',[65,40,1200,800]);
% 
% for idx = 1:length(id2)
%     for conx = 1:length(condition2)
% 
%         filePath = ['R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\',id2{idx},'\Follow-up2\'];
%         fileName = [id2{idx},'_mri_120_custom_',condition2{conx},'.vhdr'];
%         EEG = pop_loadbv(filePath, fileName);
% 
%         % Plot a heatmap showing clipped points
%         subplot(4,4,n);
%         plot(EEG.times,EEG.data,'k');
%         xlabel('Time (ms)');
%         ylabel('Amplitude (\muV)');
%         title(sprintf('Participant %g %s',idx,conditionName2{conx}));
%         set(gca,'ylim',[-17000,17000]);
% 
%         n = n+1;
% 
%     end
% end
% 
% % Save the figure
% % print(fig4,'-dpng',[pathFigures,'figure_individual_clipping_compare_amp_timeseries']);

%%

% Plot participant from AC/DC
EEG = pop_loadbv('\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Marissa_temp\Optimization_Data\P004\Follow-up\', 'P004_mri_120_custom_monophasic_dc.vhdr');

% --- Add electrode locations ---
EEG = pop_chanedit(EEG, 'lookup', fullfile(eeglabPath,'plugins','dipfit5.2','standard_BESA','standard-10-5-cap385.elp'));

% --- Remove unused channels (31 & 32) ---
EEG = pop_select(EEG, 'rmchannel', [31 32]);

% --- Remove TMS pulse window (-2 to 10 ms), then interpolate it
EEG = pop_tesa_removedata( EEG, [-2 10], [-500 -10], {'S127'} );
EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

%% 

% Load the data
load([pathData,'individual_clipping.mat']);
load([pathData,'individual_clipping_compare_amp.mat']);

% ID list
id = {'P002','P004','P012','P014'};
id2 = {'P002','P012'};

conditionName = {'AC mono low','AC bi low','DC mono low','DC bi low'};
conditionName2 = {'DC mono low','DC bi low','DC mono high','DC bi high'};

cmap = brewermap(6,'Dark2');

% Colours
col = tab20;

fig2 = figure('color','w');
set(gcf,'Position',[200,300,1000,400]);

subplot(1,3,1)
plot(EEG.times,EEG.data(6,:),'color',col(1,:)); hold on;
minRange = -3276;  % lower limit (µV)
maxRange = 3276;   % upper limit (µV)
plot([EEG.times(1),EEG.times(end)],[minRange,minRange],'--','color',col(7,:),'LineWidth',1.5);
plot([EEG.times(1),EEG.times(end)],[maxRange,maxRange],'--','color',col(7,:),'LineWidth',1.5);
set(gca, 'box','off','tickdir','out', 'FontSize', 12,'linewidth',1.5);

xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Example of clipping');

text(-0.35, 1.1, 'A', ...
    'Units', 'normalized', ...
    'FontWeight', 'bold', ...
    'FontSize', 14, ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left');

subplot(1,3,2);

% Create bar plot and suppress its legend entry
blue = [0.6 0.8 0.95];
hBar = bar(mean(meanClipped,1), 'HandleVisibility','off','linewidth',1.5,'FaceColor', blue); 
hBar.FaceColor = 'flat';        % allow individual bar colours
hBar.CData = col([2 6 4 8],:);        % first 4 colours
hold on;

% Plot each participant's line
hLines = gobjects(length(id),1);
for idx = 1:length(id)
    hLines(idx) = plot(1:size(meanClipped,2), meanClipped(idx,:), '-o', ...
        'LineWidth', 1.5, 'MarkerSize', 3, ...
        'Color', 'k',...
        'MarkerFaceColor', 'k');
    hold on;
end

xlabel('Condition');
ylabel('Samples clipped (%)');

set(gca, 'box','off','tickdir','out', ...
    'xlim',[0.5,4.5], 'XTick', 1:4, 'XTickLabel', conditionName, ...
    'FontSize', 12, 'ylim',[0,35],'linewidth',1.5);

% Add only the line plots to the legend
% legend(hLines, id, 'Location','Northwest','box','off');
title('AC vs DC coupling');

text(-0.25, 1.1, 'B', ...
    'Units', 'normalized', ...
    'FontWeight', 'bold', ...
    'FontSize', 14, ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left');


subplot(1,3,3);

% Create bar plot and suppress its legend entry
blue = [0.6 0.8 0.95];
hBar = bar(mean(meanClipped2,1), 'HandleVisibility','off','linewidth',1.5,'FaceColor', blue);
hBar.FaceColor = 'flat';        % allow individual bar colours
hBar.CData = col([4 8 3 7],:);        % first 4 colours
hold on;

% Plot each participant's line
hLines = gobjects(length(id2),1);
for idx = 1:length(id2)
    if idx == 1
    hLines(idx) = plot(1:size(meanClipped2,2), meanClipped2(idx,:), '-o', ...
        'LineWidth', 1.5, 'MarkerSize', 3, ...
        'Color', 'k',...
        'MarkerFaceColor', 'k');
    elseif idx == 2
            hLines(idx) = plot(1:size(meanClipped2,2), meanClipped2(idx,:), '-o', ...
        'LineWidth', 1.5, 'MarkerSize', 3, ...
        'Color', 'k',...
        'MarkerFaceColor', 'k');
    end
    hold on;
end

xlabel('Condition');
ylabel('Samples clipped (%)');

set(gca, 'box','off','tickdir','out', ...
    'xlim',[0.5,4.5], 'XTick', 1:4, 'XTickLabel', conditionName2, ...
    'FontSize', 12, 'ylim',[0,35],'linewidth',1.5);

% Add only the line plots to the legend
% legend(hLines, id2, 'Location','Northeast','box','off');

title('Low vs high range');

text(-0.25, 1.1, 'C', ...
    'Units', 'normalized', ...
    'FontWeight', 'bold', ...
    'FontSize', 14, ...
    'VerticalAlignment', 'top', ...
    'HorizontalAlignment', 'left');

% Save the figure
print(fig2,'-dpng',[pathFigures,'figure_summary_clipping']);