
% SCRIPT_EVALUATE_CLASSIFICATION
% -------------------------------------------------------------------------
% Use this script to evaluate the performance of different classifiers
% -------------------------------------------------------------------------

config_evaluate_classification;

%% setup the environment

% load the labels
load(fullfile(root_path, 'labels.mat'));

% get filenames of the scores
scores_filenames = dir(fullfile(results_path, classifier, '*.mat'));
scores_filenames = sort_nat({ scores_filenames.name });

%% plot ROC curve

% get all the scores
y_hat = zeros(length(scores_filenames), 1);
for i = 1 : length(scores_filenames)
    % load this scores
    load(fullfile(results_path, classifier, scores_filenames{i}));
    % attach them to y_hat
    y_hat(i) = scores;
end

[TPR,TNR,info] = vl_roc( 2*labels-1, y_hat);
figure
plot(1-TNR, TPR)