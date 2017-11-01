
function [trees_ids, root_pixels] = skeletonize_vascular_tree( vessel_segm, od_segm )
%SKELETONIZE_VASCULAR_TREE Skeletonize the segm vascular tree

    % preprocess vessel segmentation
    vessel_segm = preprocess_vessel_segmentation(vessel_segm);

    % skeletonize the segmentation
    skel = bwmorph(skeleton(vessel_segm)>10, 'skel', Inf);
    
    % erode the od mask to get a slightly smaller representation of the od
    od_segm_eroded = imerode(od_segm, strel('disk', 2, 8));

    % identify pixels in the optic disc
    od_idx = find(od_segm_eroded);
    % find connected components of the skeletonization
    CC = bwconncomp(skel);
    % preserve only the structures that are connected to the onh
    new_skel = false(size(skel));
    for i = 1 : CC.NumObjects
        if ~isempty(intersect(CC.PixelIdxList{i}, od_idx))
            new_skel(CC.PixelIdxList{i}) = true;
        end
    end
    % remove vessels inside the onh
    new_skel = new_skel .* imcomplement(od_segm_eroded);
    % remove too short segments
    new_skel = bwareaopen(new_skel, 5);
    
    % assign a first set of labels for each isolated segment
    CC = bwconncomp(new_skel);
    trees_ids = zeros(size(skel));
    for i = 1 : CC.NumObjects
        trees_ids(CC.PixelIdxList{i}) = i;
    end
    n_isolated_segments = CC.NumObjects;
    
    % identify the number of segments touching the od
    od_ring = od_segm - od_segm_eroded;
    root_pixels = bwconncomp(od_ring .* new_skel);
    n_segments_touching_od = root_pixels.NumObjects;
    
    % if the number of isolated segments is different than the number of
    % segments touching the od
    if n_isolated_segments < n_segments_touching_od
        disp('Deal with this');
    end

end

