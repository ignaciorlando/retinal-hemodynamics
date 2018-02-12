
% CONFIG_EVALUATE_CLASSIFICATION
% -------------------------------------------------------------------------
% This script is called by script_evaluate_classification to setup the
% variables for comparing the performance of different classifiers.
% -------------------------------------------------------------------------

% database name
database = 'LeuvenEyeStudy';

% data path
root_path = fullfile(pwd, 'data', database);

% results path
results_path = fullfile(pwd, 'results', database);

% classifier
classifier = 'cnn';

% features
% (if classifier is cnn, this value will be ignored)
features = 'transferred-features';
