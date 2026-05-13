% main_analysis.m runs all of the statistical analysis and generates the figures for
% the study:
%
% Step, drift, clipping, and filtering artifacts in TMS-EEG recordings
%
% Before running this script, ensure to update the file paths in:
% add_paths_toolboxes.m
%
% Also, make sure the current folder is set to the folder containting
% main_analysis.m
%
% Author: Nigel Rogasch

%% Clear the command window, workspace and figures

clc; clear; close all;

%% Set the paths

run(fullfile('code','add_paths_toolboxes.m'));

%% Step, drift and filtering artifact examples

% ### Real data example (individual in data 2) ###

% Generate figure demonstrating artifacts in real data [Requires raw data]
run('figure_step_artifact_example_individual.m');

% ### Simulations example ###

% Generate figure demonstrating artifacts in simulated data
run('figure_example_filtering_artifacts.m');

%% Online methods for minimising step artifacts (data 1)

% ### Clipping ###

% Generate figure comparing clipping across time (supp figure 1) and comparing clipping
% across different experimental set ups [Requires raw data]
run('figure_compare_clipping_across_conditions.m');

% ### Pulse shape and online filters ###

% Run a basic processing pipeline to compare 'raw' and minimally processed
% TEPs across different experimental settings [Requires raw data]
run('BaselineSteps_ACDC_short.m');

% Genarate a figure comparing outcomes [Requires raw data]
run('figure_compare_gmfa_acdc.m'); 

%% Offline methods for minimising filtering artifacts

% ### Simulations ###

% Simulate a ground truth TEP
run('generate_tep_ground_truth.m'); 

% Simulate a ground truth TEP embedded in real EEG data [Require raw data]
run('prepare_minimum_processed_individual_data_offset.m'); 
run('generate_real_tep_ground_truth_plus_step.m'); % [Requires raw data]

% Generate the filtering approaches to compare based embedded TEP data
run('real_step_filter_raw.m');
run('real_step_filter_demean.m');
run('real_step_filter_detrend.m');
run('real_step_filter_butter.m'); % (A, B)
run('real_step_filter_butter_demean.m');
run('real_step_filter_butter_detrend.m'); % (D)
run('real_step_filter_butter_modified.m');
run('real_step_filter_butter_modified_demean.m');
run('real_step_filter_butter_modified_detrend.m'); %(F)

% Compare the different butterworth variants to no step
run('compare_real_step_drift_butter_variants.m'); % (C) 

% Compare the different modified butterworth variants to no step
run('compare_real_step_drift_buttermod_variants.m'); % (E)

% Generate a figure comparing the butterworth and modified butterworth
% variants to no step
run('figure_compare_filtering_approaches.m');

% Generate a figure comparing the outcomes of different approaches to the
% absolute ground truth
run('figure_compare_real_step_drift_teps.m');

% ### Simulations with decay ###

% Simulate a ground truth TEP embedded in real EEG data plus decay
% [Requires raw data]
run('generate_real_tep_ground_truth_plus_decay.m'); 

% Generate the filtering approaches to compare based embedded TEP data with
% decay
run('real_decay_filter_raw.m');
run('real_decay_filter_butter.m');
run('real_decay_filter_butter_modified_detrend.m');

% Generate a figure comparing the outcomes of different approaches to the
% absolute ground truth in presence of decay
run('figure_compare_real_step_drift_decay_teps.m');

%% ### Comparison of cleaning pipelines: data 1 ###

% Run the standard processing pipeline on the ACDC data [Requires raw data]
run('StandardProcessing_ACDC_short.m');

% Run the robust detrending processing pipeline on the ACDC data [Requires
% raw data]
run('RobustDetrending_ACDC_short.m');

% Generate figure comparing outcomes across pipelines [Requires raw data]
run('figure_compare_cleaning_pipelines_acdc.m');

%% ### Comparison of cleaning pipelines: data 2 ###

% Run the standard processing pipeline TEPOPT data [Requires raw data]
run('StandardProcessing_TEPOPT.m');

% Manually adjust any missed bad channels for certain participants [Requires raw data]
run('StandardProcessing_TEPOPT_ManualBadChannel.m');

% Run the robust detrending from savepoint 2 [Requires raw data]
run('RobustDetrending_TEPOPT.m');

% Repeat robust detrending using a modified notch filter as well [Requires raw data]
run('RobustDetrending_TEPOPT_modnotch.m');

% Convert data to FieldTrip, prepare a neighbour file and run cluster-based
% permutation statistics [Requires raw data]
run('Convert_EEGLAB2Fieldtrip.m'); 
run('Prepare_Neighbour.m'); % [Requires raw data]
run('statistics_compare_standard_modified_fieldtrip.m');

% Generate figure comparing pipeline outcomes
run('Pipeline_Comparison_Calculate_GMFA_TEPOPT.m'); % [Requires raw data]
run('figure_compare_cleaning_pipelines_tepopt.m');
run('figure_compare_cleaning_pipelines_tepopt_ringing.m'); % Supplementary figure 2

%% End