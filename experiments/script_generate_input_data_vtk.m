
% SCRIPT_GENERATE_INPUT_DATA
% -------------------------------------------------------------------------
% This script generates the vtkPolyData representation for each input data 
% .mat file.
% -------------------------------------------------------------------------

% Configurate the script
config_generate_input_data;

%% set up variables

% TODO: Replace with the actual spacing and see how to paramtrize this
% variable in the default configuration.
% The default Pixel Spacing
pixelSpacing = [0.0025, 0.0025];

% prepare output data folder
output_data_folder = fullfile(output_folder, '/input_data/vtk');
if exist(output_data_folder, 'dir') == 0
    mkdir(output_data_folder);
end

% retrieve arteries filenames
filenames = dir(fullfile(output_folder, '/input_data/*.mat'));
filenames = {filenames.name};

%% process data

% for each .mat file
for i = 1 : length(filenames)

    current_filename = filenames{i};
    fprintf('Processing %s\n', current_filename);
    load( fullfile(output_folder, strcat('/input_data/',current_filename)));
    % Generates the vtkPolyData from the graph and radius information
    % stored in the .mat file.
    [polydata, roots] = vtkPolyData( trees_radius, graph, pixelSpacing );
    % Saves the vtkPolyData to ascii file
    vtkPolyDataWriter(polydata, fullfile(output_data_folder, strcat(current_filename(1:end-3), 'vtk')));    
    
end