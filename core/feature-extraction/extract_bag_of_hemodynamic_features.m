function extract_bag_of_hemodynamic_features( root_folder, feature_maps_filenames, centroids, output_path )
%EXTRACT_BAG_OF_HEMODYNAMIC_FEATURES Summary of this function goes here
%   Detailed explanation goes here

    % identify the number of hemodynamic features
    size_centroids = size(centroids);
    d = size_centroids(1);
    n_features = size_centroids(2);
    
    % extract features for each of the feature maps
    for j = 1 : length(feature_maps_filenames)
        
        % load the feature map
        current_feature_map = load(fullfile(root_folder, feature_maps_filenames{j}));
        fprintf(['Extracting features from ', feature_maps_filenames{j}, '\n']);
        
        % initialize the cell array of features
        X = cell(n_features, 1);
        
        % for each feature...
        for f = 1 : n_features
        
            % get current feature
            f_feature_map = current_feature_map.sol(:,:,f);
            
            % remove the elements with 0 values
            f_feature_map = f_feature_map(f_feature_map > 0);
            
            % compute the distances between each feature and the centroid
            distances = abs(repmat(f_feature_map, 1 , d) - repmat(centroids(:,f)', length(f_feature_map), 1));
            [~, activated_word] = min(distances,[],2);
            
            % count the number of repetitions
            X{f} = histc(activated_word,1:d);
        
        end
        
        % output filename
        output_filename = feature_maps_filenames{j};
        output_filename = strcat(output_filename(1:end-8), '.mat');
        % save it
        save(fullfile(output_path, output_filename), 'X');
        
    end

end

