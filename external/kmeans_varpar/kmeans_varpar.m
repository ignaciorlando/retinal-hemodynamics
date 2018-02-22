function [L,C] = kmeans_varpar(X,k)
%KMEANS Cluster multivariate data using the k-means algorithm with Variance 
%Partitioning initialization.
%   [L,C] = kmeans(X,k) produces a 1-by-size(X,2) vector L with one class
%   label per column in X and a size(X,1)-by-k matrix C containing the
%   centers corresponding to each class.

%   Version: 2016-05-20
%   Authors: Stefan Pszczolkowski P. (mszspp@nottingham.ac.uk)
%            
%   k-means part based on kmeans++ code by Laurent Sorber 
%   (Laurent.Sorber@cs.kuleuven.be)
%
%   References:
%   [1] J. B. MacQueen, "Some Methods for Classification and Analysis of 
%       MultiVariate Observations", in Proc. of the fifth Berkeley
%       Symposium on Mathematical Statistics and Probability, L. M. L. Cam
%       and J. Neyman, eds., vol. 1, UC Press, 1967, pp. 281-297.
%   [2] Su, T. and Dy, J.G., 2007. In search of deterministic methods for 
%       initializing K-means and Gaussian mixture clustering. Intelligent 
%       Data Analysis, 11(4), pp.319-338.

L = [];
L1 = 0;

root.left = [];
root.right = [];
root.data = X;
root.centroid = mean(root.data, 2);

% The k-means deterministic var par initialization.
root = partition(root, 1, k);
C = collect_centroids(root);
[~,L] = max(bsxfun(@minus,2*real(C'*X),dot(C,C,1).'),[],1);

% The k-means algorithm.
while any(L ~= L1)
    L1 = L;
    for i = 1:k, l = L==i; C(:,i) = sum(X(:,l),2)/sum(l); end
    [~,L] = max(bsxfun(@minus,2*real(C'*X),dot(C,C,1).'),[],1);
end

end

function C = collect_centroids(node)
    if isempty(node.left)
        C = node.centroid;
    else
        Cl = collect_centroids(node.left);
        Cr = collect_centroids(node.right);
        C = [Cl Cr];
    end
end

function node = partition(node, cur_k, max_k)
    if cur_k < max_k && size(node.data,2) > 1
        [~, max_var_dim] = max(arrayfun(@(x)(var(node.data(x,:))), 1:size(node.data,1)));
        cutoff = mean(node.data(max_var_dim,:));
        
        node_left.left = [];
        node_left.right = [];
        node_left.data = node.data(:, node.data(max_var_dim,:) < cutoff);
        node_left.centroid = mean(node_left.data, 2);
        
        node_right.left = [];
        node_right.right = [];
        node_right.data = node.data(:, node.data(max_var_dim,:) >= cutoff);
        node_right.centroid = mean(node_right.data, 2);
        
        node.left = node_left;
        node.right = node_right;
        node.data = []; % No longer needed, try to free up some space
        
        sse_left = compute_sse(node.left.data);
        sse_right = compute_sse(node.right.data);
        
        if sse_left > sse_right
           node.left = partition(node.left, cur_k+1, max_k);
        else
           node.right = partition(node.right, cur_k+1, max_k);
        end
    end
end

function sse = compute_sse(X)
    C = repmat(mean(X, 2),1,size(X, 2));
    D = X-C;
    sse = sum(dot(D,D,1));
end