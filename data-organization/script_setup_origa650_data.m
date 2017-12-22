
% SCRIPT_SETUP_ORIGA650
% -------------------------------------------------------------------------
% This script organizes the downloaded ORIGA605 database.
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_origa650_data;

%% prepare the input data set and the output folders

% prepare input/output folders
origa_folder = fullfile(input_folder, 'origa650');
origa_output_folder = fullfile(output_folder, 'origa650');

% check if the file exists
if exist(origa_folder, 'file') == 0
    error('Couldnt have access to the origa650 folder. Please, download it from http://imed.nimte.ac.cn/Origa-650.html');
else
    mkdir(origa_output_folder);
end

% prepare images and masks folders
origa_input_image_folder = fullfile(origa_folder, 'images');
origa_input_optic_disc_folder = fullfile(origa_folder, 'manual marking');
origa_output_image_folder = fullfile(origa_output_folder, 'images');

%% crop the images around the FOV and resize

% get image filenames
image_filenames = dir(fullfile(origa_input_image_folder, '*.jpg'));
image_filenames = { image_filenames.name };

% get manual markings of the optic disc
manual_markings_filenames = dir(fullfile(origa_input_optic_disc_folder, '*.mat'));
manual_markings_filenames = { manual_markings_filenames.name };

% create the output folder
mkdir(origa_output_image_folder);

% iterate for each image
fprintf('Cropping and resizing images...\n');
for i = 1 : length(image_filenames)
    
    fprintf(['Processing image ', image_filenames{i}, ' (', num2str(i), '/', num2str(length(image_filenames)), ')\n']);
    
    % prepare input/output image filenames
    current_input_image_name = image_filenames{i};
    current_output_image_name = strcat(current_input_image_name(1:end-3), 'png');
    
    % open the image
    image = imread(fullfile(origa_input_image_folder, current_input_image_name));    
    % load the marking
    load(fullfile(origa_input_optic_disc_folder, manual_markings_filenames{i}))
    
    % dilate the mask to capture part of the tissue around the optic disc
    dilated_mask = imdilate(mask > 0, strel('disk', round(size(image, 1) * 0.05), 8));
    
    % crop the image
    [ cropped_image, cropped_dilated_mask ] = crop_fov(image, dilated_mask);
    
    % resize the image
    resized_image = imresize(cropped_image, [224, NaN]);
    
    % save both the images and the fov mask
    imwrite(resized_image, fullfile(origa_output_image_folder, current_output_image_name));
    
end

%% read the labels file

% read the xlsx file
[~, ~, raw] = xlsread(fullfile(origa_folder, 'labels.xlsx'));
% remove the headers
xlsx_file = raw(2:end, :);

% encode the labels
labels = cell2mat(xlsx_file(:,5)) == 1;
% encode the filenames
filenames = cell(size(labels));
for i = 1 : size(xlsx_file, 1)
    current_filename = xlsx_file{i, 2};
    filenames{i} = strcat(current_filename(6:end-5), '.png');
end

% save the labels file
save(fullfile(origa_output_folder, 'labels.mat'), 'labels', 'filenames');
