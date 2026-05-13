% Test tesa_modifiedbandpassfilter.m



% Load the data
EEG = pop_loadset('filename','test_dataset.set','filepath','R:\\Low_Cost_Storage\\healthsciences\\SPRH\\NeuroPAD\\projects\\2025-tms-eeg-step-artifact\\data\\');

% Settings
epochTimespan = [EEG.xmin,EEG.xmax];
artifactTimespan = EEG.tmscut.cutTimesTMS * 0.001;
bandpassFreqSpan = [1,80];
filterPrePostExtrapolationDurations = [0,0];

% Trial the filter
timeToExtend = 0.5;
maxTimeToExtend = min(abs(epochTimespan - artifactTimespan*3));
timeToExtend = min(timeToExtend, maxTimeToExtend);
EEG =tesa_modifiedbandpassfilter(EEG,...
	'piecewiseTimeToExtend', timeToExtend,...
	'lowCutoff', bandpassFreqSpan(1),...
	'artifactTimespan', artifactTimespan*3,...
	'prePostExtrapolationDurations', filterPrePostExtrapolationDurations,...
    'doDebug',true);