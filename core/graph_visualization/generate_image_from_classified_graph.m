
function [I] = generate_image_from_classified_graph(Gout)

    % Initialize the image
    I = ones(Gout.w, Gout.l, 3);
    
    % For each segment
    for i = 1 : length(Gout.node)
        
        % get current node
        current_node = Gout.node(i);
        
        % paint according to the label
        switch current_node.label
            
            case -1   % veins 
                red = I(:,:,1);
                red(current_node.idx) = 0;
                green = I(:,:,2);
                green(current_node.idx) = 0;
                I(:,:,1) = red;
                I(:,:,2) = green;
                
            case 1    % arteries  
                green = I(:,:,2);
                green(current_node.idx) = 0;
                blue = I(:,:,3);
                blue(current_node.idx) = 0;
                I(:,:,2) = green;
                I(:,:,3) = blue;
                
            case 0    % unknown
                red = I(:,:,1);
                red(current_node.idx) = 0;
                blue = I(:,:,3);
                blue(current_node.idx) = 0;
                I(:,:,1) = red;
                I(:,:,3) = blue;
                
        end
        
    end

end