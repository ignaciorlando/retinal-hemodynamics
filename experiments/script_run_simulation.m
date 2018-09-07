
% SCRIPT_RUN_SIMULATION
% -------------------------------------------------------------------------
% This script run simulations for a series of .vtk files.
% -------------------------------------------------------------------------

%clc
%clear
%close all

% Configurate the script, the script should contain the pixel spacing and image size
% config_generate_input_data_vtk;
% input folder
input_folder = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);
% Crates HDidx, the struct containing the hemodynamic indexes in the 
% solution array.
config_hemo_var_idx

%% set up variables

% Parameters for the hemodynamic simulations. -----------------------------
% The blood viscocity, in [dyn s /cm^2].
% Since the radius of the arteries are <150 µm, a variable
% viscosity depending on the segment radius will be used in the
% simulaction.
mu   = 0.04;                                                               % Dummy parameter, the viscosity is calculated internally by the solver based on the Radius.
%--------------------------------------------------------------------------
% The blood density, in [g / cm^3]. Only used if the stenosis model is employed.
rho  = 1.05;                                                               % Only used for the computation of the Reynolds number.
%--------------------------------------------------------------------------
% The central retinal artery pressure at the inlet, in [mmHg].
  P_in = [57.22, 62.22, 65.22];                                            % Used in the Sensitivity Analysis study.
% P_in = [62.22];                                                          % Used in the MICCAI-2018 study.
%--------------------------------------------------------------------------
% The reference pressure at the outlet, the venous pressure, in [mmHg].
% This is only used in the if the boundary condition is set to 'Resistive'.
% Otherwise, if the boundary condition is 'Flow', the flow is strongly 
% imposed in the terminals.
IOP = [ 5.0, 10.0, 14.2, 20.0 ];                                           % Used in the Sensitivity Analysis study.
%--------------------------------------------------------------------------
% List of total inflows to be used, in [cm^3 / s]
% The values in the paper and the literature are reported in [µl/min], then
% we converted to [cm^3 / s]
  Q_in = [30.0, 40.8, 45.6, 52.9, 80.0] * (1./60.) * 0.001;                % Used in the Sensitivity Analysis study.
% Q_in = [30.0, 45.6, 80.0] * (1./60.) * 0.001;                            % Used in the MICCAI-2018 study.
%--------------------------------------------------------------------------
% Murray exponent
mExp = [2.5, 2.66, 2.76, 2.85, 2.92, 3.0];                                 % Used in the MICCAI-2018 study.
%--------------------------------------------------------------------------
%The resistance model to be used, can be Poiseuille or PoiseuilleTapering
  rModel = {'Poiseuille','PoiseuilleTapering'};                            % Used in the Sensitivity Analysis study.
% rModel = 'Poiseuille';                                                   % Used in the MICCAI-2018 study.
%--------------------------------------------------------------------------
% The Boundary Condition method to be used. Valid values are 'Flow' (for
% strong imposition of flow) or 'Resistive' (for weak imposition of flow).
  BCType = {'Flow','Resistive'};                                           % Used in the Sensitivity Analysis study.
% BCType = 'Flow';                                                         % Used in the MICCAI-2018 study.

% The folder to be created (if not exist) where all the simulations results
% will be stored.
% scenario_output_folder = '/hemodynamic-simulation-StudyCase_R_BC';
% scenario_output_folder = '/hemodynamic-simulation-StudyCase_gamma_BC';
% scenario_output_folder = '/hemodynamic-simulation-StudyCase_P0_QT';
% scenario_output_folder = '/hemodynamic-simulation-StudyCase_IOP_QT';

% prepare output data folder
output_data_folder = fullfile(output_folder, scenario_output_folder);
if exist(output_data_folder, 'dir') == 0
    mkdir(output_data_folder);
end

% retrieve arteries filenames
filenames = dir(fullfile(input_folder, '/input_data/vtk/*.vtk'));
filenames = {filenames.name};

%% process data for the study case. 
% This version always have a matrix where one parameter is the columns and 
% the other the rows of th scenarios that will be simulated.

if (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_R_BC'));
    nScRows = numel(BCType);
    nScCols = numel(rModel);
    P_in    = 62.22;
    IOP     = 14.22;
    Q_in    = 45.6 * (1./60.) * 0.001;
    mExp    = 2.66;
elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_gamma_BC'));
    nScRows = numel(BCType);
    nScCols = numel(mExp);
    P_in    = 62.22;
    IOP     = 14.22;
    Q_in    = 45.6 * (1./60.) * 0.001;
    rModel  = 'Poiseuille';
elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_P0_QT'));
    nScRows = numel(Q_in);
    nScCols = numel(P_in);
    IOP     = 14.22;
    mExp    = 2.66;
    rModel  = 'Poiseuille';
    BCType  = 'Flow';
elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_IOP_QT'));
    nScRows = numel(Q_in);
    nScCols = numel(IOP);
    P_in    = 62.22;
    mExp    = 2.66;
    rModel  = 'Poiseuille';
    BCType  = 'Flow';
end;

% for each .vtk file
Sols  = cell(length(filenames),1);
Times = cell(length(filenames),1);
for i = 1 : length(filenames)
    current_filename       = fullfile(input_folder, 'input_data','vtk', filenames{i});
    current_filename_roots = strcat(current_filename(1:end-4),'_roots.mat');
    fprintf('Processing %s\n', current_filename);
    load(current_filename_roots);
    countSim = 1;
    sols     = cell(nScRows,nScCols);
    times    = cell(nScRows,nScCols);
    % Loop over all inlet flows
    for row = 1 : nScRows;
        % Loop over all inlet pressures
        for col = 1 : nScCols;
            output_filename = fullfile(output_data_folder, strcat(filenames{i}(1:end-4),'_SC',num2str(countSim)));
            countSim = countSim + 1;
            
            % Selects the model parameters dependending on the study cases.
            if (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_R_BC'));
                [sol, sol_condense, time] = run_simulation( current_filename, roots, mu, rho,...
                              P_in, IOP, Q_in, mExp, rModel{col}, BCType{row}, ...
                              output_filename, imgSize(i,:), pixelSpacing(i,:), HDidx );
            elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_gamma_BC'));
                [sol, sol_condense, time] = run_simulation( current_filename, roots, mu, rho,...
                              P_in, IOP, Q_in, mExp(col), rModel, BCType{row}, ...
                              output_filename, imgSize(i,:), pixelSpacing(i,:), HDidx );
            elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_P0_QT'));
                [sol, sol_condense, time] = run_simulation( current_filename, roots, mu, rho,...
                              P_in(col), IOP, Q_in(row), mExp, rModel, BCType, ...
                              output_filename, imgSize(i,:), pixelSpacing(i,:), HDidx );
            elseif (strcmp(scenario_output_folder, '/hemodynamic-simulation-StudyCase_IOP_QT'));
                [sol, sol_condense, time] = run_simulation( current_filename, roots, mu, rho,...
                              P_in, IOP(col), Q_in(row), mExp, rModel, BCType, ...
                              output_filename, imgSize(i,:), pixelSpacing(i,:), HDidx );
            end;
            
            sols(row,col)            = {sol_condense};
            times(row,col)           = {time};
        end;
    end;
    Sols(i)  = {sols};
    Times(i) = {times}; 
end
save(strcat(output_data_folder,'/SolutionsAtOutlets.mat'),'Sols','Times','P_in','Q_in','mExp','IOP','rModel','BCType','rho');

