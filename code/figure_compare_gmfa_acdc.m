clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Set paths
DataOut = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_ACDC';

% Set conditions
condition = {'monophasic_highpass','biphasic_highpass','monophasic_DC','biphasic_DC'};
% condition = {'monophasic_highpass','monophasic_DC','biphasic_highpass','biphasic_DC'};
conditionNames = {'AC Mono','AC Bi','DC Mono','DC Bi'};

P_ID = {'P002','P004','P012','P014'};

%% Calculate GMFA for different time periods


for P_IDX = 1:length(P_ID)
    
    for conX = 1:length(condition)
        
        % Load Data
        
        filename = [P_ID{P_IDX}, '_', condition{conX}, '_Savepoint3_short.set'];
        
        EEG = pop_loadset('filename',filename,'filepath',DataOut);

        % Find the F1 electrode
        idx = find(strcmpi({EEG.chanlocs.labels}, 'F3'));

        % --- Remove TMS pulse window (-2 to 15 ms), then interpolate it
        EEG = pop_tesa_removedata( EEG, [-2 15], [-500 -10], {'S127'} );
        EEG = pop_tesa_interpdata( EEG, 'cubic', [5 5] );

        % Extract GMFA
        EEG = pop_tesa_tepextract( EEG, 'GMFA' );
        
        dataAll.(condition{conX})(P_IDX,:) = EEG.GMFA.R1.tseries;
        dataTEP.(condition{conX})(P_IDX,:) = mean(EEG.data(idx,:,:),3);

        % Band pass filter
        EEG = pop_tesa_filtbutter( EEG, 1, 80, 2, 'bandpass' );

        % Extract GMFA
        EEG = pop_tesa_tepextract( EEG, 'GMFA' );

        dataAllFilt.(condition{conX})(P_IDX,:) = EEG.GMFA.R2.tseries;
        dataTEPFilt.(condition{conX})(P_IDX,:) = mean(EEG.data(idx,:,:),3);

    end
    
end

%% Plot GMFA Time Series 

fig1 = figure('color', 'w'); 
set(gcf,'position',[200,200,1000,750]);

% Colours
col = tab20;
col = col([2 6 4 8],:);

% Fig letters
figLet = {'A','B','C','D','E','F'};

subplot(2,3,2)

 for conX = 1:length(condition)

  meandata = mean(dataAll.(condition{conX}),1);
  h1(conX) = plot(EEG.times, meandata,'color',col(conX,:),'linewidth',1.5); hold on;
  plot([0,0],[-100,100],'k--');

 end

xBox = [15 500 500 15];
yBox = [0 0 0.5 0.5];

h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey

h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

