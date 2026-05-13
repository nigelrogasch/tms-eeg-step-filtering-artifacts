clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Set paths
DataOut = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_ACDC';

% Set conditions
condition = {'monophasic_highpass','biphasic_highpass','monophasic_DC','biphasic_DC'};
% condition = {'monophasic_highpass','monophasic_DC','biphasic_highpass','biphasic_DC'};
conditionNames = {'Monophasic AC-coupled','Biphasic AC-coupled','Monophasic DC-coupled','Biphasic DC-coupled'};
conditionNames2 = {'AC Mono','AC Bi','DC Mono','DC Bi'};

cleanpipeline = {'cleanedStandard','cleanedRobustdetrend'};
cleanpipelineNames = {'Standard','Modified'};

P_ID = {'P002','P004','P012','P014'};

%% Calculate GMFA for different time periods


for P_IDX = 1:length(P_ID)

    for conX = 1:length(condition)

        for pipeX = 1:length(cleanpipeline)

            % Load Data

            filename = [P_ID{P_IDX}, '_', condition{conX}, '_', cleanpipeline{pipeX}, '_short.set'];

            EEG = pop_loadset('filename',filename,'filepath',DataOut);

            % Extract GMFA
            EEG = pop_tesa_tepextract( EEG, 'GMFA' );

            dataAll.(condition{conX}).(cleanpipeline{pipeX})(P_IDX,:) = EEG.GMFA.R1.tseries;

            % Find the F1 electrode
            idx = find(strcmpi({EEG.chanlocs.labels}, 'Fz'));
            dataTEP.(condition{conX}).(cleanpipeline{pipeX})(P_IDX,:) = mean(EEG.data(idx,:,:),3);

        end
    end
end

%% Plot GMFA Time Series 

fig1 = figure('color', 'w');
set(gcf,'position',[100,300,1350,515]);

% Colours
col = tab20;
col = col([2 1 6 5 4 3 8 7],:);

% Plot TEP

num = [1,2,3,4];
figLet = {'A','B','C','D'};

