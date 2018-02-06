function [ centroids ] = get_hemodynamic_centroids( root_folder, feature_maps_filenames, labels, k )
%GET_HEMODYNAMIC_CENTROIDS Summary of this function goes here
%   Detailed explanation goes here

    % identify different classes in the labels vector
    unique_labels = unique(labels);
    % identify the number of hemodynamic features
    loaded_file = load(fullfile(root_folder, feature_maps_filenames{1}));
    input_size = size(loaded_file.sol);
    n_features = input_size(3);
    image_size = input_size(1:2);
    
    % k is the number of centroids per label, so initialize a vector of
    % centroids
    centroids = zeros(k * length(unique_labels), n_features);
    
    for f = 1 : n_features
    
        start_idx = 1;
        
        % iterate for each class
        for i = 1 : length(unique_labels)

            % get current class
            current_class = unique_labels(i);
            % identify the images with that class
            current_feature_maps_filenames = feature_maps_filenames(labels == current_class);

            % create a huge matrix with all the features that are different
            % than zero
            training_features = [];
            for j = 1 : length(current_feature_maps_filenames)
                % get current feature map
                current_feature_map = load(fullfile(root_folder, current_feature_maps_filenames{j}));
                % get current feature
                current_feature_map = current_feature_map.sol(:,:,f);
                % remove the elements with 0 values
                current_feature_map = current_feature_map(current_feature_map > 0);
                % concatenate in training features
                training_features = cat(1, training_features, current_feature_map);
            end
            
            % run a k-means clustering method
            [~, centroids(start_idx:k*i,f)] = kmeans(training_features, k);
            % update start idx
            start_idx = k*i + 1;
            
        end
        
    end

end

