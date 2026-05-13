% Run a permutation test comparing TEPs at different time points.
%
% Author: Nigel Rogasch

%% Settings
clc; clear; close all;

% % Load paths
load('pathInfo.mat');

% Load data
load([pathData,'ft_grandaverage_tepopt.mat']);
load([pathData,'neighbours_tepopt.mat']);

% Conditions to compare
comparisons = {'standard','modified_notch'};

% Time windows
timeWindow = [-0.11,-0.09;...
    0.036,0.055;...
    0.056,0.075;...
    0.11,0.13;...
    0.21,0.23];

%% Run analysis

for compi = 1:size(timeWindow,1)

    % Setting up our comparisons (e.g. L2 vs L4 etc.)
    D1 = grandAverage.(comparisons{1});
    D2 = grandAverage.(comparisons{2});

    %this is creating the settings for the stats. 2 levels: clustering and
    %permuations.
    cfg = [];
    cfg.channel     = {'all'};
    cfg.minnbchan        = 2; %minimum number of channels for cluster
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.alpha       = 0.05;
    cfg.avgovertime = 'yes'; %collapsing all time points down into single value. can change this between no and yes depending if you want time included
    cfg.latency     = timeWindow(compi,:);
    cfg.avgoverchan = 'no'; %can change this between no and yes depending if you want all channels included
    cfg.statistic   = 'depsamplesT';
    cfg.numrandomization = 5000;
    cfg.correctm    = 'cluster';
    cfg.method      = 'montecarlo';
    cfg.tail             = 0; % Two-tailed
    cfg.correcttail = 'prob'; % Correct probability values for two-tailed test
    cfg.clustertail      = 0; % Two-tailed
    cfg.neighbours  = neighbours;
    cfg.parameter   = 'individual';

    subj = size(D1.individual,1); %enter number of participants

    %design for within subject test
    design = zeros(2,2*subj);
    for i = 1:subj
        design(1,i) = i;
    end
    for i = 1:subj
        design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;

    cfg.design = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;

    %define variables for comparison
    seedDetails = rng('default');
    [stat] = ft_timelockstatistics(cfg, D1, D2);

    % Calculate the effect size
    if size(stat.posclusters,2) > 0
        if stat.posclusters(1).prob < 0.05
            chanN = stat.posclusterslabelmat == 1;

            cfg = [];
            cfg.channel     = {stat.label{chanN}};
            cfg.avgoverchan = 'yes';
            cfg.avgovertime = 'yes';
            cfg.method = 'analytic';
            cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD

            cfg.design = design;
            cfg.uvar  = 1;
            cfg.ivar  = 2;

            effect_avg = ft_timelockstatistics(cfg, D1, D2);
            cohensdPos = effect_avg.cohensd;
        else
            cohensdPos = NaN;
        end
    else
        cohensdPos = NaN;
    end
    
    if size(stat.negclusters,2) > 0
        if stat.negclusters(1).prob < 0.05
            chanN = stat.negclusterslabelmat == 1;

            cfg = [];
            cfg.channel     = {stat.label{chanN}};
            cfg.avgoverchan = 'yes';
            cfg.avgovertime = 'yes';
            cfg.method = 'analytic';
            cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD

            cfg.design = design;
            cfg.uvar  = 1;
            cfg.ivar  = 2;

            effect_avg = ft_timelockstatistics(cfg, D1, D2);
            cohensdNeg = effect_avg.cohensd;
        else
            cohensdNeg = NaN;
        end
    else
        cohensdNeg = NaN;
    end

    % Save the output
    saveName = sprintf('standard_vs_modified_%g_%g',timeWindow(compi,1)*1000,timeWindow(compi,2)*1000);
    save([pathStats,saveName,'.mat'],'stat','seedDetails','cohensdPos','cohensdNeg');

end

%% Read out the results
clc;

for compi = 1:size(timeWindow,1)
    
    % Load the results
    loadName = sprintf('standard_vs_modified_%g_%g',timeWindow(compi,1)*1000,timeWindow(compi,2)*1000);
    load([pathStats,loadName,'.mat']);
    
    % Positive cluster
    if size(stat.posclusters,2) > 0
        input1 = stat.posclusters(1).prob;
    else
        input1 = 1;
    end
    input2 = cohensdPos;

    % Negative cluster
    if size(stat.negclusters,2) > 0
        input3 = stat.negclusters(1).prob;
    else
        input3 = 1;
    end
    input4 = cohensdNeg;

    formatSpec = '%s vs %s: %g to %g: pos. p = %.3f, pos. cd = %.2f, neg. p = %.3f, neg. cd = %.2f\n';
    fprintf(formatSpec,comparisons{1},comparisons{2}, timeWindow(compi,1)*1000, timeWindow(compi,2)*1000,...
        input1,input2,input3,input4);
end