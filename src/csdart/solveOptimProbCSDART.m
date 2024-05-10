function [If, phif, hist] = solveOptimProbCSDART(A, y, n, kT, Ip0, uval, option)
%SOLVEOPTIMPROBCSDART Solve an optimization problem using CSDART method.
%   [If, phif, hist] = SOLVEOPTIMPROBCSDART(A, y, n, kT, Ip0, uval, option)
%   solves the tomographic reconstruction optimization problem using a
%   constrained simultaneous dual averaging total reconstruction approach.
%
% Inputs:
%   A      : The system matrix or projection matrix.
%   y      : Measurement vector.
%   n      : Dimensions of the reconstructed image.
%   kT     : DCT coefficient sizes and coefficients.
%   Ip0    : Initial image for starting the reconstruction.
%   uval   : Initial intensity values.
%   option : Structure containing options for the optimization.
%
% Outputs:
%   If     : Final reconstructed image.
%   phif   : Final phi values used for reconstruction.
%   hist   : History of optimization containing residuals and other metrics.
%
% Example:
%   A = ... % define or load system matrix
%   y = ... % define or load measurements
%   n = [256 256 256];
%   kT = [64 64 64];
%   Ip0 = rand(256, 256, 256);
%   uval = linspace(0, 1, 5);
%   option = struct('kappa', 0.1, 'kpUp', 0.1, 'epochs', 10, 'epIter', 10);
%   [If, phif, hist] = solveOptimProbCSDART(A, y, n, kT, Ip0, uval, option);
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Handle default options
if nargin < 7, option = []; end
kappa = getoptions(option, 'kappa', 0.1);
kpUp = getoptions(option, 'kpUp', 0.1);
epochs = getoptions(option, 'epochs', 10);
epIter = getoptions(option, 'epIter', 10);
lambda = getoptions(option, 'lambda', 0);
noiseOrder = getoptions(option, 'noiseOrder', 1);

% Initialize coefficients
x0 = initializeCoeff(Ip0, uval, kT); 

% Setup optimization options
optimOpt = struct('maxIter', epIter, 'optTol', 1e-16, 'progTol', 1e-16, ...
                  'memory', 10, 'verbose', 0, 'curvilinear', 1);

% Print header for output
fprintf('=======================================================================================\n');
fprintf('                                    CSDART Approach                                    \n');
fprintf('=======================================================================================\n');
fprintf('image size         : %d x %d x %d \n', n);
fprintf('measurements       : %d x %d \n', size(y));
fprintf('DCT coeff          : %d x %d x %d (total :%d) \n', kT, numel(x0));
fprintf('epochs             : %d (inner_iterations : %d) \n', epochs, epIter);
fprintf('--------------------------------------------------------------------------------------\n');
fprintf('                                         Epoch Info                                   \n');
fprintf('%5s %15s | %10s %10s %10s %16s \n','iter','residual','u1','kappa','nnz(I)','time')
fprintf('--------------------------------------------------------------------------------------\n');

% Main optimization loop
hist = struct('u1', zeros(1, epochs), ...
    'kappa', zeros(1, epochs), ...
    'rel_res', zeros(1, epochs), ...
    'nnzV', zeros(1, epochs));

xIter = x0(:);
kpIter = kappa;
normY = norm(vec(y));
time_hist = 0;

y = gpuArray(single(y));

for i = 1:epochs
    tic;
    [xIter, fIter, I_iter, phi_iter, hist] = optimizeEpoch(xIter, A, y, noiseOrder, uval, n, kT, lambda, kpIter, optimOpt, hist, i, normY);
    kpIter = kpIter * kpUp;
    time_iter = toc;
    time_hist = time_iter + time_hist;
    printEpochInfo(i, hist, time_iter, time_hist, epochs);

    % Early stopping criteria
    if hist.rel_res(i) <= 1e-6 || kpIter < 1e-6
        break;
    end

    plotOrthoSlices(I_iter, Ip0);
end

% Final output processing
[If, phif] = finalizeOutput(xIter, uval, n, kT);

% Print final results
printFinalResults(n, numel(xIter), fIter, hist.rel_res(end));

end


function [xIter, fIter, I_iter, phi_iter, hist] = optimizeEpoch(xIter, A, y, noiseOrder, uval, n, kT, lambda, kpIter, optimOpt, hist, i, normY)
    % Define function handles
    F = @(x) misfitLeastSquares(x, A, y, noiseOrder);
    plsOpt.kappa = kpIter;
    plsOpt.lambda = lambda;
    fh = @(x) CSDARTObjective(x, uval, uval, n, kT, F, plsOpt);
    fp = @(x) projBounds(x, -Inf, Inf);

    % Minimize the objective
    [xIter, fIter] = minConf_SPG(fh, xIter, fp, optimOpt);

    % Generate image
    [I_iter, phi_iter] = generateImage(xIter, uval, uval, n, kT, kpIter);

    % Update history
    hist.u1(i) = mean(uval);
    hist.kappa(i) = single(kpIter);
    hist.rel_res(i) = single(sqrt(2 * fIter) / normY);
    hist.nnzV(i) = single(nnz(I_iter));
end


function [If, phif] = finalizeOutput(xIter, uval, n, kT)
    % Generate final image and phi values
    [If, phif] = generateImage(xIter, uval, uval, n, kT, 1e-9);
end


function printEpochInfo(i, hist, time_iter, time_hist, epochs)
    fprintf('%5d %15.5e | %10.1e %10.1e %10.2e [%4.2e/%4.2e]\n', i, hist.rel_res(i),...
            hist.u1(i), hist.kappa(i), hist.nnzV(i), time_hist, (epochs * time_iter));
end

function printFinalResults(n, numCoeff, fIter, relRes)
    fprintf('--------------------------------------------------------------------------------------\n');
    fprintf('image volume compression: %.0f \n', prod(n) / numCoeff);
    fprintf('absolute residual       : %4.4e \n', fIter);
    fprintf('relative residual       : %4.4e \n', relRes);
    fprintf('=======================================================================================\n');
end
