
% SCRIPT_SETUP_RITE_DATA
% -------------------------------------------------------------------------
% This script download RITE (DRIVE) data set and prepares all the data to 
% be used for experiments.
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_rite_data;

% create folder
mkdir(fullfile(output_folder, 'tmp'));

%% prepare the input data set

% prepare ZIP filename
zip_filename = fullfile(input_folder, 'AV_groundTruth.zip');

% check if the file exists
if exist(zip_filename, 'file') == 0
    % file not found, trying to download
    fprintf('File not found. Trying to download...\n');
    try
        websave(zip_filename, ...
            'http://webeye.ophth.uiowa.edu/abramoff/AV_groundTruth.zip');
        fprintf('File downloaded!\n');
    catch exception
        error('Couldnt download the file. Please, try manually with http://webeye.ophth.uiowa.edu/abramoff/AV_groundTruth.zip');
    end
end

% unzip the file
fprintf('Unzipping AV_groundTruth file...\n');
% unzip on output_folder/tmp
unzip(zip_filename, fullfile(output_folder, 'tmp'));

%% generate the input data set

subsets = {'training', 'test'};

fprintf('Done! Organizing data...\n');
for subs_ = 1 : length(subsets)
    
    % get current set
    current_set = subsets{subs_};

    % the input folder will be different now
    input_folder_for_images = fullfile(output_folder, 'tmp', 'AV_groundTruth', current_set, 'images');
    input_folder_for_labels = fullfile(output_folder, 'tmp', 'AV_groundTruth', current_set, 'av');

    % and the output folder will be...
    rite_dataset_folder = fullfile(output_folder, strcat('RITE-', current_set));
    mkdir(rite_dataset_folder);
    mkdir(fullfile(rite_dataset_folder, 'images'));
    mkdir(fullfile(rite_dataset_folder, 'vessel-segmentations'));
    mkdir(fullfile(rite_dataset_folder, 'veins'));
    mkdir(fullfile(rite_dataset_folder, 'arteries'));
    mkdir(fullfile(rite_dataset_folder, 'original-labels'));

    % retrieve image names
    image_filenames = dir(fullfile(input_folder_for_images, '*.tif'));
    image_filenames = {image_filenames.name};
    % retrieve labels names
    labels_filenames = dir(fullfile(input_folder_for_labels, '*.png'));
    labels_filenames = {labels_filenames.name};

    % for each graph file
    for i = 1 : length(image_filenames)

        % open the image
        img = imread(fullfile(input_folder_for_images, image_filenames{i}));
        
        % save the image
        new_image_filename = image_filenames{i};
        new_image_filename = strcat(new_image_filename(1:end-3), 'png');
        imwrite(img, fullfile(rite_dataset_folder, 'images', new_image_filename));
        
        % open label
        im_labels = imread(fullfile(input_folder_for_labels, labels_filenames{i}));

        % identify labels of arteries, removing unknown portions of the
        % vasculature
        arteries = logical((im_labels(:,:,1) == 255) .* (im_labels(:,:,3) == 0));
        arteries(im_labels(:,:,2)==255) = true;
        arteries(sum(im_labels, 3) > 510) = false;
        % identify labels of veins, removing unknown portions of the
        % vasculature
        veins = logical((im_labels(:,:,1) == 0) .* (im_labels(:,:,3) == 255));
        veins(im_labels(:,:,2)==255) = true;
        veins(sum(im_labels, 3) > 510) = false;

        % identify veins and save
        imwrite(veins, fullfile(rite_dataset_folder, 'veins', labels_filenames{i}));
        % identify arteries and save
        imwrite(arteries, fullfile(rite_dataset_folder, 'arteries', labels_filenames{i}));
        % identify vessels and save
        imwrite((veins + arteries) > 0, fullfile(rite_dataset_folder, 'vessel-segmentations', labels_filenames{i}));
        % write the original labels
        imwrite(im_labels, fullfile(rite_dataset_folder, 'original-labels', labels_filenames{i}));
        
    end

end

%% delete tmp folder
fprintf('Done!\n');
rmdir(fullfile(output_folder, 'tmp'), 's');