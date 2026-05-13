clear; close all; clc;

% Load paths
load('pathInfo.mat');

% Set paths
DataOut = 'R:\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Marissa\Pipeline_Optimization\DATA_TEPOPT';

% Set conditions
cleanpipeline = {'standard','modified','modified_notch'};
cleanpipelineNames = {'Standard','Modified','ModifiedNotch'};

P_ID = {'P001','P002','P003','P004','P006','P007','P009','P010',...
        'P011','P012','P013','P014','P015','P016','P017'};

%% Calculate GMFA for different time periods


for P_IDX = 1:length(P_ID)

        for pipeX = 1:length(cleanpipeline)

            % Load Data

            filename = [P_ID{P_IDX}, '_Savepoint3_', cleanpipeline{pipeX}, '.set'];

            EEG = pop_loadset('filename',filename,'filepath',DataOut);

            % Extract GMFA
            EEG = pop_tesa_tepextract( EEG, 'GMFA' );
            EEG = pop_tesa_tepextract( EEG, 'ROI', 'elecs', {'F1'} );

            dataAll.(cleanpipeline{pipeX})(P_IDX,:) = EEG.GMFA.R1.tseries;
            dataAllTep.(cleanpipeline{pipeX})(P_IDX,:) = EEG.ROI.R1.tseries;

        end
end

%% Save the data

saveName = 'data_filtering_pipelines';
save([pathData,saveName,'.mat'],'dataAll','dataAllTep','EEG');


