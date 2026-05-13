%% Settings

clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Path to individual data
pathDataInd = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\LAB_temporary\Merrick_temp\TMSEEG_DS\analysis\line_offset_check\TMSEEG_senstim\';

%% Butterfly plot

% Individual to plot
id = 'P004';

% Load the data
fileName = [id, '_optimal_120_custom_no_artefact_removed.set'];
EEG = pop_loadset('filename',fileName,'filepath',pathDataInd);

% Plot the figure
fig = figure('color','w');
set(gcf,'Position',[100,100,900,650]);

% Colours
cb = brewermap(4,'GnBu');

% Butterfly plot
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

%%

% Load the absolute ground truth
gt = load('ground_truth_tep.mat');

data = mean(EEG.data(chani,:,:),3);
time = EEG.times;

% Parameters
b = 2.6;    % example value
k = 0;    % example value
x = 1;    % example value

% Range of F
F = 0:999;

L_10 = b - log10(k + F.^x);  % original formula with log base 10
Y_10 = 10.^(b - L_10);       % log-free form: Y = 10^(b - L) = k + F^x
AP = (10.^b) ./ (F.^x);

mixMod = gt.tep_gt*-3;

t1 = F(1);
t2 = F(end);
[~,tp1] = min(abs(t1-gt.time*1000));
[~,tp2] = min(abs(t2-gt.time*1000));
mixMod(tp1:tp2) = mixMod(tp1:tp2) + AP;

close all;
figure;
plot(time,data.*-1,'k');hold on;
plot(gt.time*1000,gt.tep_gt*-3,'r');
%plot(F,AP,'b');
plot(gt.time*1000,mixMod,'b');
set(gca,'ylim',[-20,20]);

%%

% Generate a dummy EEG structure
EEG = [];
EEG.srate = 1000;
EEG.times = time;
EEG.pnts = length(EEG.times);
EEG.xmin = EEG.times(1)./1000;
EEG.xmax = EEG.times(end)./1000;
EEG.trials = 1;
EEG.event.latency = 1001;
EEG.event.type = 'tms';
EEG.data = zeros(1,length(time));
EEG.data(tp1:tp2) = EEG.data(tp1:tp2) + AP;

EEGraw = EEG;

% Remove artifact
EEG = pop_tesa_removedata( EEG, [-2 10] );

% Interpolate artifact
EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

% Run filter
EEGpost = pop_tesa_filtbutter( EEG, 1, [], 2, 'highpass' );

% set(gca,'ylim',[-20,20]);

%%

% Settings
epochTimespan = [EEG.xmin,EEG.xmax];
bandpassFreqSpan = [1,80];
filterPrePostExtrapolationDurations = [0,0];
timeToExtend = 0.5;

% Run filter
artifactTimespan = EEG.tmscut(1).cutTimesTMS * 0.001;
EEGmod = tesa_modifiedbandpassfilter(EEG,...
	'piecewiseTimeToExtend', timeToExtend,...
	'lowCutoff', bandpassFreqSpan(1),...
	'artifactTimespan', artifactTimespan*3,...
	'prePostExtrapolationDurations', filterPrePostExtrapolationDurations,...
    'doDebug',true);

close all;
figure;
plot(EEG.times,EEG.data,'k');hold on;
plot(EEGpost.times,EEGpost.data,'r');
plot(EEGmod.times,EEGmod.data,'b');