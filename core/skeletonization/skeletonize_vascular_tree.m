
function [first_trees_ids, first_root_pixels] = skeletonize_vascular_tree( vessel_segm, od_segm )
%SKELETONIZE_VASCULAR_TREE Skeletonize the segm vascular tree

    % preprocess vessel segmentation
    vessel_segm = preprocess_vessel_segmentation(vessel_segm);

    % skeletonize the segmentation
    skel = bwmorph(skeleton(vessel_segm)>20, 'skel', Inf);
    
    % get a first guess of the structure from the od segmentation
    [first_new_skel, first_root_pixels, first_connected_components, first_trees_ids] = get_components_connected_to_optic_disc(od_segm, skel);

    % erode the od_segm until up to 30% of its diameter
    max_eroding_level = round(max(sum(od_segm, 2)) * 0.4);
    for eroding_level = 10 : 10 : max_eroding_level
        
        % reerode the od_segm
        new_od_segm = imerode(od_segm, strel('disk', eroding_level, 8));
        [current_new_skel, current_root_pixels, current_connected_components, current_trees_ids] = get_components_connected_to_optic_disc(new_od_segm, skel);
        
        % preserve the elements that are not touching the od now
        for j = 1 : first_connected_components.NumObjects
            % if the segment is not anymore in the connected components...
            if sum(current_new_skel(first_connected_components.PixelIdxList{j})) ~= length(first_connected_components.PixelIdxList{j})
                % add the root pixels
                current_root_pixels.NumObjects = current_root_pixels.NumObjects + 1;
                current_root_pixels.PixelIdxList = cat(2, current_root_pixels.PixelIdxList, { first_root_pixels.PixelIdxList{j} });
                % add the pixels to the current_new_skel
                current_new_skel(first_connected_components.PixelIdxList{j}) = true;
                % update the trees ids
                current_trees_ids(first_connected_components.PixelIdxList{j}) = max(current_trees_ids(:)) + 1;
                % and add the connected components
                current_connected_components.NumObjects = current_connected_components.NumObjects + 1;
                current_connected_components.PixelIdxList = cat(2, current_connected_components.PixelIdxList, { first_connected_components.PixelIdxList{j} });
            end
        end
        
        % update the structures
        first_new_skel = current_new_skel;
        first_root_pixels = current_root_pixels;
        first_connected_components = current_connected_components;
        first_trees_ids = current_trees_ids;
        
    end

end



function [new_skel, root_pixels, connected_components, trees_ids] = get_components_connected_to_optic_disc(od_segm, skel)

    % erode the od disk a little bit
    od_segm_eroded = imerode(od_segm, strel('disk', 2, 8));

    % identify pixels in the optic disc
    od_idx = find(od_segm_eroded);
    % find connected components of the skeletonization
    connected_components = bwconncomp(skel);
    % preserve only the structures that are connected to the onh
    new_skel = false(size(skel));
    for i = 1 : connected_components.NumObjects
        if ~isempty(intersect(connected_components.PixelIdxList{i}, od_idx))
            new_skel(connected_components.PixelIdxList{i}) = true;
        end
    end
    % remove vessels inside the onh
    new_skel = new_skel .* imcomplement(od_segm_eroded);
    % remove too short segments
    %new_skel = bwareaopen(new_skel, 5);
    
    % assign a first set of labels for each isolated segment
    connected_components = bwconncomp(new_skel);
    trees_ids = zeros(size(skel));
    for i = 1 : connected_components.NumObjects
        trees_ids(connected_components.PixelIdxList{i}) = i;
    end
    
    % identify the number of segments touching the od
    od_ring = od_segm - od_segm_eroded;
    root_pixels = bwconncomp(od_ring .* new_skel);
    
    % correct wrong roots
    [root_pixels] = correct_wrong_roots(root_pixels, od_segm, connected_components);

end


function [root_pixels] = correct_wrong_roots(root_pixels, od_segm, connected_components)
    
    % get the number of isolated segments
    n_isolated_segments = connected_components.NumObjects;

    % if the number of isolated segments is different than the number of
    % segments touching the od
    if n_isolated_segments < root_pixels.NumObjects
        
        % identify the centroid of the optic disc
        s = regionprops(od_segm, 'centroid');
        od_centroid = cat(1, s.Centroid);
        
        % check if two roots lie into the same connected component
        touched_elements = zeros(root_pixels.NumObjects, 1);
        for i = 1 : root_pixels.NumObjects
            for j = 1 : connected_components.NumObjects
                if any(ismember(root_pixels.PixelIdxList{i}, connected_components.PixelIdxList{j}))
                    touched_elements(i) = j;
                    break
                end
            end
        end
        
        % identify the repeated connected component
        [~, ind] = unique(touched_elements);
        % duplicate indices
        duplicate_ind = setdiff(1:size(touched_elements, 1), ind);
        % duplicate values
        duplicate_value = touched_elements(duplicate_ind);
       
        % identify the connected components
        overlapping_roots = root_pixels.PixelIdxList(touched_elements == unique(duplicate_value));
        repeated_roots = find(touched_elements == unique(duplicate_value));
        
        % check which one is the farthest to the optic disc center
        distances_to_od = zeros(size(overlapping_roots));
        for i = 1 : length(overlapping_roots)
            current_mask = zeros(size(od_segm));
            current_mask(overlapping_roots{i}) = true;
            s = regionprops(current_mask, 'centroid');
            current_centroid = cat(1, s.Centroid);
            distances_to_od(i) = norm(current_centroid - od_centroid);
        end
        [distance, idx] = min(distances_to_od);
        % delete the element from the roots
        idx_to_delete = 1:length(distances_to_od);
        idx_to_delete(idx_to_delete == idx) = [];
        root_pixels.PixelIdxList(repeated_roots(idx_to_delete)) = [];
        root_pixels.NumObjects = root_pixels.NumObjects - length(idx_to_delete);
        
    end

end