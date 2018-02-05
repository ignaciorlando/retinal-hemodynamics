
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
disp('Compiling skeleton.cpp...');
mex 'external/skeletonization/skeleton.cpp' -outdir 'external/skeletonization/'

% add main folders to path
addpath(genpath(fullfile(my_root_position, 'data-organization'))) ;
addpath(genpath(fullfile(my_root_position, 'fundus-util'))) ;
addpath(genpath(fullfile(my_root_position, 'configuration'))) ;
addpath(genpath(fullfile(my_root_position, 'core'))) ;
addpath(genpath(fullfile(my_root_position, 'experiments'))) ;
addpath(genpath(fullfile(my_root_position, 'external'))) ;

clear
clc

% CNN fine tuning
cnn_finetuning_library = fullfile('external', 'cnn-finetune');
if exist(cnn_finetuning_library, 'dir') == 0
    warning('It seems that the cnn-finetune library has not been added yet to the repository. Please, run this command in a Git terminal: git submodule update --recursive');
else
    addpath(genpath(fullfile(pwd, cnn_finetuning_library))) ;
    cd(cnn_finetuning_library)
    setup_cnn_finetuning
    cd ..
    cd ..
    fprintf('Successful configuration. Ready to work.\n');
end