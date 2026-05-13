% Plot the offset problem in an example participant

%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Merrick_temp\TMSEEG_DS\analysis\line_offset_check\TMSEEG_senstim\';

%% Butterfly plot

% Individual to plot
id = 'P010';

% Load the data
fileName = [id, '_optimal_120_custom_no_artefact_removed.set'];
EEG = pop_loadset('filename',fileName,'filepath',pathDataInd);
EEG = pop_tesa_interpdata( EEG, 'cubic', [5 5] );

% Plot the figure
fig = figure('color','w');
set(gcf,'Position',[100,100,1185,650]);

% Colours
cb = brewermap(4,'GnBu');

% Butterfly plot
subplot(2,3,1)
plot(EEG.times,mean(EEG.data,3),'k');hold on;
chan = 'F1';
labels = {EEG.chanlocs.labels}';
chani = find(strcmp(labels,chan));
plot(EEG.times,mean(EEG.data(chani,:,:),3),'r','linewidth',1.5);
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[-40,40],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Butterfly plot of raw TEP');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'A', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Plot the GMFA
EEG = pop_tesa_tepextract( EEG, 'GMFA' );
subplot(2,3,2)
plot(EEG.times,EEG.GMFA.R1.tseries,'k','linewidth',1.5);hold on;
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[0,12],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Raw GMFA');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'B', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% %% Inidividual channel
% 
% % Rank the channels from max to min amplitude at 500 ms
% [~,tp1] = min(abs(500-EEG.times));
% tempData = mean(EEG.data(:,tp1,:),3);
% [B,I] = sort(tempData);
% labels = {EEG.chanlocs.labels}';
% chanSort = labels(I);
% 
% % Plot individual channel
% chan = 'FCz';
% chani = find(strcmp(labels,chan));
% subplot(2,2,2)
% plot(EEG.times,mean(EEG.data(chani,:,:),3),'k');

%% Independent component

% Load the data with IC
fileName = [id, '_optimal_120_custom_step_artefact_removed.set'];
EEGic = pop_loadset('filename',fileName,'filepath',pathDataInd);

% Find the step IC
stepIC = EEGic.icaCompClass.TESA1.reject;

% Calculate the IC time series
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
EEG.icaact = reshape( EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);

% Plot the IC representing the step
subplot(2,3,3)
plot(EEG.times,mean(EEG.icaact(stepIC,:,:),3),'color',cb(3,:),'linewidth',1.5); hold on;
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[-5,5],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('IC representing step artifact');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'C', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


%% Filter the data and calculate the IC

% Filter the data
EEG = pop_tesa_filtbutter( EEG, 1, 80, 2, 'bandpass' );

% Replot the butterfly plot
subplot(2,3,4)
plot(EEG.times,mean(EEG.data,3),'k');hold on;
chan = 'F1';
labels = {EEG.chanlocs.labels}';
chani = find(strcmp(labels,chan));
plot(EEG.times,mean(EEG.data(chani,:,:),3),'r','linewidth',1.5); hold on;
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[-40,40],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('TEP after filtering (1-80 Hz)');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'D', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Plot the GMFA
EEG = pop_tesa_tepextract( EEG, 'GMFA' );
subplot(2,3,5)
plot(EEG.times,EEG.GMFA.R2.tseries,'k','linewidth',1.5);hold on;
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[0,12],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('GMFA after filtering');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'E', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Re-calculate the IC time series
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
EEG.icaact = reshape( EEG.icaact, size(EEG.icaact,1), EEG.pnts, EEG.trials);

% Re-plot the IC after filtering the step
subplot(2,3,6)
plot(EEG.times,mean(EEG.icaact(stepIC,:,:),3),'color',cb(4,:),'linewidth',1.5); hold on;
plot([0,0],[-100,100],'--','color',[0.8,0.8,0.8],'linewidth',1.5);
set(gca,'ylim',[-5,5],'tickdir','out','box','off','linewidth',1.5,'fontsize',12);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
title('Step artifact IC after filtering');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.05, 'F', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Plot the IC topography on the plot

% Load layout
% load('easycapM1.mat');
% lay.label = upper(lay.label);

% Create dummy structure
TPdata.avg = EEG.icawinv(:,stepIC);
TPdata.dimord = 'chan_time';
TPdata.time = 1;
TPdata.label = upper({EEG.chanlocs.labels}');

% Set fieldtrip cfg for topoplots
cfg = [];
cfg.layout             = 'quickcap64.mat';
cfg.comment            = 'no';
cfg.interactive        = 'no';
cfg.markersymbol       = '.';
cfg.markersize         = 3; % Slightly bigger marker for clarity
% cfg.parameter          = 'data';
cfg.gridscale          = 128; % Higher grid resolution for smoother plots
cfg.zlim               = [-3, 3];
cfg.style              = 'straight';
% cfg.xlim     = [0.4,0.7]; %time period we want to compare
% cfg.avgovertime = 'yes'; %collapsing all time points down into single value. can change this between no and yes depending if you want time included

% Plot the figure
ax = axes('Position', [0.78,0.6,0.15,0.15]);
cfg.figure = 'gcf';
ft_topoplotER(cfg,TPdata);

cb = colorbar;
title(cb,'a.u.')

%% Save the figure

print(fig,'-dpng',[pathFigures,'figure_step_artifact_example_individual']);

%% Finish