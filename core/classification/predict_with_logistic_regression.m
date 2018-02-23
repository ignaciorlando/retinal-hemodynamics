
function [scores, y_hat] = predict_with_logistic_regression(X, model)

    % classify given data set
    scores = (model.w' * X')';
    % threshold it
    y_hat = scores > 0;

end