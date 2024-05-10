function rec = rec_em(stack, iterations, start_slice, end_slice, time)
%REC_EM Perform reconstruction using expectation minimization algorithm.
%   REC = REC_EM(STACK) - performs reconstruction of the whole stack using 150 iterations.
%   REC = REC_EM(STACK, ITER) - specify the numer of iterations.
%   REC = REC_EM(STACK, ITER, START_SLICE, END_SLICE) - specify the range of stack
%       rows to use for reconstruction.
%   REC = REC_EM(STACK, ITER, []) - reconstructs the middle row of the stack.
%   REC = REC_EM(STACK, ITER, START_SLICE, END_SLICE, TIME) - show progressbar
%       and overall time taken for reconstruction. Default 1.
%
% Inputs:
%   stack       - Structure containing the tomographic data and corresponding angles.
%   iterations  - Number of iterations for the EM algorithm (default: 150).
%   time        - Flag to display progress and time (default: 1).
%
% Output:
%   rec         - Reconstructed volume based on the specified slices.
%
% Example:
%   stack.data = rand(128, 128, 100);
%   stack.angles = linspace(0, 180, 100);
%   rec = rec_em(stack, 100, 10, 100, 1);
%
% Requires:
%   ASTRA Toolbox installed and a CUDA-supporting GPU.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

assert(gpuDeviceCount > 0, 'No CUDA-supporting GPU found. Try using SIRT');

if nargin < 5, time = 1; end
if time
    disp('Performing reconstruction by expectation maximization (EM) algorithm...\n');
end

if ndims(stack.data) == 3    
    [rows,cols,n_angles] = size(stack.data);
    sino = permute(stack.data,[3 2 1]);
elseif ndims(stack.data) == 2
    [cols,n_angles] = size(stack.data);
    rows = 1;
    sino = stack.data';
else
    error('Stack data should be 2D or 1D projections')
end

if n_angles ~= length(stack.angles)
    error('Number of specified angles is different from number of projections in stack.')
end

if nargin < 2, iterations = 15; end
if nargin < 3, start_slice = 1; end
if nargin < 4, end_slice = size(stack.data, 1); end

% Convert angles to radians
angles = deg2rad(stack.angles);

% Set geometry in ASTRA
proj_geom = astra_create_proj_geom('parallel', 1, cols, angles);
vol_geom = astra_create_vol_geom(cols, cols);

% Allocate array for reconstruction
rec = zeros(cols, cols, end_slice - start_slice + 1);

% Iterate through all needed slices
for slice = start_slice:end_slice
    % Print progress if needed
    if time
        show_progress(slice, start_slice, end_slice);
    end
    % Convert slice to 2D array
    sino_slice = squeeze(sino(:,:,slice));
    % Send sinogram to ASTRA
    sinogram_id = astra_mex_data2d('create','-sino', proj_geom, sino_slice);
    % Allocate space for slice reconstruction is ASTRA
    reconstruction_id = astra_mex_data2d('create', '-vol', vol_geom, 1);
    % Initialize algorithm
    cfg = astra_struct('EM_CUDA');
    cfg.ProjectionDataId = sinogram_id;
    cfg.ReconstructionDataId = reconstruction_id;
    algId = astra_mex_algorithm('create', cfg);
    % Perform reconstruction of the slice
    astra_mex_algorithm('iterate', algId, iterations);
    % Save reconstructed slice
    rec(:,:,slice-start_slice+1) = astra_mex_data2d('get', reconstruction_id);
    % Clean GPU memory
    astra_mex_algorithm('delete', algId)
    astra_mex_data2d('delete', sinogram_id, reconstruction_id)
end