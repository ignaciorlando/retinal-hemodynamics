
function model = train_random_forest(X, labels, number_of_trees)

    % initialize an array of different number of trees
    if nargin < 3
        number_of_trees = 100:20:200;
    end

    % quality values and models
    quality_values = zeros(length(number_of_trees), 1);
    models_per_quality_value = cell(size(quality_values));

    % for each tree
    for n_tree = 1 : length(number_of_trees)

        fprintf('Training with number of trees = %d', number_of_trees(n_tree));
        % train a RF from the training set
        model = classRF_train(X, labels, number_of_trees(n_tree), sqrt(size(X,2)));
        % retrive current OOB error
        quality_values(n_tree) = model.errtr(end,1);
        % print current OOB error
        fprintf(' ---> OOB error rate = %d\n', quality_values(n_tree));
        models_per_quality_value{n_tree} = model;

    end

    % Retrieve the best performance
    [quality, index] = min(quality_values(:));
    fprintf('Best OOB error: %d\n', quality);
    fprintf('Number of trees=%d\n', number_of_trees(index));
    % and the best model
    model = models_per_quality_value{index};

end