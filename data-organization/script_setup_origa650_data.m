
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
origa_output_image_folder = fullfile(origa_output_folder, 'images');
origa_output_masks_folder = fullfile(origa_output_folder, 'masks');

% move the masks from the precomputed-data folder to the masks folder
copyfile(fullfile('precomputed-data', 'origa650', 'masks'), origa_output_masks_folder);

%% crop the images around the FOV and resize

% get image filenames
image_filenames = dir(fullfile(origa_input_image_folder, '*.jpg'));
image_filenames = { image_filenames.name };

% get fov mask filenames
fov_mask_filenames = dir(fullfile(origa_output_masks_folder, '*.png'));
fov_mask_filenames = { fov_mask_filenames.name };

% create the output folder
mkdir(origa_output_image_folder);

% iterate for each image
fprintf('Cropping and resizing images...\n');
for i = 1 : length(image_filenames)
    
    fprintf(['Processing image ', image_filenames{i}, ' (', num2str(i), '/', num2str(length(image_filenames)), ')\n']);
    
    % prepare input/output image filenames
    current_input_image_name = image_filenames{i};
    current_output_image_name = strcat(current_input_image_name(1:end-3), 'png');
    % prepare input fov mask filename
    current_input_fov_name = fov_mask_filenames{i};
    
    % open the image
    image = imread(fullfile(origa_input_image_folder, current_input_image_name));    
    % open mask
    fov_mask = imread(fullfile(origa_output_masks_folder, current_input_fov_name)) > 0;
    
    % crop the image
    [ cropped_image, cropped_mask ] = crop_fov(image, fov_mask);
    
    % resize both of them to the required resolution
    resized_image = zeros(224, 224, size(cropped_image, 3));
    for j = 1 : size(cropped_image, 3)
        resized_image(:,:,j) = imresize(cropped_image(:,:,j), [224, 224]);
    end
    resized_image = uint8(resized_image);
    resized_fov_mask = imresize(cropped_mask, [224, 244], 'nearest') > 0;
    
    % save both the images and the fov mask
    imwrite(resized_image, fullfile(origa_output_image_folder, current_output_image_name));
    imwrite(resized_fov_mask, fullfile(origa_output_masks_folder, current_input_fov_name));
    
end
