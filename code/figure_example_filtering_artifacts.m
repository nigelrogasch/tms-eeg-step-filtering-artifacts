% Example of filtering artifacts with step artifact

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

%% Generate a ground truth flatline signal

time = -1000:1000;
gt = zeros(1,length(time));

%% Add a step artifact

% Find time between 0 and 1000
[~,t1] = min(abs(0-time));
[~,t2] = min(abs(1000-time));

stepArt = gt;
stepArt(t1:t2) = stepArt(t1:t2)+5;

%% High-pass filter over step artifact

EEG.srate = 1000;
EEG.times = time;
EEG.pnts = length(EEG.times);
EEG.xmin = -1;
EEG.xmax = 1;
EEG.data = stepArt;

% Loop over multiple filter orders
filtOrd = [2];

for fx = 1:length(filtOrd)

    % Run filter
    outcomeHigh.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, 1, [], filtOrd(fx), 'highpass' );

    % Run filter
    outcomeLow.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, [], 80, filtOrd(fx), 'lowpass' );

end

%% Plot the outcomes

% Colours
cb = brewermap(4,'GnBu');

fig = figure('color','w');
set(gcf,'Position',[100,100,850,800]);

subplot(2,2,1)
% plot(time,gt,'k','LineWidth',1.5); hold on;
plot(time,stepArt,'k','LineWidth',1.5);hold on;
for fx = 1:length(filtOrd)
    plot(time,outcomeHigh.(['EEG',num2str(filtOrd(fx))]).data,'color','r','LineWidth',1.5);
end
set(gca,'ylim',[-6,6],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('High-pass filter (1 Hz)');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'A', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

subplot(2,2,2)
% plot(time,gt,'k','LineWidth',1.5); hold on;
plot(time,stepArt,'k','LineWidth',1.5);hold on;
for fx = 1:length(filtOrd)
    plot(time,outcomeLow.(['EEG',num2str(filtOrd(fx))]).data,'color','r','LineWidth',1.5);
end
set(gca,'ylim',[-6,6],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('Low-pass filter (80 Hz)');
legend({'Raw + step','Raw + step + filter'},'location','southwest','box','off');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'B', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


%% Generate drift artifact

% Parameters
fs = 1000;                  % Sampling rate in Hz
t = -1:1/fs:1;              % Time vector from -1 to 1 seconds
drift_rate = -5e-6;          % Drift rate in V/s (1 µV/s = 1e-6 V/s)

% Create drift artifact (linear increase)
drift = drift_rate * t;     % Drift in Volts

% Convert to microvolts for display
drift_uV = drift * 1e6;

% Filter the drift artifact
EEG.srate = 1000;
EEG.times = time;
EEG.pnts = length(EEG.times);
EEG.xmin = -1;
EEG.xmax = 1;
EEG.data = drift_uV;

% Loop over multiple filter orders
filtOrd = [2];

for fx = 1:length(filtOrd)

    % Run filter
    outcomeDriftHigh.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, 1, [], filtOrd(fx), 'highpass' );

    % Run filter
    outcomeDriftLow.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, [], 80, filtOrd(fx), 'lowpass' );

end

subplot(2,2,3)
% plot(time,gt,'k','LineWidth',1.5); hold on;
plot(time,drift_uV,'k','LineWidth',1.5); hold on;
for fx = 1:length(filtOrd)
    plot(time,outcomeDriftHigh.(['EEG',num2str(filtOrd(fx))]).data,'color','r','LineWidth',1.5);
end
set(gca,'ylim',[-6,6],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('High-pass filter (1 Hz)');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'C', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


subplot(2,2,4)
% plot(time,gt,'k','LineWidth',1.5); hold on;
plot(time,drift_uV,'k','LineWidth',1.5); hold on;
for fx = 1:length(filtOrd)
    plot(time,outcomeDriftLow.(['EEG',num2str(filtOrd(fx))]).data,'color','r','LineWidth',1.5);
end
set(gca,'ylim',[-6,6],'xlim',[-1000,1000],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
xlabel('Time (ms)');
ylabel('Amplitude (a.u.)');
title('Low-pass filter (80 Hz)');
legend({'Raw + drift','Raw + drift + filter'},'location','southwest','box','off');

% Plot the figure letter
xlimits = get(gca,'xlim');
ylimits = get(gca,'ylim');
text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'D', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');


% %% Example of combined artifact
% 
% % Generate step artifact with 5 uV step
% stepArt5 = gt;
% stepArt5(t1:t2) = stepArt5(t1:t2)+5;
% 
% % Combine with drift artifact
% combineArt = drift_uV+stepArt5;
% 
% % Baseline correct (-1000 to 0)
% [~,t1] = min(abs(-1000-time));
% [~,t2] = min(abs(0-time));
% combineArt = combineArt - mean(combineArt(t1:t2));
% 
% 
% % Filter the combined artifact
% EEG.srate = 1000;
% EEG.times = time;
% EEG.pnts = length(EEG.times);
% EEG.xmin = -1;
% EEG.xmax = 1;
% EEG.data = combineArt;
% 
% % Loop over multiple filter orders
% filtOrd = [2];
% 
% for fx = 1:length(filtOrd)
% 
%     % Run filter
%     outcomeCombineHigh.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, 1, [], filtOrd(fx), 'highpass' );
% 
%     % Run filter
%     outcomeCombineLow.(['EEG',num2str(filtOrd(fx))]) = pop_tesa_filtbutter( EEG, 1, 80, filtOrd(fx), 'bandpass' );
% 
% end
% 
% subplot(3,2,5)
% plot(time,gt,'k','LineWidth',1.5); hold on;
% plot(time,combineArt,'r','LineWidth',1.5);
% for fx = 1:length(filtOrd)
%     plot(time,outcomeCombineHigh.(['EEG',num2str(filtOrd(fx))]).data,'color',cb(fx+2,:),'LineWidth',1.5);
% end
% set(gca,'ylim',[-6,6],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
% xlabel('Time (ms)');
% ylabel('Amplitude (a.u.)');
% title('High-pass filter (1 Hz)');
% 
% % Plot the figure letter
% xlimits = get(gca,'xlim');
% ylimits = get(gca,'ylim');
% text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'E', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
% 
% 
% subplot(3,2,6)
% plot(time,gt,'k','LineWidth',1.5); hold on;
% plot(time,combineArt,'r','LineWidth',1.5);
% for fx = 1:length(filtOrd)
%     plot(time,outcomeCombineLow.(['EEG',num2str(filtOrd(fx))]).data,'color',cb(fx+2,:),'LineWidth',1.5);
% end
% set(gca,'ylim',[-6,6],'xlim',[-1000,1000],'tickdir','out','box','off','fontsize',12,'LineWidth',1.5);
% xlabel('Time (ms)');
% ylabel('Amplitude (a.u.)');
% title('Band-pass filter (1-80 Hz)');
% legend({'Raw','Raw + step + drift','Filt. ord. = 2','Filt. ord. = 4'},'location','southwest','box','off');
% 
% % Plot the figure letter
% xlimits = get(gca,'xlim');
% ylimits = get(gca,'ylim');
% text(xlimits(1)-(xlimits(2)-xlimits(1))*0.2, ylimits(2)+(ylimits(2)-ylimits(1))*0.08, 'F', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

%% Save the figure

print(fig,'-dpng',[pathFigures,'figure_example_filtering_artifacts']);

%% Finish