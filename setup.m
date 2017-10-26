
% SETUP_AV_CLASSIFICATION
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

% add main folders to path
addpath(genpath(fullfile(my_root_position, 'data-organization'))) ;
addpath(genpath(fullfile(my_root_position, 'fundus-util'))) ;
addpath(genpath(fullfile(my_root_position, 'configuration'))) ;
addpath(genpath(fullfile(my_root_position, 'core'))) ;
addpath(genpath(fullfile(my_root_position, 'experiments'))) ;
addpath(genpath(fullfile(my_root_position, 'external'))) ;

% compile maxflow code
cd('./core/crf/maxflow/');
make;
cd(my_root_position);

% compile svm-struct
cd('./external/svm-struct-matlab/');

if ispc
    makefile_windows;
else
    % svm_light .o files
    fprintf('doing hideo \n');
    mex -largeArrayDims  -c ./svm_light/svm_hideo.c
    fprintf('doing learn \n');
    mex -largeArrayDims  -c ./svm_light/svm_learn.c
    fprintf('doing common \n');
    mex -largeArrayDims  -c ./svm_light/svm_common.c
    % svm_struct .o files
    mex -largeArrayDims  -c ./svm_struct/svm_struct_learn.c
    mex -largeArrayDims  -c ./svm_struct/svm_struct_common.c
    % svm_struct - custom  .o files
    mex -largeArrayDims  -c ./svm_struct_api.c 
    mex -largeArrayDims  -c ./svm_struct_learn_custom.c
    mex -largeArrayDims -output  svm_struct_learn svm_struct_learn_mex.c svm_struct_api.o  svm_struct_learn_custom.o svm_struct_learn.o svm_struct_common.o svm_common.o svm_learn.o svm_hideo.o
end
%delete *.obj
cd(my_root_position);


clear
clc