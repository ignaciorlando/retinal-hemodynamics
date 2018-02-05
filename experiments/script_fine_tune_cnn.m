
% SCRIPT_FINE_TUNE_CNN
% -------------------------------------------------------------------------
% This script takes the VGG-M network and do some fine tuning using the
% ORIGA650 database.
% -------------------------------------------------------------------------

config_fine_tune_cnn;

%% fine tune and save the model

% fine tune the cnn
[net, info] = cnn_finetune('origa650', 'layers_for_update', [14, 16, 18], ...
                                       'numEpochs', numEpochs, ...
                                       'learningRate', learningRate, ...
                                       'dropout', dropout, ...
                                       'weightDecay', weight_decay, ...
                                       'expDir', output_dir);
