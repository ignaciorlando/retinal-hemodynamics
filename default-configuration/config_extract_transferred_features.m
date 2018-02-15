
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

% image source
%image_source = 'optic-disc';
%image_source = 'full-image';
image_source = 'full-image-without-onh';

% folder where the data is stored
root_folder = fullfile(pwd, 'data', database);

% cnn path
cnn_path = fullfile(pwd, 'cnn-models');

% output paths
output_path_features = fullfile(root_folder, 'transferred-features');
output_path_probabilities = fullfile(pwd, 'results', database);