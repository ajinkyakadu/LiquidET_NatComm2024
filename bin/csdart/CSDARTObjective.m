function [f, g] = CSDARTObjective(x, u, t, n, m, funObj, options)
%CSDARTOBJECTIVE Compute the objective and gradient for constrained SDA reconstruction.
%   [f, g] = CSDARTOBJECTIVE(x, u, t, n, m, funObj, options) computes the
%   objective function value 'f' and gradient 'g' for a given reconstruction
%   problem using simultaneous dual averaging (SDA) and total variation regularization.
%
% Inputs:
%   x       : Vector of image pixels.
%   u       : Intensity levels in the image.
%   t       : Thresholds for intensity levels.
%   n       : Size of the padded image.
%   m       : Original image size.
%   funObj  : Handle to the objective function that computes the misfit and gradient.
%   options : Structure containing options for 'kappa' and 'lambda'.
%
% Outputs:
%   f       : Scalar value of the objective function.
%   g       : Gradient of the objective function with respect to x.
%
% Example:
%   x = rand(100,1);
%   u = linspace(100, 200, 10);
%   t = linspace(0, 1, 10);
%   n = [128, 128];
%   m = [100, 100];
%   funObj = @(h) deal(0.5*sum(h.^2), h);
%   options.kappa = 0.1;
%   options.lambda = 0.01;
%   [f, g] = CSDARTObjective(x, u, t, n, m, funObj, options);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Default options
if nargin < 6, options = []; end
kappa = getoptions(options, 'kappa', 0.1);
lambda = getoptions(options, 'lambda', 0);

%% Pre-processing
% Convert to the image domain
x = reshape(x, m);
x = padarray(x, n - m, 'post');

% Level-set using discrete cosine transform
phi = dctThree(x);
phi = vec(phi);
phi = gpuArray(phi);

%% Function and gradient computation
% Heaviside options
phid = (max(phi) - min(phi));
epsi = kappa * phid;

% Initialize heaviside and Dirac-delta functions
h = gpuArray(zeros(size(phi)));
d = gpuArray(zeros(size(phi)));

% Compute heaviside and Dirac-delta for each threshold
for i = 1:length(u)
    [hI, dI] = heavi(phi - t(i), epsi);
    if i > 1
        h = (u(i) - u(i-1)) * hI + h;
        d = (u(i) - u(i-1)) * dI + d;
    else
        h = u(i) * hI;
        d = u(i) * dI;
    end
end

% Gather results from GPU to CPU
h = gather(h);
d = gather(d);

% Compute objective and gradient via function handle
[f, g0] = funObj(h);

% Add regularization if lambda is positive
if lambda > 0
    f = f + 0.5 * lambda * norm(h)^2;
    g1 = idctThree(reshape((g0 + lambda * h) .* d, n));
else
    g1 = idctThree(reshape(g0 .* d, n));
end

% Restrict gradient to original image dimensions and vectorize
g = vec(g1(1:m(1), 1:m(2), 1:m(3)));
g = gather(g);

end
