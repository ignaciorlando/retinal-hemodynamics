function [ Sols ] = load_simulations_results( folder, labels, SCid_H, SCid_D, stat )
%LOAD_SIMULATIONS_RESULTS Loads all simulations results from folder of the specify scenario
% Loads all the condence solutions from the specified folder that match to the
% specified scenario id for healthy and diseased according to the labels array.
%
% Parameter:
% folder: The folder containing the files.
% labels: The labels for each file, healthy (0) and diseased (1).
% SCid_H: The scenario id for healthy.
% SCid_D: The scenario id for diseased.
% stat:   The statistic to be extracted from the condence solutions.
%
% Returns:
% Sols: Cell array with the condence solutions.
%

% Loads the solution files one by one and rerieve the vessel segments!
filenamesSCH = dir(fullfile(folder, strcat('/*SC',num2str(SCid_H),'*.mat')));
filenamesSCH = {filenamesSCH.name};
filenamesSCG = dir(fullfile(folder, strcat(,'/*SC',num2str(SCid_D),'*.mat')));
filenamesSCG = {filenamesSCG.name};

Sols  = cell(length(filenames),1);
for p = 1 : length(filenames)
    if (labels(p)==0);
        current_filename       = fullfile(input_folder, '/hemodynamic-simulation/', filenamesSCH{p});
        load(current_filename,'sol_condense','HDidx');
    else
        current_filename       = fullfile(input_folder, '/hemodynamic-simulation/', filenamesSCG{p});
        load(current_filename,'sol_condense','HDidx');
    end;
    sol_c = extract_statistic_from_sol_condense( sol_condense, HDidx, stat );
    sol_c = sol_c(sol_c(:,HDidx.mask)<0,:);
    Sols(p) = {sol_c};
end;

end
