
% SCRIPT_HEMODYNAMICS_SENSITIVITY_ANALYSIS
% -------------------------------------------------------------------------
% This script performs a sensitivity analysis of the simulations ran and
% stored in the data/RITE-*/hemodynamic-simulation/ folders and in the 
% data/RITE-*/hemodynamic-simulationSolutionsAtOutlets file.
% -------------------------------------------------------------------------

clc

output_data_folder = 'data-analysis';

%% Loads the result at the outlets
load('data/RITE-training/hemodynamic-simulation/SolutionsAtOutlets')
Sols_training  = Sols;
Times_training = Times;
load('data/RITE-test/hemodynamic-simulation/SolutionsAtOutlets')
Sols_test      = Sols;
Times_test     = Times;

Sols           = {Sols_training; Sols_test};
Times          = {Times_training; Times_test};

%% Time statistics
% Simulation pre-processing time statistics
stats_time_prep = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation time statistics
stats_time_simu = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation post-processing time statistics
stats_time_post = compute_stats( Times, [0,0], 1, [1,0] );

%% Statistics at the outlets for all patients
stats_outlets_r = {};
stats_outlets_Q = {};
stats_outlets_P = {};
for sci = 1 : numel(Q_in);
    for scj = 1 : numel(P_in);
        % Simulation pre-processing time statistics
        stats_outlets_r(sci,scj) = {compute_stats( Sols, [sci,scj], 1, [1,0] )};
        % Simulation time statistics
        stats_outlets_Q(sci,scj) = {compute_stats( Sols, [sci,scj], 2, [1./Q_in(sci),0] )};
        % Simulation post-processing time statistics
        stats_outlets_P(sci,scj) = {compute_stats( Sols, [sci,scj], 3, [1,P_in(scj)] )};
    end;
end;

save(strcat(output_data_folder,'/stats.mat'),'stats_time_prep','stats_time_simu','stats_time_prost',...
                                             'stats_outlets_r','stats_outlets_Q','stats_outlets_P');

