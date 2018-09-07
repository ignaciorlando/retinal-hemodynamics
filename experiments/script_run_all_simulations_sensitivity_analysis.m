clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-test';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_R_BC';
script_run_simulation

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-test';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_gamma_BC';
script_run_simulation

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-test';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_P0_QT';
script_run_simulation;

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-test';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_IOP_QT';
script_run_simulation;


clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-training';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_R_BC';
script_run_simulation;

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-training';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_gamma_BC';
script_run_simulation;

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-training';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_P0_QT';
script_run_simulation;

clear
close all
clc
% input folder ------------------------------------------------------------
input_folder = fullfile(pwd, 'data');
% output folder -----------------------------------------------------------
output_folder = fullfile(pwd, 'data');
% pixel spacing, in [cm] --------------------------------------------------
 pixelSpacing = [ones(20,1)*0.0025, ones(20,1)*0.0025]; % RITE database
% The image size ----------------------------------------------------------
 imgSize      = [ones(20,1)*565, ones(20,1)*584];  % RITE database
% database ----------------------------------------------------------------
database = 'RITE-training';
scenario_output_folder = '/hemodynamic-simulation-StudyCase_IOP_QT';
script_run_simulation;

