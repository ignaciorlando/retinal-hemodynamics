function [ centroids ] = get_hemodynamic_centroids( root_folder, feature_maps_filenames, labels, k )
%GET_HEMODYNAMIC_CENTROIDS Summary of this function goes here
%   Detailed explanation goes here

    % identify different classes in the labels vector
    unique_labels = unique(labels);
    % identify the number of hemodynamic features
    loaded_file = load(fullfile(root_folder, feature_maps_filenames{1}));
    input_size = size(loaded_file.sol);
    n_features = input_size(3) - 1;
    image_size = input_size(1:2);
    
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
            % use the fifth coordinate (the skeletonization) to identify
            % the centerlines that will be characterized
            centerlines = current_feature_map.sol(:,:,5) > 0;
            
            % initialize the current design matrix
            current_X = zeros(length(find(centerlines(:))), n_features);
            % and collect all the features
            for f = 1 : n_features
                % get current feature
                current_feature_map_f = current_feature_map.sol(:,:,f);
                % add it to the design matrix
                current_X(:,f) = current_feature_map_f(centerlines);
            end
            
            % normalize using mean and standard deviation
            current_mean = mean(current_X);
            current_std = std(current_X);
            current_X = bsxfun(@rdivide, bsxfun(@minus, current_X, current_mean), current_std);
            
            % and now concatenate this to the big design matrix
            X = cat(1, X, current_X);
            
        end

        % run a k-means clustering method to identify the centroids
        [ ~, centroids(start_idx:k*i,:) ] = kmeans(X, k, 'MaxIter', 10000);
        % update start idx
        start_idx = k*i + 1;
        
    end

end

