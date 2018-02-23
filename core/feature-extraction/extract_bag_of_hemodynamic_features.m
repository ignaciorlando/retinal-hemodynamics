function features = extract_bag_of_hemodynamic_features( root_folder, feature_maps_filenames, centroids, output_path, verbosity )
%EXTRACT_BAG_OF_HEMODYNAMIC_FEATURES Summary of this function goes here
%   Detailed explanation goes here

    if exist('verbosity', 'var') == 0
        verbosity = false;
    end

    % identify the number of hemodynamic features
    size_centroids = size(centroids);
    k = size_centroids(1);
    n_features = size_centroids(2);
    
    % initialize the cell array of features
    features = cell(size(feature_maps_filenames));
    
    % extract features for each of the feature maps
    for j = 1 : length(feature_maps_filenames)
        
        % load the feature map
        current_feature_map = load(fullfile(root_folder, feature_maps_filenames{j}));
        % identify centerlines
        centerlines = ~isnan(current_feature_map.sol(:,:,1));
        
        if verbosity
            fprintf(['Extracting features from ', feature_maps_filenames{j}, '\n']);
        end
        
        % initialize the matrix of features
        X = zeros(length(find(centerlines(:))), n_features);
        % for each feature...
        for f = 1 : size(current_feature_map.sol,3) - 1
            % get current feature
            f_feature_map = current_feature_map.sol(:,:,f);
            % remove the elements with 0 values
            X(:,f) = f_feature_map(centerlines);
        end
        % normalize by mean and standard deviation
        current_mean = mean(X);
        current_std = std(X);
        X = bsxfun(@rdivide, bsxfun(@minus, X, current_mean), current_std);
        
        % compute the distances between each feature and the centroid
        distances = zeros(size(X,1), k);
        for kk = 1 : k
            % compute the euclidean distance
            distances(:,kk) = sqrt(sum((X - repmat(centroids(kk,:), size(X,1), 1)).^2, 2));
        end
        % identify the activated word
        [~, activated_word] = min(distances,[],2);
        % count the number of repetitions
        X = histc(activated_word,1:k);
        % assign to the array of features
        features{j} = X;
        
        if ~strcmp(output_path, '')
            % output filename
            output_filename = feature_maps_filenames{j};
            output_filename = strcat(output_filename(1:end-8), '.mat');
            % save it
            save(fullfile(output_path, output_filename), 'X');
        end
        
    end

end

