function [ vessel_radius ] = estimate_vessel_radius( vessel_segm, centerline )
%ESTIMATE_VESSEL_RADIUS Compute the vessel radius using the Euclidean
%transform

    % We approximate the vessel radius using the Euclidean transform
    vessel_radius = bwdist(imcomplement(vessel_segm)) .* centerline;


end

