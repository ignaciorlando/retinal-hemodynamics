
function [cnn_features, probabilities] = extract_cnn_features(cnn, image_filename)
   
    bopts.pad = 0 ;
    bopts.border = 0 ;
    bopts.transformation = 'stretch' ;
    bopts.imageSize = cnn.meta.normalization.imageSize ;
    bopts.averageImage = cnn.meta.normalization.averageImage ;
    bopts.rgbVariance = cnn.meta.augmentation.rgbVariance ;
    
    % process the input image
    image = cnn_get_batch(image_filename, bopts);
    % process the image
    res = vl_simplenn(cnn, image) ;
    % squeeze the output to get the features
    cnn_features = squeeze(gather(res(end-2).x))';
    probabilities = squeeze(gather(res(end).x))';

end