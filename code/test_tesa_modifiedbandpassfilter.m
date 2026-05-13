clear; close all; clc;

% Generate a dummy EEG structure
time = -1:0.001:1;
EEG.srate = 1000;
EEG.times = time*1000;
EEG.pnts = length(EEG.times);
EEG.xmin = -1;
EEG.xmax = 1;
EEG.trials = 1;
EEG.event.latency = 1001;
EEG.event.type = 'tms';
EEG.nbchan = 1;
EEG.data = ones(1,length(EEG.times));

% Remove artifact
EEG = pop_tesa_removedata( EEG, [-2 12] );

% Interpolate artifact
EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );

EEG1 = EEG;

% % Test tesa_modifiedbandpassfilter
% EEG = tesa_modifiedbandpassfilter(EEG,'lowCutoff',2);
% 
% plot(EEG.times,EEG.data);hold on;
% plot(EEG.times,EEG1.data);

% Test pop_tesa_modifiedbandpassfilter
[EEG, com] = pop_tesa_modifiedbandpassfilter(EEG);
% [EEG, com] = pop_tesa_modifiedbandpassfilter(EEG,'lowCutoff',2);

fprintf('Function passed\n');

eval(com);
fprintf('Function write out passed\n');
com

