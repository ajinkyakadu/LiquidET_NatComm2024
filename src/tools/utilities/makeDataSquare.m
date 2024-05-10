function [data] = makeDataSquare(data)
% makeDataSquare - Resizes a 3D array of 2D images by padding zeros, making the images square
%
% Syntax: data = makeDataSquare(data)
%
% Inputs:
% data - A 3D array of 2D images
%
% Outputs:
% data - A 3D array of square 2D images, padded with zeros if necessary
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

validateInputs(data);

data = padDataWithZeros(data);

end

function validateInputs(data)
if nargin < 1
    error('Not enough input arguments. Expected data.');
end

if ndims(data) ~= 3
    error('Input data must be a 3D array.');
end
end

function data = padDataWithZeros(data)
n = size(data);

if n(1) < n(2)
    paddingSize = [n(2)-n(1), n(2), 0];
    data = padarray(data, paddingSize, 0, 'post');
elseif n(1) > n(2)
    paddingSize = [n(1), n(1)-n(2), 0];
    data = padarray(data, paddingSize, 0, 'post');
end
end