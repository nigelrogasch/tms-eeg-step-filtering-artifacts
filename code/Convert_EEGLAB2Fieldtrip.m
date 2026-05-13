% ##### CONVERT EEGLAB TO FIELDTRIP AND STORE IN GRAND AVERAGE STRUCTURE #####

% This script converts individual EEGLAB files in to FieldTrip files and
% stores the data in a grand average structures according to
% pipeline.
% Inputs are final cleaned EEGLAB data files

% Author: Nigel Rogasch, University of Adelaide

clear;

% Set paths
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_TEPOPT';
StatsOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\projects\2025-tms-eeg-step-artifact\data\';

% Set conditions
cleanpipeline = {'standard','modified_notch'};
cleanpipelineNames = {'Standard','Modified'};

P_ID = {'P001','P002','P003','P004','P006','P007','P009','P010',...
    'P011','P012','P013','P014','P015','P016','P017'};


%% CONVERT FILES FROM EEGLAB TO FIELDTRIP

for P_IDX = 1:length(P_ID)
    for pipeX = 1:length(cleanpipeline)

        % Load Data

        filename = [P_ID{P_IDX}, '_Savepoint3_', cleanpipeline{pipeX}, '.set'];

        EEG = pop_loadset('filename',filename,'filepath',DataOut);

        EEG.icachansind = [];

        %convert to fieldtrip
        ftData = eeglab2fieldtrip(EEG, 'timelockanalysis');
        ftData.dimord = 'chan_time';

        %store data
        allData.(cleanpipeline{pipeX}){P_IDX} = ftData;

        fprintf('%s''s data converted from eeglab to fieldtrip\n', P_ID{P_IDX});

    end
end

%% CREATE GRAND AVERAGE FOR EACH CONDITION AND STORE

for pipeX = 1:length(cleanpipeline)

    %Perform grand average
    cfg=[];
    cfg.keepindividual = 'yes';

    grandAverage.(cleanpipeline{pipeX}) = ft_timelockgrandaverage(cfg,allData.(cleanpipeline{pipeX}){:});

end


%set filename
filename = 'ft_grandaverage_tepopt';

%Save data
save([StatsOut,filename],'grandAverage');