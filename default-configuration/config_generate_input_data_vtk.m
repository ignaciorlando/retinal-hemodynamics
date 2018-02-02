
% CONFIG_GENERATE_INPUT_DATA_VTK
% -------------------------------------------------------------------------
% This script is called by script_generate_input_data for setting up the
% generation of the data needed for the simulations.
% -------------------------------------------------------------------------

% input folder
input_folder = fullfile(pwd, 'data');

% output folder
output_folder = fullfile(pwd, 'data');

% database
database = 'RITE-training';
% pixel spacing
pixelSpacing = [0.0025, 0.0025];