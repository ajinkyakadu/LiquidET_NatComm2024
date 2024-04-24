function [x0] = initializeCoeff(I, u, m)
%INITIALIZECOEFF Initialize coefficients for an image based on intensity levels.
%   [x0] = INITIALIZECOEFF(I, u, m) initializes coefficients for image I using
%   given intensity levels u and desired dimensions m. The function quantizes
%   the image into different regions based on the intensity levels, applies the
%   inverse discrete cosine transform (IDCT), and then vectorizes the result.
%
% Inputs:
%   I : Input image, a 2D or 3D array.
%   u : Array of intensity levels used for quantization.
%   m : Target dimensions [m1, m2, m3] for the output coefficients.
%
% Output:
%   x0 : Vector of initialized coefficients.
%
% Example:
%   I = imread('cameraman.tif');
%   u = [0, 128, 255];
%   m = [64, 64];
%   x0 = initializeCoeff(I, u, m);
%   % This example will quantize the 'cameraman.tif' into three regions
%   % and then calculate the IDCT coefficients for a 64x64 size.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Check the number of intensity levels
if length(u) > 1
    % Use multilevel thresholding if multiple intensity levels are provided
    thr = multithresh(I, length(u)-1);  % Calculate threshold values
    I0 = imquantize(I, thr, u);         % Quantize image based on thresholds
else
    % For a single intensity level, threshold and scale the image
    I0 = I > u/2;
    I0 = u * single(I0);
end

% Apply the inverse discrete cosine transform to the quantized image
x0 = idctThree(I0);

% Trim the coefficients to match the target dimensions
x0 = x0(1:m(1), 1:m(2), 1:m(3));

% Vectorize the trimmed coefficients
x0 = vec(x0);

end
