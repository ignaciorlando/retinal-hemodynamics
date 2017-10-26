
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