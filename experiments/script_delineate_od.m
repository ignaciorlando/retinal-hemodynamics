
% SCRIPT_DELINEATE_OD
% -------------------------------------------------------------------------
% This script allows to manually delineate the optic disc.
% -------------------------------------------------------------------------

% Configurate the script
config_delineate_od;

%% prepare variables

% prepare the input folder for the images
images_path = fullfile(input_folder, 'images');
% prepare the output folder for the optic disc masks
od_masks_path = fullfile(output_folder, 'od-masks');
if exist(od_masks_path, 'dir') == 0
    mkdir(od_masks_path);
end

% retrieve image filenames
image_filenames = dir(fullfile(images_path, '*.png'));
image_filenames = {image_filenames.name};

% count the number of images in the output folder
od_masks_filenames = dir(fullfile(od_masks_path, '*.png'));
od_masks_filenames = {od_masks_filenames.name};

% the starting image will be the one after the last image that was
% previously processed
starting_image = length(od_masks_filenames) + 1;

%% delineate the od

% for each image
for i = starting_image : length(image_filenames)
    
    % open the image
    I = imread(fullfile(images_path, image_filenames{i}));
    fprintf('Processing image %s\n', image_filenames{i});
    
    % first, zoom in the area around the ONH to improve the detection
    source_coordinate = floor(size(I,1) / 3);
    initial_guess = [source_coordinate, source_coordinate, ...
        size(I,1) - 2 * source_coordinate, size(I,1) - 2 * source_coordinate];
    figure, imshow(I);
    title('Select a rectangle close to the OD to zoom in');
    % maximize figure for better visualization
    set(gcf, 'Position', get(0,'Screensize')); 
    h = imrect(gca, initial_guess);
    setFixedAspectRatioMode(h, 1);
    zoom = wait(h);
    
    % crop the rectangle to zoom
    [~, rect] = imcrop(I, zoom);
    rect = round(rect);
    smallSubImage = I(rect(2) : rect(2) + rect(4), ...
        rect(1) : rect(1) + rect(3), :);
    % and show the rectangle
    close
    figure;
    the_fig = imshow(smallSubImage);
    title('Move and resize the elipse to cover the OD area');
    % maximize figure for better visualization
    set(gcf, 'Position', get(0,'Screensize')); 

    % mark the ellipse
    h = imellipse;
    wait(h);
    % generate the binary mask
    od_roi = createMask(h, the_fig);
    % assign the mask to its real position in the image
    final_od_roi = false(size(I,1),size(I,2));
    final_od_roi(rect(2) : rect(2) + rect(4), rect(1) : rect(1) + rect(3), :) = od_roi;
    close all;

    % save the final_od_roi
    imwrite(final_od_roi, fullfile(od_masks_path, image_filenames{i}));
    
end
