
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

% output folder
output_data_path = fullfile(pwd, 'results');

% classifier
%classifier = 'random-forest';
classifier = 'logistic-regression';

% validation metric
%validation_metric = 'auc';
validation_metric = 'acc';

% add cnn based features
add_cnn_features = false;
%cnn_features = 'transferred-features-images-onh';
%type_of_feature = 'prob';
%type_of_feature = 'features';

% feature extraction -----------

% number of centroids to learn for each of the classes
ks = 2:15;
% simulation scenario
simulation_scenario = 'SC2';