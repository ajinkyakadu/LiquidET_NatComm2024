function [f, g] = misfitLeastSquares(x, A, y, k)
%MISFITLEASTSQUARES Compute the weighted least squares misfit and gradient.
%   [f, g] = MISFITLEASTSQUARES(x, A, y, k) computes the weighted least 
%   squares misfit and its gradient for the model parameters x, given the 
%   matrix A, data y, and the nonlinearity parameter k. The weight is 
%   computed as 1/(1 + y.^k).
%
% Inputs:
%   x : Column vector of model parameters.
%   A : Matrix relating the model parameters x to the observations.
%   y : Column vector of observations.
%   k : Scalar exponent used in the weighting function (optional; default=1).
%
% Outputs:
%   f : Scalar value of the weighted least squares misfit.
%   g : Gradient of the misfit with respect to x.
%
% Example:
%   x = randn(10,1);
%   A = randn(20,10);
%   y = randn(20,1);
%   [f, g] = misfitLeastSquares(x, A, y);
%   % Compute the function and gradient for default k=1
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Default value for nonlinearity parameter
if nargin < 4, k = 1; end

% Compute A*x and move to GPU for faster computation
Ax = gpuArray(A * x);

% Compute the residuals
res = Ax - y;

% Compute the weights, which depend non-linearly on y
D = 1 ./ (1 + y .^ k);

% Apply the weights to the residuals
Dres = D .* res;

% Compute the misfit function
f = 0.5 * norm(Dres, 'fro')^2;

% Compute the gradient of the misfit
g = A' * gather(D .* Dres);

% Gather the scalar misfit from the GPU to CPU
f = gather(f);

end
