
% SCRIPT_FINE_TUNE_CNN
% -------------------------------------------------------------------------
% This script takes the VGG-M network and do some fine tuning using the
% ORIGA650 database.
% -------------------------------------------------------------------------

config_fine_tune_cnn;

%% fine tune and save the model

% get the image source name
switch image_source
    case 'optic-disc'
        image_source = 'images-onh';
    case 'full-image'
        image_source = 'images-fov';
    case 'full-image-without-onh'
        image_source = 'images-fov-wo-onh';
end

% prepare output dir for the model
output_dir = fullfile(output_dir, image_source);

% fine tune the cnn
[net, info] = cnn_finetune('origa650', image_source, ...
                                       'layers_for_update', [14, 16, 18], ...
                                       'numEpochs', numEpochs, ...
                                       'learningRate', learningRate, ...
                                       'dropout', dropout, ...
                                       'weightDecay', weight_decay, ...
                                       'expDir', output_dir);
