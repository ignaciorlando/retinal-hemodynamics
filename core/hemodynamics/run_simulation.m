function [ sol, times ] = run_simulation( inputFile, roots, mu, rho, P_in, P_ref, Q_in, mExp, outputFile, imgSize, spacing )
%RUN_SIMULATION Given an input vtk file and a set of parameters, perform an
% hemodynamics simulations and export the result to a .mat file in a matrix
% forma.
% 
% inputFile: The file name (with full path) to the vtk containing the
%          arterial tree to be used.
% roots:   Array of (N,3) containing the x,y and z coordinates for the N
%          roots of the arterial tree in the input vtk.
% mu:      The blood viscocity, in [dyn s /cm^2].
% rho:     The blood density, in [g / cm^3]. Only used if the stenosis 
%          model is employed.
% P_in:    Pressure at the root(s) of the arterial tree, in [mmHg].
% P_ref:   Reference pressure at all terminals of the arterial tree, 
%          in [mmHg].
% Q_in:    Total inflow at the root(s) of the arterial tree, in [cm^3 / s].
% mExp:    The Murray exponent to be used in the calculus of terminal
%          resistances. Adimensional parameter.
% outFile: The file name (with full path) to the .mat file to be created
%          with the solution.
% imgSize: Array containing the x and y sizes of the resulting image. Note
%          that this sizes should be large enough to fit the input vtk
%          points coordinates. No size check is perform.
% spacing: The pixel spacing, used to convert point coordinates into image
%          indexes.
%
%
% Retunrs:
% sol:   The solution of the simulation, it is a marix of dimensions 
% (imgSize(1),imgSize(2),5), contining at each skeleton pixel the radius, 
% flow, pressure, blood velocity and a Mask with "nan" everywhere else. The mask indicates 
% 0 for arterial segment, 1 for root, 2 for terminal and 3 for bifurcation 
% point.
% times: Array with the times took for running the steps 0 (data
% prearation), 1 (run simulation) and 2 (postprocessing). Times are
% measured by the tic/toc functions.
%

times = zeros(1,3);

%% Step 0: Data preparation
% Generates the configuration file to perform convertion of the input vtk
% to segment-wise format.
tic
fileStep0Cfg = strcat(outputFile,'_sim_step0.cfg');
fid = fopen(fileStep0Cfg, 'wt');
fprintf(fid, 'modality = "convertFile";\n');
fprintf(fid, strcat('fileToConvert  = "',inputFile,'";\n'));
fprintf(fid, strcat('fileConverted  = "',outputFile,'_sim_step0.vtk";\n'));
fprintf(fid, 'numberOfElementsPerBranch = 1;\n');
fprintf(fid, 'rootPoints={\n');
fprintf(fid, 'numberOfPoints=%d;\n', size(roots,1));
fprintf(fid, 'pointsSpatialPosition=(\n');
for i = 1 : size(roots,1)-1;
    fprintf(fid, '%1.10E, %1.10E, %1.10E,\n', roots(i,1), roots(i,2), roots(i,3));
end;
fprintf(fid, '%1.10E, %1.10E, %1.10E\n', roots(end,1), roots(end,2), roots(end,3));
fprintf(fid, ');\n}\n'  );
fclose(fid);

% Convert the original centerline to an arterial segment structure using the FFRTest program
command = strcat('external/hemodynamics-solver/step0 -f ', fileStep0Cfg );
[status,cmdout] = system(command);

times(1) = toc;

%% Step 1: Simulation
tic
% Generates the configuration file to perform simulation
fileStep1Cfg = strcat(outputFile,'_sim_step1.cfg');
fid = fopen(fileStep1Cfg, 'wt');
fprintf(fid, 'modality = "generic-simulation";\n');
% Blood viscocity, in [dyn s /cm^2]
fprintf(fid, 'mu = %1.10E;\n', mu);
% Blood density, in [g / cm^3]
fprintf(fid, 'rho = %1.10E;\n', rho);
% Pressure at the root of the arterial tree, in [mmHg].
fprintf(fid, 'P_in = %1.10E;\n', P_in);
% Reference pressure at all terminals of the arterial tree, in [mmHg].
fprintf(fid, 'P_ref = %1.10E;\n', P_ref);
% Estimated total inflow at the root(s) of the arterial tree, in [cm^3/s].
fprintf(fid, 'Q_in = %1.10E;\n', Q_in);
% The radius exponent is used to construct  boundary conditions following the
% Murray's law idea of linear relationship between the flux Q and the radius r
% on terminal elements. the
% IMPORTANT: If this parameter is not present, the default (3) is used, which is
%            the original Murray's principle.
fprintf(fid, 'radiusExponent = %1.10E;\n', mExp);
% The root point coordinates, it must contain three values, (x,y,z)
fprintf(fid, 'rootPoints={\n');
fprintf(fid, 'numberOfPoints=%d;\n', size(roots,1));
fprintf(fid, 'pointsSpatialPosition=(\n');
for i = 1 : size(roots,1)-1;
    fprintf(fid, '%1.10E, %1.10E, %1.10E,\n', roots(i,1), roots(i,2), roots(i,3));
