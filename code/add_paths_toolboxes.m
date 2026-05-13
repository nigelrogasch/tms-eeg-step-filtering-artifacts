% Sets the correct paths. Run at the start before running the other scripts
%
% Author: Nigel Rogasch

%% Add paths

% Path to project (modify as required)
pathIn = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\projects\2025-tms-eeg-step-artifact\';

% Create the required paths for the folders
pathData = [pathIn,'data\'];
pathFigures = [pathIn,'figures\'];
pathCode = [pathIn,'code\'];
pathStats = [pathIn,'stats\'];

% Add the paths
addpath(pathIn);
addpath(pathData);
addpath(pathFigures);
addpath(pathCode);
addpath(pathStats);

% Save the paths texts for use in scripts
save([pathData,'pathInfo.mat'], 'pathIn','pathData','pathFigures','pathCode','pathStats');

%% Load the toolboxes

% Path to toolboxes (% Modify as required)
pathToolbox = '\\uofa\resources\Low_Cost_Storage\healthsciences\SPRH\NeuroPAD\Shared_resources\MATLAB Toolboxes\';

% Set the path to EEGLAB
addpath([pathToolbox,'eeglab2023.0']);
eeglab;close;

% Set the path to BrewerMap
addpath([pathToolbox,'BrewerMap-3.2.5']);

% Set the path to MatPlotLib
addpath([pathToolbox,'MatPlotLib']);

% Set the path to Fieldtrip
addpath([pathToolbox,'fieldtrip-20250114']);
ft_defaults;

%% Finish