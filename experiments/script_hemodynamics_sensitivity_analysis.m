
% SCRIPT_HEMODYNAMICS_SENSITIVITY_ANALYSIS
% -------------------------------------------------------------------------
% This script performs a sensitivity analysis of the simulations ran and
% stored in the data/RITE-*/hemodynamic-simulation/ folders and in the 
% data/RITE-*/hemodynamic-simulationSolutionsAtOutlets file.
% -------------------------------------------------------------------------

clc
clear

output_data_folder = 'data-analysis';
if (exist(output_data_folder, 'dir') == 0)
    mkdir(output_data_folder)
end;
%% Loads the result at the outlets
load('data/RITE-training/hemodynamic-simulation/SolutionsAtOutlets')
Sols_training  = Sols;
Times_training = Times;
load('data/RITE-test/hemodynamic-simulation/SolutionsAtOutlets')
Sols_test      = Sols;
Times_test     = Times;

Sols           = [Sols_training; Sols_test];
Times          = [Times_training; Times_test];

%% Time statistics
% Simulation pre-processing time statistics
stats_time_prep = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation time statistics
stats_time_simu = compute_stats( Times, [0,0], 1, [1,0] );
% Simulation post-processing time statistics
stats_time_post = compute_stats( Times, [0,0], 1, [1,0] );

%% Statistics at the outlets for all patients, at each scenario
stats_outlets_r = {};
stats_outlets_Q = {};
stats_outlets_P = {};
for sci = 1 : numel(Q_in);
    for scj = 1 : numel(P_in);
        % Radius statistics
        stats_outlets_r(sci,scj) = {compute_stats( Sols, [sci,scj], 1, [1.,           0.] )};
        % Flow percentage statistics
        stats_outlets_Q(sci,scj) = {compute_stats( Sols, [sci,scj], 2, [1./Q_in(sci), 0.] )};
        % Pressure drop from inlet statistics
        stats_outlets_P(sci,scj) = {compute_stats( Sols, [sci,scj], 3, [-1.,   P_in(scj)] )};
        % Blood velocity statistics
        stats_outlets_V(sci,scj) = {compute_stats( Sols, [sci,scj], 4, [1.,           0.] )};
    end;
end;

%% Perform classification and sensitivity analysis of ficticius classes
[statsFPP, statsFQP] = sen_anal_classification( Sols, Q_in, P_in, 3, 1);
[statsFPV, statsFQV] = sen_anal_classification( Sols, Q_in, P_in, 4, 0);
% Generates a cell array with the vFAI for each simulation in the Sols
% array.
K=0;
Q_1_vFAI = [];
Q_2_vFAI = [];
KK=0;
for scqi = 1 : 1;
%for scqi = 1 : numel(Q_in)-1;
    %for scqj = scqi+1 : numel(Q_in);
    for scqj = numel(Q_in)-KK : numel(Q_in);
        K=K+1;
        Q_1_vFAI(end+1) = Q_in(scqi);
        Q_2_vFAI(end+1) = Q_in(scqj);
    end;
end;

vFAIs = cell(size(Sols));
for p = 1 : numel(Sols);
    vfais = cell(1, numel(P_in));
    for scp = 1 : numel(P_in);
        k=0;
        for scqi = 1 : 1;
        %for scqi = 1 : numel(Q_in)-1;
            %for scqj = scqi+1 : numel(Q_in);
            for scqj = numel(Q_in)-KK : numel(Q_in);
                k    = k + 1;
                % Computes the vFAI value for the current simulation
                n    = size(Sols{p}{1,1},1);
                vfai = vFAI( P_in(scp)*ones(n,1), Sols{p}{scqi,scp}(:,3),...
                             Sols{p}{scqj,scp}(:,3), Sols{p}{scqi,scp}(:,2),...
                             Sols{p}{scqj,scp}(:,2), [] );
                vfais(k,scp) = {vfai};
            end;
        end;
    end;
    vFAIs(p) = {vfais};
end;
[statsFPvFAI, statsFQvFAI] = sen_anal_classification( vFAIs, Q_1_vFAI, P_in, 1, 0);


%%
%save(strcat(output_data_folder,'/stats.mat'),'stats_time_prep','stats_time_simu','stats_time_post',...
%                                             'stats_outlets_r','stats_outlets_Q','stats_outlets_P','stats_outlets_V');

