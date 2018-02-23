
% SCRIPT_NEW_FIGURE
% -------------------------------------------------------------------------
% This script creates a new figure with a pre-set layout and configuration
% parameters.
% -------------------------------------------------------------------------

figSize = 1.25*[.1 .1 .225 .3];

figure('units','normalized','position',figSize);
set(gcf,'DefaultLineLineWidth',1, 'DefaultAxesFontSize',16,...
    'DefaultTextFontSize',14,...
    'DefaultTextInterpreter','latex',...
    'DefaultLineMarkerSize', 4,...
    'DefaultLineMarker', 'o')
hold on; 
box on; 
grid on;