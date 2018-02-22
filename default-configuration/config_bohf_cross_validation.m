
% CONFIG_BOHF_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script is called by script_bohf_cross_validation to setup the 
% variables required for running a full evaluation of the BOHF model on a 
% given set.
% -------------------------------------------------------------------------

% database used for the experiments
database = 'LeuvenEyeStudy';

% input folder
input_data_path = fullfile(pwd, 'data');

% classifier
classifier = 'random-forest';

% feature extraction -----------

% number of centroids to learn for each of the classes
k = 10;
% simulation scenario
simulation_scenario = 'SC2';