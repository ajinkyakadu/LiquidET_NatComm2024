function [u] = computeIntensity(I, numMat, alpha)
%COMPUTEINTENSITY Calculate intensity levels in an image based on quantization.
%   [u] = COMPUTEINTENSITY(I, numMat, alpha) computes the average intensity
%   values for each quantized material region in the image I, using a specified
%   number of materials 'numMat' and an unused parameter 'alpha'.
%
%   This function first determines optimal threshold values for quantizing the
%   image into 'numMat' different regions using Otsu's method. It then assigns
%   average intensity values to each material region based on pixel intensities.
%
% Inputs:
%   I      : Input grayscale image, a 2D array.
%   numMat : Number of material regions to quantize the image into.
%   alpha  : Unused parameter, reserved for future enhancements.
%
% Outputs:
%   u      : A column vector of length 'numMat' containing the sorted average
%            intensities of each quantized material region.
%
% Example:
%   I = imread('cameraman.tif');
%   numMat = 3;
%   u = computeIntensity(I, numMat, 1); % Calculate intensity levels
%
% Note:
%   'alpha' is currently unused and reserved for future functionality.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Calculate thresholds using multilevel Otsu's method
thr = multithresh(I, numMat);

% Quantize image using calculated thresholds
J0 = imquantize(I, thr);

% Get unique quantized values
uJ0 = unique(J0);

% Initialize the output vector for intensities
u = zeros(numMat, 1);

% Calculate average intensity for each material region, except the background
for idx = 1:min(length(uJ0)-1, numMat)
    pix = find(J0 == uJ0(idx+1)); % pixels corresponding to the current region
    u(idx) = sum(I(pix), 'all') / length(pix); % average intensity
end

% Sort the intensities in ascending order
u = sort(u, 'ascend');

end
