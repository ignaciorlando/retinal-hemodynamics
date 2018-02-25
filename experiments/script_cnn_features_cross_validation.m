
% SCRIPT_CNN_FEATURES_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script performs a full evaluation of the CNN model on a given set.
% -------------------------------------------------------------------------

config_cnn_features_cross_validation;

%% preset variables 

% set the random seed for k-means
rng(7);

% set the data path
input_data_path = fullfile(input_data_path, database);
% and the path for images
images_folder = fullfile(input_data_path, 'images');

% load the labels
load(fullfile(input_data_path, 'labels.mat'));

% retrieve image filenames
image_filenames = dir(fullfile(images_folder, '*.png'));
image_filenames = { image_filenames.name };

% retrieve the cnn features, if necessary
% set the path for collecting pre-computed features
cnn_features_path = fullfile(input_data_path, cnn_features);
cnn_features_filenames = dir(fullfile(cnn_features_path, strcat('*-', type_of_feature, '.mat')));
cnn_features_filenames = { cnn_features_filenames.name };

% lets use leave-one-out cross-validation
data_partition = cvpartition(length(cnn_features_filenames), 'LeaveOut');

%% run cross validation!!

% initialize the array of scores for collecting each probability
scores = zeros(data_partition.NumTestSets, 1);
y_hat = zeros(data_partition.NumTestSets, 1);

% iterate for each partition
for i = 1 : data_partition.NumTestSets
    
    fprintf( '========= Fold %d/%d =========\n', i, data_partition.NumTestSets);
    
    % separate the training and validation
    
    % collect the indices of the original training samples and randomly
    % shuffle them
    original_training_idx = find(data_partition.training(i));
    original_training_idx = original_training_idx(randperm(length(original_training_idx)));
    original_training_labels = labels(original_training_idx);
    % identify the labels
    unique_labels = unique(original_training_labels);
    % initialize the training and validation sets
    current_training_set = zeros(length(data_partition.training(i)), 1);
    current_validation_set = zeros(length(data_partition.training(i)), 1);
    
    % ensure a similar distribution of each sample
    for l_id = 1 : length(unique_labels)
       
        % get the training idx associated with current label
       current_labels_original_training_idx = original_training_idx(original_training_labels == unique_labels(l_id));
       % 70% will be used for training
       n_training_samples = floor(length(current_labels_original_training_idx) * 0.7);       
       % use the first n_training_samples for training
       current_training_set(current_labels_original_training_idx(1:n_training_samples)) = 1;
       % and the remaining for validation
       current_validation_set(current_labels_original_training_idx(n_training_samples+1:end)) = 1;
    end
    % turn it to logical
    current_training_set = current_training_set > 0;
    current_validation_set = current_validation_set > 0;
    
    % divide data into training 
    training_cnn_samples = cnn_features_filenames(current_training_set);
    training_labels = labels(current_training_set);
    % ... validation
    validation_cnn_samples = cnn_features_filenames(current_validation_set);
    validation_labels = labels(current_validation_set);
    % and test
    test_cnn_samples = cnn_features_filenames(data_partition.test(i));
    test_labels = labels(data_partition.test(i));
    
    % identify the test index
    test_index = find(data_partition.test(i));
    
    % get the training features
    X = retrieve_cnn_features( cnn_features_path, training_cnn_samples );
    % normalize the features
    training_mean = mean(X);
    training_std = std(X) + eps;
    X = bsxfun(@rdivide, bsxfun(@minus, X, training_mean), training_std);
        
    % normalize all the validation features
    X_val = retrieve_cnn_features( cnn_features_path, validation_cnn_samples );
    X_val = bsxfun(@rdivide, bsxfun(@minus, X_val, training_mean), training_std);
                    
    % train a logistic regression classifier
    model = train_logistic_regression_classifier(X, training_labels, X_val, validation_labels, validation_metric);
    model.training_mean = training_mean;
    model.training_std = training_std;

    % extract test features
    X_test = retrieve_cnn_features( cnn_features_path, test_cnn_samples );
    X_test = bsxfun(@rdivide, bsxfun(@minus, X_test, model.training_mean), model.training_std);

    % evaluate it
    [scores(test_index), y_hat(test_index)] = predict_with_logistic_regression(X_test, model);
    
end

% turn logits into probabilities
scores = exp(scores) ./ (1 + exp(scores));
        
% get the ROC curve
[TPR,TNR,info] = vl_roc( 2*labels-1, scores);
% plot it
if ~exist('h', 'var')
    h = figure;
    my_legends = { ['Transferred CNN features - AUC=', num2str(info.auc)] };
else
    hold on;
    my_legends = cat(1, my_legends, { ['Transferred CNN features - AUC=', num2str(info.auc)] });
end
plot(1-TNR, TPR, 'LineWidth', 2)
legend(my_legends, 'Location', 'southeast');
xlabel('FPR (1 - Specificity)')
ylabel('TPR (Sensitivity)')
grid on
box on

fprintf('=================================\n');
fprintf('AUC = %d\n', info.auc);
fprintf('Acc = %d\n', sum(y_hat == labels)/length(y_hat));

%% save the results

% rename scores variable
all_scores = scores;
% create a tag for the experiment
output_tag = strcat('cnn-logistic-regression-', cnn_features, '-', type_of_feature);
% update the output path
output_data_path = fullfile(output_data_path, database, output_tag);
mkdir(output_data_path);
% save each score separately
for i = 1 : length(image_filenames)
    scores = all_scores(i);
    current_filename = image_filenames{i};
    save(fullfile(output_data_path, strcat(current_filename(1:end-3), 'mat')), 'scores');
end