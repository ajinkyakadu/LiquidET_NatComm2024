function [regularity_index] = computeRegularityIndex(shp)
%COMPUTEREGULARITYINDEX Computes the regularity index of a polyhedron.
%   This function calculates the regularity index of a polyhedron defined
%   by its vertices. The regularity index is a measure of how regular (or
%   irregular) the shape is, based on the variability of distances from
%   the vertices to the centroid of the polyhedron. A lower index indicates
%   a more regular shape.
%
%   The regularity index is defined as 100 times the ratio of the standard
%   deviation to the mean of the distances from each vertex to the centroid.
%
% Inputs:
%   shp : A structure with a field 'Points' containing the vertices of the
%         polyhedron as an N-by-3 matrix.
%
% Output:
%   regularity_index : The calculated regularity index of the polyhedron.
%
% Example:
%   shp = struct('Points', [1 1 1; 1 -1 1; -1 -1 1; -1 1 1; 0 0 -1.5]);
%   idx = computeRegularityIndex(shp);
%   fprintf('Regularity Index: %.2f\n', idx);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% June 4, 2023

% Validate input
if ~isfield(shp, 'Points')
    error('Input structure must contain a ''Points'' field.');
end
vertices = shp.Points;
if size(vertices, 2) ~= 3
    error('Vertices must be given as an N-by-3 matrix.');
end
if size(vertices, 1) < 4
    error('At least four vertices are needed to define a polyhedron.');
end

% Compute the centroid of the polyhedron
centroid = mean(vertices, 1);

% Compute the distances from each vertex to the centroid
distances = sqrt(sum((vertices - centroid).^2, 2));

% Compute the average distance and standard deviation
avg_distance = mean(distances);
std_distance = std(distances);

% Compute the regularity index
regularity_index = 100 * (std_distance / avg_distance);

end
