function [X] = idctThree(X)
%IDCTTHREE Apply the inverse discrete cosine transform to a 3D array.
%   [X] = IDCTTHREE(X) applies the IDCT to the 3D array X sequentially across 
%   all three dimensions. This function utilizes the Type 1 IDCT along each 
%   dimension, modifying the array in-place.
%
% Inputs:
%   X : Input 3D array. The IDCT is applied along each dimension.
%
% Outputs:
%   X : The 3D array after applying the IDCT along each of the three dimensions.
%
% Example:
%   A = rand(5,5,5); % Generate a random 5x5x5 array
%   B = idctThree(A); % Apply the IDCT to A along all three dimensions
%
% Note:
%   This function requires the Signal Processing Toolbox for the idct function.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Apply IDCT along the third dimension
X = idct(X, [], 3, "Type", 1);

% Apply IDCT along the second dimension
X = idct(X, [], 2, "Type", 1);

% Finally, apply IDCT along the first dimension
X = idct(X, [], 1, "Type", 1);

end
