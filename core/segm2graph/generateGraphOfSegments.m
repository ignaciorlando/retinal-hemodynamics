
function [Gout] = generateGraphOfSegments(Gin)

    % Initialize the new graph...
    Gout.w = Gin.w;
    Gout.l = Gin.l;
    
    
    % node structure:
        %   |
        %   |--> idx: pixels in the segment
        %   |--> links: ids of the links
        %   |--> conn: nodes connected to it
        %   |--> numLinks: length(links)
        %   |--> original_segment_id: original name of the segment
        %   |--> features: unary feature vector
        %   |--> comx: average coordinate in the X axis
        %   |--> comy: average coordinate in the Y axis
    Gout.node(length(Gin.link)) = struct( ...
        'idx', [], ...
        'links', [], ...
        'conn', [], ...
        'numLinks', 0, ...
        'original_segment_id', -1, ...
        'features', [], ...
        'comx', -1, ...
        'comy', -1 ...
        );
    
    % link structure:
    %  |
    %  |--> n1: segment connected with this node
    %  |--> n2: the other segment connected with this node
    %  |--> point: node pixels
    %  |--> original_node_id = original name of the node
    %  |--> features: pairwise feature vector
    %  |--> comx: average coordinate in the X axis
    %  |--> comy: average coordinate in the Y axis
    %  |--> is_branching_point: true/false if is a branching point or not
    Gout.link(1) = struct( ...
        'n1', -1, ...
        'n2', -1, ...
        'point', [], ...
        'original_node_id', -1, ...
        'features', [], ...
        'comx', -1, ...
        'comy', -1, ...
        'is_branching_point', 0 ...
        );
    
   
    
    % For each link in the image
    for link_id = 1 : length(Gin.link)
        
        node.idx = Gin.link(link_id).point;
        node.links = [];
        node.conn = [];
        node.numLinks = 0;
        node.original_segment_id = link_id;
        node.features = [];
        
        % Take the mean coordinate
        coord = zeros(length(node.idx), 2);
        [coord(:,1), coord(:,2)] = ind2sub([Gin.w Gin.l], node.idx);
        coord = mean(coord);
        % Assign to the new node
        node.comx = coord(2);
        node.comy = coord(1);
        
        % Assign the node to its corresponding position in Gout
        Gout.node(link_id) = node;
        
    end
    
    % this will be my alias generator
    new_link_alias = 1;
    
    % Now, we have to link each segment using nodes in Gin
    for node_gin_id = 1 : length(Gin.node)
        
        % Get current node
        current_node = Gin.node(node_gin_id);
        
        % check which type of node it is:
        
        % is an initial branching point, only connecting 2 segments
        if is_an_initial_branching_point(current_node)
            
            % prepare the new link
            new_link = struct();
            new_link.n1 = current_node.links(1);
            new_link.n2 = current_node.links(2);
            new_link.point = current_node.idx;
            new_link.original_node_id = node_gin_id;
            new_link.features = [];
            new_link.comx = current_node.comx;
            new_link.comy = current_node.comy;
            new_link.is_branching_point = true;
            
            % add the new link and update the nodes
            Gout = add_new_link(Gout, new_link, new_link_alias);
            
            % increment the new_link_alias
            new_link_alias = new_link_alias + 1;
            
        % is a branching point or a crossing???
        elseif is_a_branching_point(current_node) || is_a_crossing(current_node) 
            
            % add one new link per each of the combinations
            for i = 1 : length(current_node.links) - 1
                for j = i + 1 : length(current_node.links)
                    
                    % prepare the new link
                    new_link = struct();
                    new_link.n1 = current_node.links(i);
                    new_link.n2 = current_node.links(j);
                    new_link.point = current_node.idx;
                    new_link.original_node_id = node_gin_id;
                    new_link.features = [];
                    new_link.comx = current_node.comx;
                    new_link.comy = current_node.comy;
                    new_link.is_branching_point = is_a_branching_point(current_node);
                    
                    % add the new link and update the nodes
                    Gout = add_new_link(Gout, new_link, new_link_alias);
                    
                    % increment the new_link_alias
                    new_link_alias = new_link_alias + 1;
                    
                end
            end
            
        end
    
    end
    
end

    
    
function Gout = add_new_link(Gout, new_link, new_link_alias)
    
    % add it to the new graph
    Gout.link(new_link_alias) = new_link;

    % update the connectiong in the corresponding nodes:
    %   for n1
    Gout.node(new_link.n1).links = [Gout.node(new_link.n1).links, new_link_alias];
    Gout.node(new_link.n1).conn = [Gout.node(new_link.n1).conn, new_link.n2];
    Gout.node(new_link.n1).numLinks = length(Gout.node(new_link.n1).links);
    %   for n2
    Gout.node(new_link.n2).links = [Gout.node(new_link.n2).links, new_link_alias];
    Gout.node(new_link.n2).conn = [Gout.node(new_link.n2).conn, new_link.n1];
    Gout.node(new_link.n2).numLinks = length(Gout.node(new_link.n2).links);
    
end
    

% is an initial branchit point if it has only 2 links
function it_is = is_an_initial_branching_point(node)
    it_is = length(node.conn)==2;
    if (unique(node.conn) < length(node.conn))
        if unique(node.conn) ~= -1
            disp('A');
        end
    end
end

% is a traditional branching point if it is connected to 3 nodes
function it_is = is_a_branching_point(node)
    it_is = length(node.conn)==3;
    if (unique(node.conn) < length(node.conn))
        my_cicles = node.conn(node.conn ~= -1);
        if length(unique(my_cicles)) < length(my_cicles)
            disp('A');
        end
    end
end

% is a crossing if it is connected to 4 different nodes
function it_is = is_a_crossing(node)
    it_is = length(node.conn)==4;
end