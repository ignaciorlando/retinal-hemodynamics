
% SCRIPT_SETUP_WIDE_DATA
% -------------------------------------------------------------------------
% This script download WIDE data set and prepares all the data to be used
% for experiments.
% -------------------------------------------------------------------------

%% set up variables

% set up main variables
config_setup_wide_data;

% create folder
mkdir(fullfile(output_folder, 'tmp'));

% prepare some paths
dataset_path = fullfile(output_folder);

%% prepare the input data set

% prepare ZIP filename
zip_filename = fullfile(output_folder, 'Tree_topology_PAMI_2015.zip');

% check if the file exists
if exist(zip_filename, 'file')==0
    % download the data set
    fprintf('Downloading Tree_topology_PAMI_2015.zip data\n');
    zip_filename = websave(fullfile(output_folder, 'Tree_topology_PAMI_2015.zip'), ...
        'http://www.duke.edu/~sf59/Datasets/Tree_topology_PAMI_2015.zip');
end

% unzip on output_folder/tmp
fprintf('Done! Unpacking...\n');
unzip(zip_filename, fullfile(output_folder, 'tmp'));

% remove RICE and SKETCH because we don't care about those two sets
rmdir(fullfile(output_folder, 'tmp', 'Tree topology estimation datasets', 'RICE'), 's');
rmdir(fullfile(output_folder, 'tmp', 'Tree topology estimation datasets', 'SKETCH'), 's');
delete(fullfile(output_folder, 'tmp', 'Tree topology estimation datasets', 'plot_graph.m'));
delete(fullfile(output_folder, 'tmp', 'Tree topology estimation datasets', 'README.txt'));

%% generate the input data set

% the input folder will be different now
input_folder = fullfile(output_folder, 'tmp', 'Tree topology estimation datasets', 'WIDE', 'Ground truth trees');

% and the output folder will be...
wide_dataset_folder = fullfile(output_folder, 'WIDE');
mkdir(wide_dataset_folder);
mkdir(fullfile(wide_dataset_folder, 'images'));

% retrieve .mat files
graph_filenames = dir(fullfile(input_folder, '*.mat'));
graph_filenames = {graph_filenames.name};

% for each graph file
fprintf('Done! Organizing data...\n');
for i = 1 : length(graph_filenames)
    
    % load current graph
    load(fullfile(input_folder, graph_filenames{i}));
    % get current name
    [~, current_image_name, ~] = fileparts(graph_filenames{i}); 
    % write current image as a separate file
    imwrite(I2, fullfile(wide_dataset_folder, 'images', strcat(current_image_name, '.png')));
    
end

%% delete tmp folder
fprintf('Done! Removing useless files...\n');
rmdir(fullfile(output_folder, 'tmp'), 's');
if exist(zip_filename, 'file') ~= 0
    delete(zip_filename);
end