function [X] = dctThree(X)
%DCTTHREE Apply the discrete cosine transform to a 3D array.
%   [X] = DCTTHREE(X) applies the DCT to the 3D array X sequentially across 
%   all three dimensions. This function uses the Type 1 DCT along each 
%   dimension, modifying the array in-place.
%
% Inputs:
%   X : Input 3D array. The DCT is applied along each dimension.
%
% Outputs:
%   X : The 3D array after applying the DCT along each of the three dimensions.
%
% Example:
%   A = rand(5,5,5); % Generate a random 5x5x5 array
%   B = dctThree(A); % Apply the DCT to A along all three dimensions
%
% Note:
%   This function requires the Signal Processing Toolbox for the dct function.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Apply DCT along the first dimension
X = dct(X, [], 1, "Type", 1);

% Apply DCT along the second dimension
X = dct(X, [], 2, "Type", 1);

% Finally, apply DCT along the third dimension
X = dct(X, [], 3, "Type", 1);

end
