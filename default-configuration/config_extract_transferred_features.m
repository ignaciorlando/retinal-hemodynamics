
% CONFIG_EXTRACT_TRANSFERRED_FEATURES
% -------------------------------------------------------------------------
% This script is called by script_extract_transferred_features
% to setup parameters for extracting features derived from a pre-trained 
% CNN.
% -------------------------------------------------------------------------

% database
%database = 'RITE-training';
%database = 'RITE-test';
database = 'LeuvenEyeStudy';

% folder where the data is stored
root_folder = fullfile(pwd, 'data', database);

% cnn filename (full path to the deployed network)
cnn_filename = fullfile(pwd, 'cnn-models', 'net-deployed.mat');

% output feature path
output_path = fullfile(root_folder, 'transferred-features');