
% CONFIG_FINE_TUNE_CNN
% -------------------------------------------------------------------------
% This script is called by script_fine_tune_cnn to configure itself.
% -------------------------------------------------------------------------

% Output folder
output_dir = fullfile(pwd, 'cnn-models');

% Number of epochs for fine tuning
numEpochs = 120;

% Learning rate. Keep it low!
learningRate = 0.00001;

% Dropout probability. Keep it high!
dropout = 0.5;

% Weight decay. Keep it high!
weight_decay = 1e-4;