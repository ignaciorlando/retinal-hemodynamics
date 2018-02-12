
% SCRIPT_EXTRACT_TRANSFERRED_FEATURES
% -------------------------------------------------------------------------
% Use this script to extract features derived from the pre-trained CNN
% -------------------------------------------------------------------------

clc
config_extract_transferred_features

%% prepare input variables

% load the centroids
cnn = load(cnn_filename);

% update root_folder to include images-cropped
root_folder = fullfile(root_folder, 'images-cropped');

% retrieve the image names
image_filenames = dir(fullfile(root_folder, '*.png'));
image_filenames = {image_filenames.name};

%% extract features

% check if the folder doesnt exist
if exist(output_path_features, 'dir')==0
    mkdir(output_path_features);
end
output_path_probabilities = fullfile(output_path_probabilities, 'cnn');
if exist(output_path_probabilities, 'dir')==0
    mkdir(output_path_probabilities);
end

% compute the features for each of the images
for i = 1 : length(image_filenames)
    fprintf(strcat(image_filenames{i}, '\n'));
    % compute the features
    [X, scores] = extract_cnn_features(cnn, { fullfile(root_folder, image_filenames{i}) });
    % save the features in a MAT file
    current_filename = image_filenames{i};
    save(fullfile(output_path_features, strcat(current_filename(1:end-3), 'mat')), 'X');
    % save the scores for the true class
    scores = scores(2);
    save(fullfile(output_path_probabilities, strcat(current_filename(1:end-3), 'mat')), 'scores');
end