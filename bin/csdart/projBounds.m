function [x] = projBounds(x, LB, UB)
%PROJBOUNDS Project elements of a vector or matrix to specified bounds.
%   [x] = PROJBOUNDS(x, LB, UB) sets the elements of x that are below the 
%   lower bound (LB) to LB, and those above the upper bound (UB) to UB.
%
% Inputs:
%   x  : Input vector or matrix.
%   LB : Scalar or array of the same size as x specifying the lower bounds.
%   UB : Scalar or array of the same size as x specifying the upper bounds.
%
% Outputs:
%   x  : Output vector or matrix with values projected within the bounds.
%
% Example:
%   A = [1, 2, 3; 4, 5, 6];
%   LB = 2;
%   UB = 5;
%   B = projBounds(A, LB, UB);
%   % Now B is [2, 2, 3; 4, 5, 5]
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Apply lower bound
x(x < LB) = LB;

% Apply upper bound
x(x > UB) = UB;

end
