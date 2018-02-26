function [ centroids ] = get_hemodynamic_centroids( root_folder, feature_maps_filenames, labels, k )
%GET_HEMODYNAMIC_CENTROIDS Summary of this function goes here
%   Detailed explanation goes here

    % call to config_hemo_var_idx to get the ids of the masks
    config_hemo_var_idx;

    % identify different classes in the labels vector
    unique_labels = unique(labels);
    % identify the number of hemodynamic features
    loaded_file = load(fullfile(root_folder, feature_maps_filenames{1}));
    % prepare an array of the useful features
    to_preserve = ones(size(loaded_file.sol, 3), 1);
    to_preserve(HDidx.mask) = 0;
    to_preserve(HDidx.r) = 0;
    to_preserve = logical(to_preserve);
    % identify the number of hemodynamic features
    n_features = length(find(to_preserve));
    
    start_idx = 1;
    
    % k is the number of centroids per label, so initialize a vector of
    % centroids
    centroids = zeros(k * length(unique_labels), n_features);
    
    % iterate for each class
    for i = 1 : length(unique_labels)
    
        % get current class
        current_class = unique_labels(i);
        % identify the images with that class
        current_feature_maps_filenames = feature_maps_filenames(labels == current_class);
        
        % initialize the design matrix
        X = [];
        
        % append the non-zero features
        for j = 1 : length(current_feature_maps_filenames)
            
            % get current feature map
            current_feature_map = load(fullfile(root_folder, current_feature_maps_filenames{j}));
            % use the fifth coordinate to identify the POIs
            to_mask = current_feature_map.sol(:,:,HDidx.mask) > 1;
            
            % remove useless variables from current_feature_map
            current_feature_map.sol = current_feature_map.sol(:,:,to_preserve);
            
            % initialize the current design matrix
            current_X = zeros(length(find(to_mask(:))), n_features);
            % and collect all the features
            for f = 1 : n_features
                % get current feature
                current_feature_map_f = current_feature_map.sol(:,:,f);
                % add it to the design matrix
                current_X(:,f) = current_feature_map_f(to_mask);
            end
            
            % normalize using mean and standard deviation
            current_mean = mean(current_X);
            current_std = std(current_X);
            current_X = bsxfun(@rdivide, bsxfun(@minus, current_X, current_mean), current_std + eps);
            
            % and now concatenate this to the big design matrix
            X = cat(1, X, current_X);
            
        end

        % run a k-means clustering method to identify the centroids
        [~, current_centroids] = kmeans_varpar(X', k);
        centroids(start_idx:k*i,:) = current_centroids';
        % update start idx
        start_idx = k*i + 1;
        
    end

end

