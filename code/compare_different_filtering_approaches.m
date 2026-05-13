% Compare different filtering approaches

%% Reset
clear; close all; clc;

% Load paths
load('pathInfo.mat');

%% Loop and plot RMSE

% Approach names
cleaningName = {'butter','butter_modified','butter_modified_demean','butter_modified_detrend'};
cleaningVar = {'butter','butterMod','butterModDemean','butterModDetrend'};

% Loop and save the rmse
for cx = 1:length(cleaningName)

    % Load the data
    load(['filter_',cleaningName{cx},'.mat']);

    % Save the output
    rmseAll.(cleaningVar{cx}).rmse = rmse;
    rmseAll.(cleaningVar{cx}).stepLevel = stepLevel;

end

%%

fig = figure('color','w');

% Loop and plot
for cx = 1:length(cleaningVar)

    plot(rmseAll.(cleaningVar{cx}).stepLevel,rmseAll.(cleaningVar{cx}).rmse,'.-'); hold on;

end

set(gca,'xlim',[-0.5,5.5],'tickdir','out','box','off');
xlabel('Step artifact amplitude (\muV)');
ylabel('Root mean square error (\muV)');

legend(cleaningVar,'location','northwest');
