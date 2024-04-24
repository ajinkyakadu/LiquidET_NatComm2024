function [I, uval, I0] = rec_csdart(stack, iterations, numMat, options, uval)
%REC_CSDART Performs tomographic reconstruction using the CSDART method.
%   [I, uval, I0] = REC_CSDART(stack, iterations, numMat, options, uval)
%   reconstructs the image I using the given stack of projection data, and
%   optionally returns the used intensity values (uval) and the initial image (I0).
%
% Inputs:
%   stack      : Structure containing the tomographic data and angles.
%   iterations : Number of main iterations for the reconstruction (default: 10).
%   numMat     : Number of materials or intensity levels (default: 1).
%   options    : Options structure for various parameters (default: empty).
%   uval       : Initial intensity values (optional).
%
% Outputs:
%   I     : The reconstructed image.
%   uval  : The intensity values used for reconstruction.
%   I0    : The initial image used for starting the reconstruction.
%
% Example:
%   stack = load('data.mat'); % Assume stack contains data and angles
%   [I, uval, I0] = rec_csdart(stack, 15, 3);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Default parameter handling
if nargin < 2, iterations = 10; end
if nargin < 3, numMat = 1; end
if nargin < 4, options = []; end

% Generate tomography operator and measurements
[W, Y, n, stack] = generateTomoOp(stack);

% Retrieve options with default values
nDCT    = getoptions(options, 'nDCT', floor(0.1 * n));
innerIt = getoptions(options, 'innerIt', 10);
alpha   = getoptions(options, 'alpha', ones(numMat + 1, 1));
kappa0  = getoptions(options, 'kappa', 0.05);
kpUp    = getoptions(options, 'kappaUp', 0.8);
lambda  = getoptions(options, 'lambda', 0);
noiseOrd= getoptions(options, 'noiseOrder', 0);

% Initial image reconstruction using EM algorithm
I0 = rec_em(stack, 20);
I0max = max(I0(:));
I0 = I0 / I0max;
Y  = Y / I0max;

% Compute intensity values if not provided
if nargin < 5
    uval = computeIntensity(I0, numMat, alpha);
    uval = [uval(1)/2; uval];
    thr = 0.5 * (uval(1:end-1) + uval(2:end));
    I0 = imquantize(I0, thr, uval);
else
    thr = 0.5 * (uval(1:end-1) + uval(2:end));
    I0 = imquantize(I0, thr, uval);
end
disp('Intensities:');
disp(uval);

% Set optimization options
optionP = struct('kappa', kappa0, ...
    'kpUp', kpUp, ...
    'epochs', iterations, ...
    'epIter', innerIt, ...
    'lambda', lambda, ...
    'noiseOrder', noiseOrd);

% Perform the inversion to get the reconstructed image
I = solveOptimProbCSDART(W, Y, n, nDCT, I0, uval, optionP);

end
