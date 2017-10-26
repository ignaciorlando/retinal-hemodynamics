
function [data, computational_cost] = prepare_graphs(data_folder, is_training)

    % Prepare paths
    images_folder = fullfile(data_folder, 'images'); % images
    vessels_folder = fullfile(data_folder, 'vessel-segmentations'); % vessels
    % if is training, we will also use the labels
    if is_training
        labels_folder = fullfile(data_folder, 'labels'); % labels
    end
    
    % Initialize the array of times
    computational_cost = zeros(length(images_folder), 4);

    % Retrieve filenames
    images_filenames = getMultipleImagesFileNames(images_folder); % images
    vessels_filenames = getMultipleImagesFileNames(vessels_folder); % vessels
    % if is training, we will also use the labels
    if is_training
        labels_filenames = dir(fullfile(labels_folder, '*.mat'));
        labels_filenames = {labels_filenames.name};
    end
    
    % check if all the variables have the same size
    if (length(images_filenames) == length(vessels_filenames)) && (~is_training || (length(images_filenames) == length(labels_filenames)))
        
        % Initialize the training data cell array
        data = cell(length(images_filenames), 1);
        
        % for each image
        for i = 1 : length(images_filenames)
            
            fprintf('Processing %s\n', images_filenames{i});
            
            % Load the image
            I = imread(fullfile(images_folder, images_filenames{i}));
            % Load the segmentation
            segm = imread(fullfile(vessels_folder, vessels_filenames{i}));
            % if is training, load the labels
            if is_training
                load(fullfile(labels_folder, labels_filenames{i}));
            end
            
            % Load the skeletonization
            skel = bwmorph(segm, 'skel', Inf);

            % Extract the graph
            % Generate graph of crossings
            tic
            [G_crossings] = initializeGraphFromSkel_new(skel);
            computational_cost(i, 1) = toc;
            % And now transform the graph of crossings into a graph of segments
            tic
            [Gout] = generateGraphOfSegments(G_crossings);
            computational_cost(i, 2) = toc;
            
            % Extract unary features
            tic
            [Gout] = compute_unary_features(Gout, I, segm);
            computational_cost(i, 3) = toc;
            % Extract pairwise features
            tic
            [Gout] = compute_pairwise_features(Gout, segm);
            computational_cost(i, 4) = toc;

            % Assign labels to the graph if it is a training set
            if is_training
                [Gout] = assign_labels(Gout, labels);
            end
            
            % Assign the graph to the cell array
            data{i} = Gout;
            
        end
        
    else
        
        error('Image, labels and vessels folder have a different amount of files inside. Check it out!');
    
    end

end