
% SCRIPT_PLOT_FLOW_VS_RADIUS
% -------------------------------------------------------------------------
% This script is intended to generates plots of radius vs flow of the
% simulation results.
% -------------------------------------------------------------------------

clc
clear
close all

% Configurate the script, the script should contain the pixel spacing and image size
config_generate_input_data_vtk;
% input folder
input_folder  = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);
% The indexes for the hemodynamics simulations results
config_hemo_var_idx

%% Set up variables
% Loads the true labels for classification
load(strcat(input_folder,'/labels'));

% Flag specifying if the plots are done over the terminals (1) or over the
% segments (0).
flag_term_segm = 0;

if (flag_term_segm);
    % Load the solution at the outlets and the times
    load(strcat(input_folder,'/hemodynamic-simulation/SolutionsAtOutlets'),'Sols');
    scQidx = 2; % Scenario Q_T index
    scPidx = 1; % Scenario P_0 index
else
    % Loads the solution files one by one and rerieve the vessel segments!
    scidx     = 2; % Scenario index
    filenames = dir(fullfile(input_folder, strcat('/hemodynamic-simulation/*SC',num2str(scidx),'*.mat')));
    filenames = {filenames.name};

    Sols  = cell(length(filenames),1);
    Times = cell(length(filenames),1);
    for p = 1 : length(filenames)
        current_filename       = fullfile(input_folder, '/hemodynamic-simulation/', filenames{p});    
        load(current_filename);

        [I,J] = find(~isnan(sol(:,:,HDidx.mask)) & sol(:,:,HDidx.mask)<0);
        sol_  = nan(numel(I),HDidx.mask);
        for i = 1 : numel(I);
            sol_(i,:) = sol(I(i),J(i),:);
        end;
        nSegments = abs(min(sol_(:,HDidx.mask)));
        sol__  = nan(nSegments,HDidx.mask);
        for i = 1 : nSegments;
            sol__(i,:) = mean(sol_(sol_(:,HDidx.mask)==-i,:),1);
        end;    
        Sols(p) = {sol__};
    end;
end;

%% Perform the plot of the data and the approximated function
% loop over all the patients, and plot the points and approximations with
% differen colors depending on the labels
n = numel(Sols);
fit_func = 'exp';
r_l0 = [];
r_l1 = [];
q_l0 = [];
q_l1 = [];

script_new_figure
for p = 1 : n;
    if (flag_term_segm);
        r = Sols{p}{scQidx,scPidx}(:,HDidx.r);
        q = Sols{p}{scQidx,scPidx}(:,HDidx.q);
    else
        r = Sols{p}(:,HDidx.r);
        q = Sols{p}(:,HDidx.q);
    end;
    [r,I] = sort(r);
    q     = q(I);
    if (labels(p));
        shape = 'x';
        color = 'r';
        r_l1 = [r_l1; r];
        q_l1 = [q_l1; q];
    else
        shape = 'o';
        color = 'k';
        r_l0 = [r_l0; r];
        q_l0 = [q_l0; q];
    end;
    scatter(r,q,35,color,shape,'LineWidth',0.5);
    
    fit_coef = fit_point_data( [r, q], fit_func );
    y = polyval(fit_coef, r);
    
    if (strcmp(fit_func,'exp'));
        plot(r, exp(y), color,'LineWidth',1);
    else
        plot(r, y, color,'LineWidth',1);
    end;
end;
xlabel('Mean radius per segment [cm]','interpreter','latex','fontsize',16);
ylabel('Flow per segment [ml/s]','interpreter','latex','fontsize',16);

% Now approximates one function for each label.
script_new_figure

[r_l0,I] = sort(r_l0);
q_l0     = q_l0(I);
[r_l1,I] = sort(r_l1);
q_l1     = q_l1(I);
fit_coef_l0 = fit_point_data( [r_l0, q_l0], fit_func );
y_l0        = polyval(fit_coef_l0, r_l0);
fit_coef_l1 = fit_point_data( [r_l1, q_l1], fit_func );
y_l1        = polyval(fit_coef_l1, r_l1);

if (strcmp(fit_func,'exp'));
    plot(r_l1, exp(y_l1), 'r','LineWidth',1);
    plot(r_l0, exp(y_l0), 'k','LineWidth',1);
else
    plot(r_l1, y_l1, 'r','LineWidth',1);
    plot(r_l0, y_l0, 'k','LineWidth',1);    
end;
xlabel('Mean radius per segment [cm]','interpreter','latex','fontsize',16);
ylabel('Flow per segment [ml/s]','interpreter','latex','fontsize',16);
legend(gca,{'Healthy','Diseased'},'Interpreter','LaTeX','FontSize',16,'Location','NorthWest');