lgd = legend(h1,conditionNames, 'Location','northwest','box','off','fontsize',10);
lgd.ItemTokenSize = [10 10];

  set(gca,'ylim',[0,8],'xlim',[-500,500],'box', 'off','tickdir','out',...
      'linewidth',1.5,'fontsize',12,'layer','top');
  xlabel('Time (ms)');
  ylabel('Amplitude (\muV)');
  title('GMFA before filtering');

 text(-0.3, 1.1, figLet{2}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

 subplot(2,3,5)

 for conX = 1:length(condition)

  meandata = mean(dataAllFilt.(condition{conX}),1);
  plot(EEG.times, meandata,'color',col(conX,:),'linewidth',1.5); hold on;
  plot([0,0],[-100,100],'k--');

  % legend(conditionNames, 'Location','northwest','box','off');
  
 end

 xBox = [-100 -2 -2 -100];
yBox = [0 0 0.5 0.5];

h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey

h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
h.EdgeColor = 'none';  % remove border
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

    set(gca,'ylim',[0,6],'xlim',[-500,500],'box', 'off','tickdir','out',...
      'linewidth',1.5,'fontsize',12,'layer','top');
  xlabel('Time (ms)');
  ylabel('Amplitude (\muV)');
  title('GMFA after filtering');

   text(-0.3, 1.1, figLet{5}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

 %% Plot TEP time series

 subplot(2,3,1)

 for conX = 1:length(condition)

  meandata = mean(dataTEP.(condition{conX}),1);   
  h1(conX) = plot(EEG.times, meandata,'color',col(conX,:),'linewidth',1.5); hold on;
  plot([0,0],[-100,100],'k--');


  % legend(conditionNames, 'Location','northwest','box','off');
  
 end

set(gca,'ylim',[-10,10],'xlim',[-500,500],'box', 'off','tickdir','out',...
'linewidth',1.5,'fontsize',12,'layer','top');    
xlabel('Time (ms)');
  ylabel('Amplitude (\muV)');
  title('TEP before filtering');

     text(-0.3, 1.1, figLet{1}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)



  subplot(2,3,4)

 for conX = 1:length(condition)

  meandata = mean(dataTEPFilt.(condition{conX}),1);
  h1(conX) = plot(EEG.times, meandata,'color',col(conX,:),'linewidth',1.5); hold on;
  plot([0,0],[-100,100],'k--');

  % legend(conditionNames, 'Location','northwest','box','off');
  
 end
 
set(gca,'ylim',[-6,6],'xlim',[-500,500],'box', 'off','tickdir','out',...
'linewidth',1.5,'fontsize',12,'layer','top');    
xlabel('Time (ms)');
  ylabel('Amplitude (\muV)');
  title('TEP after filtering');

     text(-0.3, 1.1, figLet{4}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)


 %% Calculate GMFA for time periods
 
 timePeriods = [50,500];
 
 for conX = 1:length(condition)
     for tpX = 1:size(timePeriods,1)
         
         [~,t1] = min(abs(EEG.times-timePeriods(tpX,1)));
         [~,t2] = min(abs(EEG.times-timePeriods(tpX,2)));
         
         % gmfaOut = participant x condition x timeperiod
         gmfaOut(:,conX,tpX) = mean(dataAll.(condition{conX})(:,t1:t2),2);
         
     end
 end
 
 timePeriods = [-100,-2];
 
 for conX = 1:length(condition)
     for tpX = 1:size(timePeriods,1)
         
         [~,t1] = min(abs(EEG.times-timePeriods(tpX,1)));
         [~,t2] = min(abs(EEG.times-timePeriods(tpX,2)));
         
         % gmfaOut = participant x condition x timeperiod
         gmfaOutFilt(:,conX,tpX) = mean(dataAllFilt.(condition{conX})(:,t1:t2),2);
         
     end
 end

 subplot(2,3,3)
 tpX = 1;
 b = bar(mean(gmfaOut(:,:,tpX),1),'linewidth',1.5); hold on;
 b.FaceColor = 'flat';        % allow individual bar colours
b.CData = col(1:4,:);        % first 4 colours
 for P_IDX = 1:length(P_ID)

     plot(1:length(condition), gmfaOut(P_IDX,:,tpX),'-o',...
         'color',[0,0,0],'linewidth',1.5,'MarkerSize',3,'MarkerFaceColor', 'k'); hold on;

 end

     set(gca,'ylim',[0,6],'xlim',[0,5],'XTick', 1:4, ...
        'XTickLabel', conditionNames,'box','off','tickdir','out',...
        'linewidth',1.5,'fontsize',12);

ylabel('Amplitude (\muV)');
title('Step artifact');

     text(-0.3, 1.1, figLet{3}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

subplot(2,3,6)
tpX = 1;
b = bar(mean(gmfaOutFilt(:,:,tpX),1),'linewidth',1.5); hold on;
b.FaceColor = 'flat';        % allow individual bar colours
b.CData = col(1:4,:);        % first 4 colours
for P_IDX = 1:length(P_ID)

    plot(1:length(condition), gmfaOutFilt(P_IDX,:,tpX),'-o',...
         'color',[0,0,0],'linewidth',1.5,'MarkerSize',3,'MarkerFaceColor', 'k'); hold on;

end

     set(gca,'ylim',[0,3],'xlim',[0,5],'XTick', 1:4, ...
        'XTickLabel', conditionNames,'box','off','tickdir','out',...
        'linewidth',1.5,'fontsize',12);

ylabel('Amplitude (\muV)');
title('Filtering artifact');

     text(-0.3, 1.1, figLet{6}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

%% Save the figure
print(fig1,'-dpng',[pathFigures,'figure_acdc_comparison']);

%%
    
% Run some basic statistics for the third time point
clc;

% Monophasic vs biphasic
data1 = gmfaOut(:,[1,3]); % monophasic_highpass, monophasic_DC
data2 = gmfaOut(:,[2,4]); % biphasic_highpass, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p_pulseshape = ranksum(data1,data2);
fprintf('Mono vs bi; p = %.4f\n',p_pulseshape);

% AC vs DC
data1 = gmfaOut(:,[1,2]); % monophasic_highpass, biphasic_highpass
data2 = gmfaOut(:,[3,4]); % monophasic_DC, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p_filter = ranksum(data1,data2);
fprintf('AC vs DC; p = %.4f\n',p_filter);

% Monophasic vs biphasic
data1 = gmfaOutFilt(:,[1,3]); % monophasic_highpass, monophasic_DC
data2 = gmfaOutFilt(:,[2,4]); % biphasic_highpass, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p_pulseshapeFilt = ranksum(data1,data2);
fprintf('Mono vs bi (filtered); p = %.4f\n',p_pulseshapeFilt);

% AC vs DC
data1 = gmfaOutFilt(:,[1,2]); % monophasic_highpass, biphasic_highpass
data2 = gmfaOutFilt(:,[3,4]); % monophasic_DC, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p_filterFilt = ranksum(data1,data2);
fprintf('AC vs DC (filtered); p = %.4f\n',p_filterFilt);