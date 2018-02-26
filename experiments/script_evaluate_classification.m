% SCRIPT_EVALUATE_CLASSIFICATION
% -------------------------------------------------------------------------
% Use this script to evaluate the performance of different classifiers
% -------------------------------------------------------------------------

config_evaluate_classification;

%% setup the environment

% load the labels
load(fullfile(root_path, 'labels.mat'));

% first tag is the features used
switch features
    case 'transferred-features'
        input_folder_name = 'cnn';
        features_tag = 'CNN features learned from ';
    case 'bohf'
        input_folder_name = 'bohf';
        features_tag = 'BOHF ';
    case 'combined'
        input_folder_name = 'combined';
        features_tag = 'BOHF and CNN features learned from ';
end

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

% construct the input folder
switch classifier
    case 'cnn'
        input_folder_name = strcat(input_folder_name, '-', image_source);
        classifier_tag = 'CNN (off the shelf)';
    case 'logistic-regression'
        input_folder_name = strcat(input_folder_name, '-logistic-regression');
        if ~strcmp(features, 'bohf')
            input_folder_name = strcat(input_folder_name, '-transferred-features-', image_source, '-', type_of_feature);
        end
        classifier_tag = ['LogReg - ', features_tag, image_tag];
end

% initialize the input score path
input_scores_path = fullfile(results_path, input_folder_name);

% get filenames of the scores
scores_filenames = dir(fullfile(input_scores_path, '*.mat'));
scores_filenames = { scores_filenames.name };

%% plot ROC curve

% get all the scores
all_scores = zeros(length(scores_filenames), 1);
y_hat = zeros(length(scores_filenames), 1);
for i = 1 : length(scores_filenames)
    % load this scores
    load(fullfile(input_scores_path, scores_filenames{i}));
    % attach them to all_scores
    all_scores(i) = scores;
    % assign the class
    y_hat(i) = scores > 0.5;
end

% get the ROC curve
[TPR,TNR,info] = vl_roc( 2*labels-1, all_scores);

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

accuracy = sum(labels==y_hat) / length(labels);

% print accuracy and auc
disp(['AUC = ', num2str(info.auc)]);
disp(['Acc = ', num2str(accuracy)]);