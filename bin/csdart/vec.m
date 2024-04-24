function [x] = vec(x)
%VEC Convert a matrix to a column vector.
%   [x] = VEC(x) takes a matrix x and reshapes it into a column vector.
%
% Inputs:
%   x : Input matrix of any size or a vector.
%
% Outputs:
%   x : Output column vector.
%
% Example:
%   A = [1 2; 3 4];
%   B = vec(A);
%   % Now B is [1; 2; 3; 4]
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

x = x(:); % Reshape input matrix to a column vector

end
