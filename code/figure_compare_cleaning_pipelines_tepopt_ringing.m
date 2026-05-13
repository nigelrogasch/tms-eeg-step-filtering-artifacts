% Plot comparison of different cleaning pipelines
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% % Load paths
load('pathInfo.mat');

% Load data
load([pathData,'data_filtering_pipelines.mat']);


% Set conditions
cleanpipeline = {'modified','modified_notch'};
cleanpipelineNames = {'Standard notch','Modified notch'};

%% Plot GMFA Time Series 

fig1 = figure('color', 'w');
set(gcf,'position',[20,20,800,800]);

cols = get(groot, 'defaultAxesColorOrder');

% subplot(2,2,1)
% for pipeX = 1:length(cleanpipeline)
% 
%     data = dataAll.(cleanpipeline{pipeX});
%     meanData = mean(data,1);
%     semData  = std(data, 0, 1) ./ sqrt(size(data, 1));
% 
%     % Create shaded area for SEM
%     fill([EEG.times, fliplr(EEG.times)], ...
%         [meanData + semData, fliplr(meanData - semData)], ...
%         cols(pipeX,:), ...       % light blue shade
%         'EdgeColor', 'none', ...
%         'FaceAlpha', 0.4); hold on;
% 
%     % Plot the mean line
%     hLines(pipeX) = plot(EEG.times, meanData, 'color',cols(pipeX,:), 'LineWidth', 2);
% 
% end
% 
% % --- Plot the shaded region (before data so it's behind) ---
% xBox = [-5 10 10 -5];             % X coordinates (left, right, right, left)
% yBox = [-10 -10 10 10];           % Y coordinates (bottom, bottom, top, top)
% fill(xBox, yBox, [0.8 0.8 0.8], ... % grey color
%      'EdgeColor', 'none', ...
%      'FaceAlpha', 1);           % transparency (0 = transparent, 1 = opaque)
% 
% set(gca,'ylim',[0,4],'xlim',[-500,500],'box', 'off','tickdir','out');
% xlabel('Time (ms)');
% ylabel('Amplitude (\muV)');
% % title(conditionNames{conX});
% 
% legend(hLines,cleanpipelineNames, 'Location','northwest','box','off');

% subplot(2,2,2)
for pipeX = 1:length(cleanpipeline)

    data = dataAllTep.(cleanpipeline{pipeX});
    meanData = mean(data,1);
    semData  = std(data, 0, 1) ./ sqrt(size(data, 1));

    % Create shaded area for SEM
    fill([EEG.times, fliplr(EEG.times)], ...
        [meanData + semData, fliplr(meanData - semData)], ...
        cols(pipeX,:), ...       % light blue shade
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.4); hold on;

    % Plot the mean line
    hLines(pipeX) = plot(EEG.times, meanData, 'color',cols(pipeX,:), 'LineWidth', 2);

end

% --- Plot the shaded region (before data so it's behind) ---
xBox = [-5 10 10 -5];             % X coordinates (left, right, right, left)
yBox = [-10 -10 10 10];           % Y coordinates (bottom, bottom, top, top)
fill(xBox, yBox, [0.8 0.8 0.8], ... % grey color
     'EdgeColor', 'none', ...
     'FaceAlpha', 1);           % transparency (0 = transparent, 1 = opaque)

set(gca,'ylim',[-6,6],'xlim',[-500,500],'box', 'off','tickdir','out',... 
    'linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
% title(conditionNames{conX});

legend(hLines,cleanpipelineNames, 'Location','northwest','box','off');

% %% Topoplots
% 
% % list of your channel names (as a cell array)
% chanlist = {EEG.chanlocs.labels};
% 
% % --- load standard 10-05/10-10 sensor file supplied with FieldTrip
% sens = ft_read_sens('standard_1005.elc');   % this file is shipped with FieldTrip
% 
% % make a layout limited to channels in your list that actually exist in the sensor file
% cfg = [];
% cfg.channel = chanlist;                % channels you want to plot
% cfg.elec = sens;                        % sensor definition
% layout = ft_prepare_layout(cfg);        % build layout (keeps only matching channels)
% 
% % Load the stat file
% 
% statFiles = {'-110_-90',...
%     '16_25',...
%     '36_55',...
%     '56_75',...
%     '110_130',...
%     '210_230'};
% 
% loadsN = {'Base','P20','N40','P65','N120','P220'};
% 
% figPos = length(statFiles)+1:length(statFiles)+length(statFiles);
% topoN = 1:length(statFiles);
% 
% % Draw figure
% % f = figure('color','w');
% % set(gcf,'position',[0,0,600,1000]);
% 
% for topox = 1:length(statFiles)
% 
%     loadFile = ['standard_vs_modified_',statFiles{topox},'.mat'];
%     load([pathStats,loadFile]);
% 
%     % Get starting figure position
%     sp = subplot(2,length(statFiles),figPos(topox));
%     pos = sp.Position;
%     delete(sp);
% 
%     % Set fieldtrip cfg for topoplots
%     cfg = [];
%     cfg.layout             = layout;
%     cfg.comment            = 'no';
%     cfg.interactive        = 'no';
%     cfg.markersymbol       = '.';
%     cfg.markersize         = 3; % Slightly bigger marker for clarity
%     % cfg.parameter          = 'data';
%     cfg.gridscale          = 128; % Higher grid resolution for smoother plots
%     cfg.zlim               = [-3, 3];
%     cfg.highlight          = 'on';
%     cfg.highlightsymbol    = '*';
%     cfg.highlightcolor     = 'w';
%     cfg.highlightsize      = 4;
%     cfg.style              = 'straight';
%     cfg.highlightchannel   =  find(stat.mask);
% 
%     % Create dummy dimord
%     TPdata = [];
%     TPdata.avg = stat.stat;
%     TPdata.dimord = 'chan_time';
%     TPdata.time = 1;
%     TPdata.label = stat.label;
% 
%     ax.(['tp',num2str(topoN(topox))]) = axes('Position', pos);
%     cfg.figure = 'gcf';
%     ft_topoplotER(cfg,TPdata);
% 
%     % Text above the topolot
%     text(0.5, 1.05, loadsN{topox}, 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Units', 'normalized');
% 
% end
% 
% for topox = 1:length(statFiles)
%     colormap(ax.(['tp',num2str(topoN(topox))]), flipud(brewermap(12,'RdBu')));
% end

%% Save the figure

print(fig1,'-dpng',[pathFigures,'figure_compare_cleaning_pipelines_ringing']);