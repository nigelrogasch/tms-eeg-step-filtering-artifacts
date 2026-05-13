% Compare different filtering approaches

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

%% Loop and plot RMSE

% Approach names
cleaningName = {'butter','butter_demean','butter_detrend'};
cleaningVar = {'butter','butterDemean','butterDetrend'};

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

cmap = brewermap(5,'Dark2');

fig1 = figure('color','w');

% Loop and plot
for cx = 1:length(cleaningVar)
     
    data = rmseAll.(cleaningVar{cx}).rmse;
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

legend(cleaningVar,'location','northwest');

%% Plot the outcomes from each of the filtering pipelines

fig2 = figure('color','w');

for cx = 1:length(cleaningVar)

    subplot(2,3,cx)
    
    for sx = 1:length(stepLevel)

        plot(time, mean(dataAll.(cleaningVar{cx}).(['step',num2str(stepLevel(sx))]),3)); hold on;
        
    end

    set(gca,'xlim',[-100,300]);
    xlabel('Time (ms)');
    ylabel('Amplitude (\muV)');

end

%% Compare step 10 between pipelines


fig3 = figure('color','w');

for cx = 1:length(cleaningVar)

    data = dataAll.(cleaningVar{cx}).('step10');

    errMean = mean(data,3);
    errSem = std(data, [], 3) / sqrt(size(data,3));

    % Shaded area
    fill([time, fliplr(time)], ...
        [errMean - errSem, fliplr(errMean + errSem)], ...
        cmap(cx,:),'EdgeColor', 'none', 'FaceAlpha', 0.3); hold on;
    
    plot(time, errMean,'Color',cmap(cx,:)); hold on; 
      

end

% Load the absolute ground truth
tep_gt_abs = load('ground_truth_tep.mat');

plot(tep_gt_abs.time*1000,tep_gt_abs.tep_gt,'k-','linewidth',1.5);

set(gca,'xlim',[-100,300]);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');

%%

% Save the data
save([pathData,'real_filter_butter_all'],'rmseAll','dataAll','time');


