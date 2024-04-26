function [W, Y, n, stack] = generateTomoOp(stack)
%GENERATETOMOOP Generate tomography operator and normalized measurements.
%   [W, Y, n, stack] = GENERATETOMOOP(stack) prepares a tomography operator W,
%   normalized measurements Y, the size of the cubic volume n, and adjusts
%   the stack data for tomographic reconstruction.
%
%   The function squares the data if it is not already square, sets up a
%   3D parallel beam geometry, creates the tomography operator using ASTRA
%   toolbox, and normalizes the measurements.
%
% Inputs:
%   stack : Structure containing the following fields:
%           - data   : Raw projection data (slices, rows, cols).
%           - angles : Projection angles in degrees.
%
% Outputs:
%   W     : Tomography operator (ASTRA toolbox operator handle).
%   Y     : Normalized measurement vector.
%   n     : Vector [cols, cols, cols] representing the dimensions of the volume.
%   stack : Updated stack structure with possibly modified data.
%
% Example:
%   stack.data = rand(128, 128, 100); % example projection data
%   stack.angles = linspace(0, 180, 100); % angles from 0 to 180 degrees
%   [W, Y, n, stack] = generateTomoOp(stack);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Ensure the data is square
if abs(size(stack.data, 2) - size(stack.data, 1)) > 0
    stack.data = makeDataSquare(stack.data);
end

% Define the dimensions
cols = size(stack.data, 2);
n = [cols, cols, cols];

% Create tomography operator using ASTRA toolbox
angles = deg2rad(stack.angles - 90);
vol_geom = astra_create_vol_geom(cols, cols, cols);
proj_geom = astra_create_proj_geom('parallel3d', 1, 1, cols, cols, angles);
W = opTomo('cuda', proj_geom, vol_geom);

% Prepare measurements
Y0 = flip(stack.data, 2);
Y0 = permute(Y0, [2, 3, 1]);
Y0 = vec(Y0);
Ymax = max(Y0(:));
Y = Y0 / Ymax;

end
