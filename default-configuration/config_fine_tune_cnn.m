
% CONFIG_FINE_TUNE_CNN
% -------------------------------------------------------------------------
% This script is called by script_fine_tune_cnn to configure itself.
% -------------------------------------------------------------------------

% Output folder
output_dir = fullfile(pwd, 'cnn-models');

% Type of images that will be used in the experiment
%image_source = 'optic-disc';
image_source = 'full-image'
%image_source = 'full-image-without-onh'

% Number of epochs for fine tuning
numEpochs = 120;

% Learning rate. Keep it low!
learningRate = 0.00001;

% Dropout probability. Keep it high!
dropout = 0.5;

% Weight decay. Keep it high!
weight_decay = 1e-4;