
% SCRIPT_EVALUATE_CLASSIFICATION
% -------------------------------------------------------------------------
% Use this script to evaluate the performance of different classifiers
% -------------------------------------------------------------------------

config_evaluate_classification;

%% setup the environment

% load the labels
load(fullfile(root_path, 'labels.mat'));

% get the image source name
switch image_source
    case 'optic-disc'
        image_source = 'images-onh';
        image_tag = 'ONH';
    case 'full-image'
        image_source = 'images-fov';
        image_tag = 'FOV';
    case 'full-image-without-onh'
        image_source = 'images-fov-wo-onh';
        image_tag = 'FOV without ONH';
end

% encode classifier name
switch classifier
    case 'cnn'
        classifier_tag = ['CNN - ', image_tag];
end

% get input folder
input_scores_path = fullfile(results_path, strcat(classifier, '-', image_source));

% get filenames of the scores
scores_filenames = dir(fullfile(input_scores_path, '*.mat'));
scores_filenames = { scores_filenames.name };

%% plot ROC curve

% get all the scores
y_hat = zeros(length(scores_filenames), 1);
for i = 1 : length(scores_filenames)
    % load this scores
    load(fullfile(input_scores_path, scores_filenames{i}));
    % attach them to y_hat
    y_hat(i) = scores;
end

% get the ROC curve
[TPR,TNR,info] = vl_roc( 2*labels-1, y_hat);

% plot it
if ~exist('h', 'var')
    h = figure;
    my_legends = { [classifier_tag, ' - AUC=', num2str(info.auc)] };
else
    hold on;
    my_legends = cat(1, my_legends, { [classifier_tag, ' - AUC=', num2str(info.auc)] });
end
plot(1-TNR, TPR, 'LineWidth', 2)
legend(my_legends, 'Location', 'southeast');
xlabel('FPR (1 - Specificity)')
ylabel('TPR (Sensitivity)')
grid on
box on