end;
fprintf(fid, '%1.10E, %1.10E, %1.10E\n', roots(end,1), roots(end,2), roots(end,3));
fprintf(fid, ');\n}\n'  );
% Relative path (from basePATH) to the folder where all results will be saved.
% Relative to the base path.
% IMPORTANT: The path should end with "/".
fprintf(fid, strcat('testFolder = "',outputFile,'";\n'));
% File name of the simulation log file. The path is constructed using the
% basePATH and the testFolder strings.
fprintf(fid, strcat('fileLog = "',outputFile,'_sim.log";\n'));
% The root folder of the Database folder hierarchy. Should end with "/"
fprintf(fid, 'DBRoot = "";\n');  % This should be empty, because input and output file names contains the full path
% The complete path to the base folder. This folder is used to compose the test
% folder. Previous versions read data and configurations files from this location.
% IMPORTANT: The path should end with "/".
fprintf(fid, 'basePATH = "";\n');  % This should be empty, because input and output file names contains the full path
% File name of the original mesh file (vasculature), with path included.
fprintf(fid, strcat('fileVasculature  = "',outputFile,'_sim_step0.vtk";\n'));
% This parameter specified the name of the point data array of the polydata used
% to retrieve radius information for resistance computation.
% IMPORTANT: If not present, the "Radius" array will be used.
fprintf(fid, 'radiusArrayName = "Radius";\n');
% Boolean flag to indicate if the Young Model is to be used in stenosis, or not.
fprintf(fid, 'useYoungModel = false;\n');
% The mothodology used to contruct the boundary conditions.
% 5: inletPressure_outletResistanceMurrayMeanDistalRadius
%    but the flow is enforced in an strong way.
fprintf(fid, 'BCMethodology = 5;\n');
% This parameter reprecent a percentage (range [0,100]) of the arterial length
% from the end point. This arterial segment will be used to compute an equivalent
% radius for the boundary condition computation.
fprintf(fid, 'endArteryLengthPercentage = 0.01;\n');
% Specified if the flows will be imposed in a strong or weak
% (threough resistance) fashion.
fprintf(fid, 'flowBCStrategy = "strong";\n');
% Scaling factor of terminal (boundary condition) resistance to be used in
% the construction of boundary conditions (if applicable).
fprintf(fid, 'scalingFactorR = 1.0;\n');
fclose(fid);

% Performs the simulation
command = strcat('external/hemodynamics-solver/step1 -f ', fileStep1Cfg );
[status,cmdout] = system(command);

times(2) = toc;

%% Step 2: Post-processing
tic
% Reads the vtk containing the solution and generates the matrix with the
% solution.
sol = nan([imgSize,5]);

movefile(strcat(outputFile,'_vasculature.vtk'), strcat(outputFile,'_sol.vtk'));
fileStep2sol  = strcat(outputFile,'_sol.vtk');
polydata      = vtkPolyDataReader(fileStep2sol);
for a = 1 : numel(polydata.PointDataArrays);
    if (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Flux'));
        iaQ = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Pressure'));
        iaP = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'Radius'));
        iaR = a;
    end;
end;
FlowArray     = polydata.PointDataArrays{iaQ}.Array;
PressureArray = polydata.PointDataArrays{iaP}.Array;
RadiusArray   = polydata.PointDataArrays{iaR}.Array;
% First set all pressure and flows, and the mask is set to zero (segment)
% by default.
for p = 1 : size(polydata.Points,1);
    i = round(polydata.Points(p,1) / spacing(1));
    j = round(polydata.Points(p,2) / spacing(2));
    sol(i,j,1) = RadiusArray(p);
    sol(i,j,2) = FlowArray(p);
    sol(i,j,3) = PressureArray(p);
    sol(i,j,4) = FlowArray(p) ./ (pi * RadiusArray(p) .* RadiusArray(p));
    sol(i,j,5) = 0;
end;
% Now set all the roots mask to one
for r = 1 : size(roots, 1);
    i = round(roots(r,1) / spacing(1));
    j = round(roots(r,2) / spacing(2));
    sol(i,j,5) = 1;
end;
% Now set all the terminal and bifurcation mask to two and three
for ci = 1 : size(polydata.Cells,1);
    CellI = polydata.Cells{ci};
    i = round(polydata.Points(CellI(end),1) / spacing(1));
    j = round(polydata.Points(CellI(end),2) / spacing(2));
    isTerminal = 1;
    for cj = 1 : size(polydata.Cells,1);
        CellJ = polydata.Cells{cj};
        if (CellI(end)==CellJ(1));
            isTerminal = 0;
            break;
        end;
    end;
    if (isTerminal==1);
        sol(i,j,5) = 2;
    else
        sol(i,j,5) = 3;
    end;
end;

% Saves the sol matrix to file
save(strcat(outputFile,'_sol.mat'), 'sol');

% deletes all auxiliary files except the solution (.mat and .vtk files)
delete(strcat(outputFile,'_0DModel.vtk'));
delete(strcat(outputFile,'_0DModelSO.vtk'));
delete(strcat(outputFile,'_sim_step0.vtk'));
delete(strcat(outputFile,'_sim_step0.cfg'));
delete(strcat(outputFile,'_sim_step1.cfg'));
delete(strcat(outputFile,'_sim_step0.vtk_vasculature.vtk'));

times(3) = toc;

end
