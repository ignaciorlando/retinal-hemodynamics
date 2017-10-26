
% SCRIPT_SETUP_INSPIRE_AVR_DATA
% -------------------------------------------------------------------------
% This script download INSPIRE AVR data set and prepares all the data to 
% be used for experiments.
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_inspire_avr_data;

% create folder
mkdir(fullfile(output_folder, 'tmp'));

%% prepare the input data set

% prepare ZIP filename
zip_filename = fullfile(input_folder, 'INSPIRE-AVR.zip');

% check if the file exists
if exist(zip_filename, 'file') ~= 0
    % unzip the file
    fprintf('Unzipping INSPIRE-AVR file...\n');
    % unzip on output_folder/tmp
    unzip(zip_filename, fullfile(output_folder, 'tmp'));
else
    throw('File not found');
end

% also unzip the ground truth labels
zip_filename = fullfile(input_folder_for_image, 'AV_GT_INSPIRE-AVR.zip');

% check if the file exists
if exist(zip_filename, 'file')==0
    % download the data set
    fprintf('Downloading AV_GT_INSPIRE-AVR.zip data');
    zip_filename = websave(fullfile(output_folder, 'AV_GT_INSPIRE-AVR.zip'), ...
        'http://paginas.fe.up.pt/~retinacad/Downloads/AV_GT_INSPIRE-AVR.zip');
end

% unzip the file
fprintf('Unzipping AV_GT_INSPIRE-AVR file...\n');
% unzip on output_folder/tmp
unzip(zip_filename, fullfile(output_folder, 'tmp'));

%% generate the input data set

% the input folder will be different now
input_folder_for_images = fullfile(output_folder, 'tmp', 'INSPIRE-AVR', 'org');
input_folder_for_labels = fullfile(output_folder, 'tmp', 'AV_GT_INSPIRE-AVR');

% and the output folder will be...
inspire_dataset_folder = fullfile(output_folder, 'INSPIRE-AVR');
mkdir(inspire_dataset_folder);
mkdir(fullfile(inspire_dataset_folder, 'images'));
mkdir(fullfile(inspire_dataset_folder, 'veins'));
mkdir(fullfile(inspire_dataset_folder, 'arteries'));
mkdir(fullfile(inspire_dataset_folder, 'labels'));

% retrieve image names
image_filenames = dir(fullfile(input_folder_for_images, '*.jpg'));
image_filenames = {image_filenames.name};
% retrieve labels names
labels_filenames = dir(fullfile(input_folder_for_labels, '*.tif'));
labels_filenames = {labels_filenames.name};

% for each graph file
for i = 1 : length(image_filenames)
    
    % copy current image
    copyfile(fullfile(input_folder_for_images, image_filenames{i}), fullfile(inspire_dataset_folder, 'images', image_filenames{i}));
    % copy all the annotations
    copyfile(fullfile(input_folder_for_labels, labels_filenames{i}), fullfile(inspire_dataset_folder, 'full-labels', labels_filenames{i}));
    % open label
    labels = imread(fullfile(input_folder_for_labels, labels_filenames{i}));
    % identify veins and save
    imwrite(labels(:,:,3)>0, fullfile(inspire_dataset_folder, 'veins', labels_filenames{i}));
    % identify arteries and save
    imwrite(labels(:,:,1)>0, fullfile(inspire_dataset_folder, 'arteries', labels_filenames{i}));
    
end

%% delete tmp folder
rmdir(fullfile(output_folder, 'tmp'), 's');