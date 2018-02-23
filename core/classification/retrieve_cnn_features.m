
function X = retrieve_cnn_features( cnn_features_path, features_filenames )

    % initialize the matrix
    feature_sample = load(fullfile(cnn_features_path, features_filenames{1}));
    if isfield(feature_sample, 'X')
        X = zeros(length(features_filenames), size(feature_sample.X,2));
    else
        X = zeros(length(features_filenames), 1);
    end
    
    % incorporate the other features
    for i = 1 : length(features_filenames)
        feature_sample = load(fullfile(cnn_features_path, features_filenames{1}));
        if isfield(feature_sample, 'X')
            X(i,:) = feature_sample.X;
        else
            X(i,:) = feature_sample.scores(2);
        end
    end

end