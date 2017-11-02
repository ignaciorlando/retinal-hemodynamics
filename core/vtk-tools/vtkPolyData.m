function [ polydata, roots ] = vtkPolyData( R, G, spacing )
%VTKPOLYDATA Generates an structure that can be saved using vtkPolyDataWriter.
% R: The radius at each pixel of the skeleton.
% G: A graph representation of the skeletonization. Can be created
%    using the graph-estimation/initialize_graph_from_skeleton function.
% spacing: The pixel spacing (dx, dy).
% 


%% Generates the arterial segments from the graph ------------------------- 
% For each tree, starting from the root and performing a breath first
% traversal, construct the list of arterial segments and the list of 
% all the pixel ids.
vtkCells    = {};
allImageIds = [];
for iTree = 1 : length(G.roots);
    iRoot = G.roots(iTree);
    [vtkcells, allimageids] = breadth_first_traversal (G, iRoot);
    vtkCells    = {vtkCells{:}, vtkcells{:}};
    allImageIds = [allImageIds; allimageids];
    allImageIds = unique(allImageIds);
end

%% Generates the polydata -------------------------------------------------
[x, y] = ind2sub([G.w, G.l], allImageIds);
z      = zeros(size(x));
Points = [x * spacing(1), y * spacing(2), z];

RadiusArray.Name      = 'Radius';
RadiusArray.Dimension = 1;
RadiusArray.Array     = R(allImageIds);
PointDataArrays       = { RadiusArray };

% for each segment, a vtkCell will be constructed
Cells = cell(numel(vtkCells),1);
Cells2 = {};
for s = 1 : numel(vtkCells);
    segment = vtkCells{s};
    vtkCell = zeros(size(segment));
    for i = 1 : numel(segment);
        vtkCell(i) = find(allImageIds==segment(i));
    end
    Cells(s) = {vtkCell};
    
    for i = 1 : numel(segment)-1;
        cell2 = [ find(allImageIds==segment(i)), find(allImageIds==segment(i+1))];
        Cells2(end+1) = { cell2 };
    end
end

CellDataArrays = { };

polydata.Points          = Points;
polydata.Cells           = Cells;
polydata.Cells2          = Cells2;
polydata.PointDataArrays = PointDataArrays;
polydata.CellDataArrays  = CellDataArrays;

%% Retrieve the index of the polydata points that are roots
roots = zeros(size(G.roots));
for i = 1 : numel(G.roots);
    roots(i) = find(allImageIds==G.node(G.roots(i)).idx(1));
end


end



function [vtkCells, allImageIds] = breadth_first_traversal (G, iRoot)
% BREADTH_FIRST_TRAVERSAL Implementation of the Breadth-first traversal algorithm
% over the Graph structure that generates a cell array representing the list
% of image indexes of the ordered pixels of each arterial segment 
% (graph link), which also contains the node pixel.
%
% G: The graph.
% iRoot: The id of the root node in the graph node list.
%
% returns: The list of arterial segments pixel ids and a list of all pixel
% ids in the returned segments that the not contains repetitions.
%

allImageIds = [];
vtkCells = {};
processedLinks = zeros(size(G.link));
processedNodes = zeros(size(G.node));

% The number of nodes in the graph
n   = numel(G.node); 
% search queue and search queue tail/head
sq  = zeros(1,n); 
sqt = 0; 
sqh = 0; 

% start bfs at root
sqt     = sqt + 1; % Advance 1 the tail pointer
sq(sqt) = iRoot;   % The index of the root node in the graph nodes list

% Loop until the search queue is empty
while sqt-sqh > 0;
    % Pop the first node off the head of the queue
    sqh   = sqh + 1;
    iNode = sq(sqh);
    % Loop over all the links of the array
    for l = 1 : numel(G.node(iNode).links)
        iLink = G.node(iNode).links(l);
        % if the link was not visited yet
        if (~processedLinks(iLink));
            linkPoints = G.link(iLink).point;
            % Generates the list of pixel indexes for the current arterial segment
            if (G.link(iLink).n2 > 0); % If the links is not a terminal segment
                % If the end-node was not processed yet, then added to the search queue list.
                if (G.link(iLink).n1 == iNode)
                    endNode = G.link(iLink).n2;
                else
                    endNode = G.link(iLink).n1;
                end
                if (~processedNodes(endNode));
                    sqt     = sqt + 1;
                    sq(sqt) = endNode;
                end
                segment      = zeros(numel(linkPoints)+2,1);
                segment(end) = G.node(endNode).idx(1);
            else
                segment = zeros(numel(linkPoints)+1,1);
            end;
            segment(1) = G.node(iNode).idx(1);
            % Checks the order of the linkPonits and fill the segment
            % accordingly
            [x,y]     = ind2sub([G.w, G.l], G.node(iNode).idx(1));
            possNode  = [x,y,0];
            [x,y]     = ind2sub([G.w, G.l], linkPoints(1));
            possFirst = [x,y,0];
            [x,y]     = ind2sub([G.w, G.l], linkPoints(end));
            possLast  = [x,y,0];
            
            if (norm(possNode-possFirst) < norm(possNode-possLast));
                for k = 1 : numel(linkPoints);
                    segment(k+1) = linkPoints(k);                
                end
            else
                for k = numel(linkPoints) : -1 : 1;
                    segment(numel(linkPoints)-k+1+1) = linkPoints(k);                
                end
            end
            vtkCells(end+1) = {segment};
            allImageIds = [allImageIds; segment];
            allImageIds = unique(allImageIds);
            % mark the current link as visited
            processedLinks(iLink) = 1;
        end
    end
    % mark the current node as visited
    processedNodes(iNode) = 1;
end

end
