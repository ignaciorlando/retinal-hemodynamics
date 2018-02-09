
% SCRIPT_SETUP_LEUVEN_EYE_STUDY
% -------------------------------------------------------------------------
% This script organizes the Leuven Eye Study
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_leuven_eye_study;

%% prepare the input data set and the output folders

% prepare input folder
leuven_eye_study_folder = fullfile(input_folder, 'LeuvenEyeStudy');

% check if the file exists
if exist(leuven_eye_study_folder, 'file') == 0
    error('Make sure that you have already copied the files of the Leuven Eye Study.');
end

% prepare images and masks folders
leuven_eye_study_input_image_folder = fullfile(leuven_eye_study_folder, 'images');
leuven_eye_study_input_optic_disc_folder = fullfile(leuven_eye_study_folder, 'od-masks');
leuven_eye_study_output_image_folder = fullfile(leuven_eye_study_folder, 'images-cropped');

%% crop the images around the FOV and resize

% get image filenames
image_filenames = dir(fullfile(leuven_eye_study_input_image_folder, '*.png'));
image_filenames = { image_filenames.name };

% get manual markings of the optic disc
manual_markings_filenames = dir(fullfile(leuven_eye_study_input_optic_disc_folder, '*.png'));
manual_markings_filenames = { manual_markings_filenames.name };

% create the output folder
mkdir(leuven_eye_study_output_image_folder);

% iterate for each image
fprintf('Cropping and resizing images...\n');
for i = 1 : length(image_filenames)
    
    fprintf(['Processing image ', image_filenames{i}, ' (', num2str(i), '/', num2str(length(image_filenames)), ')\n']);
    
    % prepare input/output image filenames
    current_input_image_name = image_filenames{i};
    current_output_image_name = strcat(current_input_image_name(1:end-3), 'png');
    
    % open the image
    image = imread(fullfile(leuven_eye_study_input_image_folder, current_input_image_name));    
    % load the marking
    mask = imread(fullfile(leuven_eye_study_input_optic_disc_folder, manual_markings_filenames{i}));    
    
    % dilate the mask to capture part of the tissue around the optic disc
    dilated_mask = imdilate(mask > 0, strel('disk', round(size(image, 1) * 0.05), 8));
    
    % crop the image
    [ cropped_image, cropped_dilated_mask ] = crop_fov(image, dilated_mask);
    
    % resize the image
    resized_image = imresize(cropped_image, [224, NaN]);
    
    % save both the images and the fov mask
    imwrite(resized_image, fullfile(leuven_eye_study_output_image_folder, current_output_image_name));
    
end

%% read the labels file

% read the xlsx file
[~,txt,~] = xlsread(fullfile(leuven_eye_study_folder, 'Data.xlsx'));
% remove the headers
xlsx_file = txt(2:end, 1);

% encode the labels
labels = ~strcmp(xlsx_file, 'normal');

% save the labels file
save(fullfile(leuven_eye_study_folder, 'labels.mat'), 'labels');
