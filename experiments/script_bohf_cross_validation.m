
% SCRIPT_BOHF_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script performs a full evaluation of the BOHF model on a given set.
% -------------------------------------------------------------------------

config_bohf_cross_validation;

%% preset variables 

% set the data path
input_data_path = fullfile(input_data_path, database);
% and the path for images
images_folder = fullfile(input_data_path, 'images');
% and the path with the hemodynamic simulations
simulations_path = fullfile(input_data_path, 'hemodynamic-simulation');

% load the labels
load(fullfile(input_data_path, 'labels.mat'));

% retrieve image filenames
image_filenames = dir(fullfile(images_folder, '*.png'));
image_filenames = { image_filenames.name };

% retrieve the simulation filenames
feature_map_filenames = dir(fullfile(simulations_path, strcat('*_', simulation_scenario, '_sol.mat')));
feature_map_filenames = { feature_map_filenames.name };

% lets use leave-one-out cross-validation
data_partition = cvpartition(length(feature_map_filenames), 'LeaveOut');

%% run cross validation!!

% initialize the array of scores for collecting each probability
scores = zeros(data_partition.NumTestSets, 1);

% iterate for each partition
for i = 1 : data_partition.NumTestSets
    
    fprintf( '========= Fold %d/%d =========\n', i, data_partition.NumTestSets);
    
    % divide data into training and test
    training_samples = feature_map_filenames(data_partition.training(i));
    training_labels = labels(data_partition.training(i));
    test_samples = feature_map_filenames(data_partition.test(i));
    test_labels = labels(data_partition.test(i));
    
    % identify the test index
    test_index = find(data_partition.test(i));
    
    % train the bag of hemodynamic features extractor
    disp('Identifying centroids');
    centroids = get_hemodynamic_centroids( simulations_path, training_samples, training_labels, k );
    
    % compute features for the training set based on these centroids
    disp('Extracting features on the training set');
    training_features = extract_bag_of_hemodynamic_features( simulations_path, training_samples, centroids, '', false );
    disp('Extracting features on the test set');
    test_features = extract_bag_of_hemodynamic_features( simulations_path, test_samples, centroids, '', false );
    
    % compact all the training features
    disp('Collecting all the training features within a single design matrix X');
    X = compact_features(training_features);
    % normalize the features
    training_mean = mean(X);
    training_std = std(X);
    X = bsxfun(@rdivide, bsxfun(@minus, X, training_mean), training_std);
    
    % normalize all the test features
    X_test = compact_features(test_features);
    X_test = bsxfun(@rdivide, bsxfun(@minus, X_test, training_mean), training_std);
    
    % train a classifier
    switch classifier
        
        case 'random-forest'
            % train a random forest
            fprintf('Training random forest classifier\n');
            model = train_random_forest(X, training_labels);
            % evaluate it
            [scores(test_index), ~] = classRF_predict_probabilities(X_test, model);
            
        otherwise
            error('Unsuported classifier. Please, use random-forest');
    end
    
end

% get the ROC curve
[TPR,TNR,info] = vl_roc( 2*labels-1, scores);
% plot it
if ~exist('h', 'var')
    h = figure;
    my_legends = { [classifier, ' - AUC=', num2str(info.auc)] };
else
    hold on;
    my_legends = cat(1, my_legends, { [classifier, ' - AUC=', num2str(info.auc)] });
end
plot(1-TNR, TPR, 'LineWidth', 2)
legend(my_legends, 'Location', 'southeast');
xlabel('FPR (1 - Specificity)')
ylabel('TPR (Sensitivity)')
grid on
box on