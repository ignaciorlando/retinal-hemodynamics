
% SETUP
% -------------------------------------------------------------------------
% This code add folders to Matlab environment
% -------------------------------------------------------------------------

% get current root position
my_root_position = pwd;

% An ignored folder, namely configuration, will be created for you so you
% just have to edit configuration scripts there without having to commit
% every single change you made
if exist('configuration', 'file')==0
    % Create folder
    mkdir('configuration');
    % Copy default configuration files
    copyfile('default-configuration', 'configuration');
end

% Install external libraries
if exist('external', 'file')==0
    mkdir('external');
end

% Skeletonization library
skeletonization_library = fullfile('external', 'skeletonization');
if exist(skeletonization_library, 'file') == 0
    % Download the library
    websave('Skeleton.zip', 'http://www.cs.smith.edu/~nhowe/research/code/Skeleton.zip');
    % unzip the code
    mkdir(skeletonization_library);
    unzip('Skeleton.zip', fullfile('external', 'skeletonization'));
    delete('Skeleton.zip')
end
% compile the library
disp('Compiling anaskel.cpp...');
mex 'external/skeletonization/anaskel.cpp' -outdir 'external/skeletonization/'


% add main folders to path
addpath(genpath(fullfile(my_root_position, 'data-organization'))) ;
addpath(genpath(fullfile(my_root_position, 'fundus-util'))) ;
addpath(genpath(fullfile(my_root_position, 'configuration'))) ;
addpath(genpath(fullfile(my_root_position, 'core'))) ;
addpath(genpath(fullfile(my_root_position, 'experiments'))) ;
addpath(genpath(fullfile(my_root_position, 'external'))) ;

clear
clc

fprintf('Successful configuration. Ready to work.\n');