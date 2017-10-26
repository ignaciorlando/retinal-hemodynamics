
function [Gmatlab, XData, YData] = generate_matlab_graph(Gin)

    adjacency_matrix = logical(length(Gin.node));
    
    Xdata = zeros(length(Gin.node), 1);
    Ydata = zeros(length(Gin.node), 1);
    
    for i = 1 : length(Gin.node)
        for j = 1 : length(Gin.node(i).conn)
            adjacency_matrix(i, Gin.node(i).conn(j)) = true;
            adjacency_matrix(Gin.node(i).conn(j), i) = true;
        end
        XData(i) = Gin.node(i).comx;
        YData(i) = Gin.node(i).comy;
    end
    
    Gmatlab = graph(adjacency_matrix);

end