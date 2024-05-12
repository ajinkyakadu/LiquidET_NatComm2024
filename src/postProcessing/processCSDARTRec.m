function [K, It] = processCSDARTRec(I, cropRadius, minArea)
%PROCESSCSDARTREC Processes reconstructed images from CSDART.
%   [K, It] = PROCESSCSDARTREC(I, cropRadius, minArea) crops the input image I
%   to a specified circular radius and filters out components based on
%   the minimum area. It then identifies and isolates individual particles
%   in the image.
%
% Inputs:
%   I          : 3D reconstructed image (e.g., binary volume).
%   cropRadius : Fractional radius for cropping the image (default = 0.9).
%   minArea    : Minimum volume in voxels to consider a particle (default = 150).
%
% Outputs:
%   K  : Cell array containing 3D matrices, each representing a separated particle.
%   It : Composite 3D image of all particles that meet the area threshold.
%
% Example:
%   load('sample3Dimage.mat'); % Assume I is loaded from this MAT file
%   [K, It] = processCSDARTRec(I, 0.8, 100);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% June 4, 2023

% Handle default parameters
if nargin < 2, cropRadius = 0.9; end
if nargin < 3, minArea = 150; end

% remove the shell (weak intensities)
I(I < 0.5) = 0;

% Calculate the size of the image
n = size(I);

% Clear borders to remove particles touching edges
[xx, yy, zz] = ndgrid(linspace(-1, 1, n(1)), linspace(-1, 1, n(2)), linspace(-1, 1, n(3)));
mask = zeros(size(I));
mask(xx.^2 + yy.^2 + zz.^2 <= cropRadius^2) = 1;
I = I .* mask;

% Identify connected components that meet the size criteria
CC = bwconncomp(I);
K = {};
It = zeros(size(I));
t = 1;
for i = 1:CC.NumObjects
    voxId = CC.PixelIdxList{i};
    if numel(voxId) > minArea
        Ktemp = zeros(size(I));
        Ktemp(voxId) = 1;
        K{t} = Ktemp;
        It = It + Ktemp;
        t = t + 1;
    end
end

end
