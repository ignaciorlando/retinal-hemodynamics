
% SCRIPT_BOHF_CROSS_VALIDATION
% -------------------------------------------------------------------------
% This script performs a full evaluation of the BOHF model on a given set.
% -------------------------------------------------------------------------

config_bohf_cross_validation;

%% preset variables 

% set the random seed for k-means
rng(7);

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
y_hat = zeros(data_partition.NumTestSets, 1);

% iterate for each partition
for i = 1 : data_partition.NumTestSets
    
    fprintf( '========= Fold %d/%d =========\n', i, data_partition.NumTestSets);
    
    % separate the training and validation
    % collect the indices of the original training samples
    original_training_samples = find(data_partition.training(i));
    % 80% will be used for training
    n_training_samples = floor(length(original_training_samples) * 0.8);
    % use the first n_training_samples for training
    current_training_set = zeros(length(data_partition.training(i)), 1);
    current_training_set(original_training_samples(1:n_training_samples)) = 1;
    current_training_set = current_training_set > 0;
    % and the remaining for validation
    current_validation_set = zeros(length(data_partition.training(i)), 1);
    current_validation_set(original_training_samples(n_training_samples+1:end)) = 1;
    current_validation_set = current_validation_set > 0;
    
    % divide data into training 
    training_samples = feature_map_filenames(current_training_set);
    training_labels = labels(current_training_set);
    % ... validation
    validation_samples = feature_map_filenames(current_validation_set);
    validation_labels = labels(current_validation_set);
    % and test
    test_samples = feature_map_filenames(data_partition.test(i));
    test_labels = labels(data_partition.test(i));
    
    % identify the test index
    test_index = find(data_partition.test(i));
    
    % initialize the array of models for evaluating different k values
    models_for_each_k = cell(length(ks), 1);
    validation_aucs = zeros(length(ks), 1);
    
    % try different k values
    for j = 1 : length(ks)
    
        k = ks(j);
        disp(['Trying with k=', num2str(k)]);
        
        % train the bag of hemodynamic features extractor
        %disp('Identifying centroids');
        centroids = get_hemodynamic_centroids( simulations_path, training_samples, training_labels, k );

        if any(isnan(centroids(:)))
            disp('Skipping this k because it generates unvalid clusters');
            break
        end
        
        % compute features for the training set based on these centroids
        %disp('Extracting features on the training set');
        training_features = extract_bag_of_hemodynamic_features( simulations_path, training_samples, centroids, '', false );
        %disp('Extracting features on the validation set');
        validation_features = extract_bag_of_hemodynamic_features( simulations_path, validation_samples, centroids, '', false );
        
        % compact all the training features
        %disp('Collecting all the training features within a single design matrix X');
        X = compact_features(training_features);
        % normalize the features
        training_mean = mean(X);
        training_std = std(X);
        X = bsxfun(@rdivide, bsxfun(@minus, X, training_mean), training_std);
        % normalize all the validation features
        X_val = compact_features(validation_features);
        X_val = bsxfun(@rdivide, bsxfun(@minus, X_val, training_mean), training_std);
        
        % train a classifier
        switch classifier

            case 'random-forest'
                % train a random forest
                %fprintf('Training random forest classifier\n');
                model = train_random_forest(X, training_labels);
                model.training_mean = training_mean;
                model.training_std = training_std;
                model.centroids = centroids;
                % evaluate it
                [val_scores, ~] = classRF_predict_probabilities(X_val, model);
                % get the AUC value
                [~,~,info] = vl_roc( 2*validation_labels-1, val_scores);
                % collect the values
                models_for_each_k{j} = model;
                validation_aucs(j) = info.auc;

            otherwise
                error('Unsuported classifier. Please, use random-forest');
        end
        
    end
    
    % pick the best model
    [best_val_performance, idx] = max(validation_aucs);
    model = models_for_each_k{idx};
    k_best = ks(idx);
    disp(['Best model for k=', num2str(k_best), '(AUC=', num2str(best_val_performance), ')']);
        
    %disp('Extracting features on the test set');
    test_features = extract_bag_of_hemodynamic_features( simulations_path, test_samples, model.centroids, '', false );
    
    % normalize all the test features
    X_test = compact_features(test_features);
    X_test = bsxfun(@rdivide, bsxfun(@minus, X_test, model.training_mean), model.training_std);
    
    % train a classifier
    switch classifier
        
        case 'random-forest'
            % evaluate it
            [scores(test_index), y_hat(test_index)] = classRF_predict_probabilities(X_test, model);
            
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

fprintf('=================================\n');
fprintf('AUC = %d\n', info.auc);
fprintf('Acc = %d\n', sum(y_hat == labels)/length(y_hat));