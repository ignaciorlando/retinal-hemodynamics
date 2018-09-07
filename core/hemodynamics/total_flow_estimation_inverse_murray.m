
% SCRIPT_ESTIMATE_MURRAYS_COEFFICIENT_FROM_SAMPLE
% -------------------------------------------------------------------------
% This script is intended to estimate the beta coefficient of the Murray's
% law for a sample of vasculature geometries.
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

scenario_output_folder = 'hemodynamic-simulation-StudyCase_gamma_BC';

Sols = load_simulations_results(fullfile(input_folder,scenario_output_folder), lagels, 1, 1, 'mean');

Qin_flag = 0;
Qin      = 45.6 ; 

%% Loop over each patient
n = numel(Sols);
fit_func = 'exp';
r_l0 = [];
r_l1 = [];
q_l0 = [];
q_l1 = [];

script_new_figure
for p = 1 : n;
    r = Sols{p}(:,HDidx.r);
    q = Sols{p}(:,HDidx.q);
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
xlabel('Mean radius per segment [cm]','interpreter','latex','fontsize',20);
ylabel('Flow per segment [ml/s]','interpreter','latex','fontsize',20);

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
xlabel('Mean radius per segment [cm]','interpreter','latex','fontsize',20);
ylabel('Flow per segment [ml/s]','interpreter','latex','fontsize',20);
legend(gca,{'Glaucomatous','Healthy'},'Interpreter','LaTeX','FontSize',20,'Location','NorthWest');