n = 1; 
for conX = 1:length(condition)
    subplot(2,6,num(conX))
    for pipeX = 1:length(cleanpipeline)
        meandata = mean(dataTEP.(condition{conX}).(cleanpipeline{pipeX}),1);
        plot(EEG.times, meandata,'linewidth',1.5,'Color',col(n,:)); hold on;
        n = n + 1;
    end

    plot([0 0],[-12 12],'k--');
    set(gca,'ylim',[-12,12],'xlim',[-250,250],'box', 'off','tickdir','out',...
        'linewidth',1.5,'fontsize',12);
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    title(conditionNames2{conX});

    % legend(cleanpipelineNames, 'Location','northwest','box','off');

     text(-0.5, 1.07, figLet{conX}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

end

% Plot GMFA

num = [9,10,11,12];
num = [7,8,9,10];
figLet = {'E','F','G','H'};

n = 1; 
for conX = 1:length(condition)
    subplot(2,6,num(conX))
    for pipeX = 1:length(cleanpipeline)
        meandata = mean(dataAll.(condition{conX}).(cleanpipeline{pipeX}),1);
        plot(EEG.times, meandata,'linewidth',1.5,'Color',col(n,:)); hold on;
        n = n+1;
    end

    xBox = [-100 -2 -2 -100];
    yBox = [0 0 0.5 0.5];

    h = patch(xBox, yBox, [0.7 0.7 0.7]);  % grey

    h.FaceAlpha = 0.3;     % transparency (0 = invisible, 1 = solid)
    h.EdgeColor = 'none';  % remove border
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';

    plot([0 0],[0 6],'k--');
    set(gca,'ylim',[0,8],'xlim',[-250,250],'box', 'off','tickdir','out',...
        'linewidth',1.5,'fontsize',12);
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');
    % title(conditionNames2{conX});

    lgd = legend({'Standard','Modified'}, 'Location','northwest','box','off','fontsize',10);
    lgd.ItemTokenSize = [10 10];

    % legend(cleanpipelineNames, 'Location','northwest','box','off');

     text(-0.5, 1.07, figLet{conX}, ...
    'Units','normalized', ...
    'FontWeight','bold', ...
    'FontSize',16)

end

% Baseline period
timePeriods = [-100,-2];

for pipeX = 1:length(cleanpipeline)
    for conX = 1:length(condition)
        for tpX = 1:size(timePeriods,1)

            [~,t1] = min(abs(EEG.times-timePeriods(tpX,1)));
            [~,t2] = min(abs(EEG.times-timePeriods(tpX,2)));

            % gmfaOut = participant x condition x timeperiod
            gmfaOutPre.(cleanpipeline{pipeX})(:,conX,tpX) = mean(dataAll.(condition{conX}).(cleanpipeline{pipeX})(:,t1:t2),2);

        end
    end
end

% Example data (replace with your own)
% Rows = participants, Columns = conditions
pipeline1 = gmfaOutPre.cleanedStandard;  % 4 participants × 4 conditions
pipeline2 = gmfaOutPre.cleanedRobustdetrend;

nConds = size(pipeline1, 2);
nSubs  = size(pipeline1, 1);

% Calculate means
mean1 = mean(pipeline1, 1);
mean2 = mean(pipeline2, 1);

% % Set up figure
% figure; 
hold on;

% Bar positions
x = 1:nConds;
barWidth = 0.35;

subplot(1,3,3)


% Plot bars
hL(1) = bar(x - barWidth/2, mean1, barWidth, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'k'); hold on; % blue
hL(2) = bar(x + barWidth/2, mean2, barWidth, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'k'); hold on; % red

hL(1).FaceColor = 'flat';        % allow individual bar colours
hL(1).CData = col([1 3 5 7],:);
hL(2).FaceColor = 'flat';        % allow individual bar colours
hL(2).CData = col([2 4 6 8],:);

% legend(cleanpipelineNames, 'Location', 'Best')

% Overlay individual participant data
for s = 1:nSubs
    for c = 1:nConds
        % X positions for the two bars of this condition
        x_pair = [x(c) - barWidth/2, x(c) + barWidth/2];
        y_pair = [pipeline1(s,c), pipeline2(s,c)];
        plot(x_pair, y_pair, '-o', 'Color', 'k', 'MarkerFaceColor', 'k', 'LineWidth', 1.5,'MarkerSize',3); hold on;
    end
end

% Beautify plot
xlim([0.5 nConds + 0.5])
xticks(1:nConds)
xticklabels(conditionNames2) % Edit as needed
ylabel('Amplitude (\muV)')
% legend(cleanpipelineNames, 'Location', 'northeast')
title('Filtering artifacts')
box on
set(gca, 'FontSize', 12,'linewidth',1.5,'box','off','tickdir','out')

 text(-0.2, 1.03, 'I', ...
'Units','normalized', ...
'FontWeight','bold', ...
'FontSize',16)

hold off;

% Save the figure
print(fig1,'-dpng',[pathFigures,'figure_acdc_pipeline_comparison']);

%%

% % Post period
% timePeriods = [15,100];
% 
% for pipeX = 1:length(cleanpipeline)
%     for conX = 1:length(condition)
%         for tpX = 1:size(timePeriods,1)
% 
%             [~,t1] = min(abs(EEG.times-timePeriods(tpX,1)));
%             [~,t2] = min(abs(EEG.times-timePeriods(tpX,2)));
% 
%             % gmfaOut = participant x condition x timeperiod
%             gmfaOutPost.(cleanpipeline{pipeX})(:,conX,tpX) = mean(dataAll.(condition{conX}).(cleanpipeline{pipeX})(:,t1:t2),2);
% 
%         end
%     end
% end
% 
% % Example data (replace with your own)
% % Rows = participants, Columns = conditions
% pipeline1 = gmfaOutPost.cleanedStandard;  % 4 participants × 4 conditions
% 
% pipeline2 = gmfaOutPost.cleanedRobustdetrend;
% 
% nConds = size(pipeline1, 2);
% nSubs  = size(pipeline1, 1);
% 
% % Calculate means
% mean1 = mean(pipeline1, 1);
% mean2 = mean(pipeline2, 1);
% 
% % Set up figure
% figure; hold on;
% 
% % Bar positions
% x = 1:nConds;
% barWidth = 0.35;
% 
% % Plot bars
% b1 = bar(x - barWidth/2, mean1, barWidth, 'FaceColor', [0 0.447 0.741], 'EdgeColor', 'none'); % blue
% b2 = bar(x + barWidth/2, mean2, barWidth, 'FaceColor', [0.85 0.325 0.098], 'EdgeColor', 'none'); % red
% 
% % Overlay individual participant data
% for s = 1:nSubs
%     for c = 1:nConds
%         % X positions for the two bars of this condition
%         x_pair = [x(c) - barWidth/2, x(c) + barWidth/2];
%         y_pair = [pipeline1(s,c), pipeline2(s,c)];
%         plot(x_pair, y_pair, '-o', 'Color', [0.5 0.5 0.5 0.5], 'MarkerFaceColor', 'w', 'LineWidth', 1);
%     end
% end
% 
% % Beautify plot
% xlim([0.5 nConds + 0.5])
% xticks(1:nConds)
% xticklabels(conditionNames2) % Edit as needed
% ylabel('Value')
% legend([b1 b2], cleanpipelineNames, 'Location', 'Best')
% title('Comparison of Pipelines Across Conditions (15 to 100 ms)')
% box on
% set(gca, 'FontSize', 12)
% 
% hold off;

%% Stats

clc;

% AC vs DC - standard  - pre
data1 = gmfaOutPre.cleanedStandard(:,[1,2]); % monophasic_highpass, biphasic_highpass
data2 = gmfaOutPre.cleanedStandard(:,[3,4]); % monophasic_DC, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p = ranksum(data1,data2);
fprintf('AC vs DC (standard), pre ; p = %.4f\n',p);

% AC vs DC - robust detrend - pre 
data1 = gmfaOutPre.cleanedRobustdetrend(:,[1,2]); % monophasic_highpass, monophasic_DC
data2 = gmfaOutPre.cleanedRobustdetrend(:,[3,4]); % biphasic_highpass, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p = ranksum(data1,data2);
fprintf('AC vs DC (modified), pre; p = %.4f\n',p);


% standard vs robust - AC - pre
data1 = gmfaOutPre.cleanedStandard(:,[1,2]); % monophasic_highpass, biphasic_highpass
data2 = gmfaOutPre.cleanedRobustdetrend(:,[1,2]); % monophasic_highpass, biphasic_highpass

data1 = data1(:);
data2 = data2(:);

p = ranksum(data1,data2);
fprintf('standard vs modified (AC), pre ; p = %.4f\n',p);

% standard vs robust - DC - pre
data1 = gmfaOutPre.cleanedStandard(:,[3,4]); % monophasic_DC, biphasic_DC
data2 = gmfaOutPre.cleanedRobustdetrend(:,[3,4]); % monophasic_DC, biphasic_DC

data1 = data1(:);
data2 = data2(:);

p = ranksum(data1,data2);
fprintf('standard vs modified (DC), pre ; p = %.4f\n',p);

