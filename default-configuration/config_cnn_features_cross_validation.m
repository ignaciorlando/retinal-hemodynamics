
% CONFIG_CNN_FEATURES_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script is called by script_cnn_features_cross_validation to setup 
% the  variables required for running a full evaluation of the CNN model 
% on a given set.
% -------------------------------------------------------------------------

% database used for the experiments
database = 'LeuvenEyeStudy';

% input folder
input_data_path = fullfile(pwd, 'data');

% output folder
output_data_path = fullfile(pwd, 'results');

% validation metric
%validation_metric = 'auc';
validation_metric = 'acc';

% type of cnn based features
cnn_features = 'transferred-features-images-onh';
%type_of_feature = 'prob';
type_of_feature = 'features';