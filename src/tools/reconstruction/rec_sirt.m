function rec = rec_sirt(stack, iterations, start_slice, end_slice, time)
%REC_SIRT Perform reconstruction using Simultaneous Iterative Reconstruction Technique (SIRT).
%   rec = REC_SIRT(stack) performs reconstruction of the entire stack using 150 iterations.
%   rec = REC_SIRT(stack, iter) specifies the number of iterations.
%   rec = REC_SIRT(stack, iter, start_slice, end_slice) specifies the range of stack
%       slices to use for reconstruction.
%   rec = REC_SIRT(stack, iter, [], []) reconstructs the middle slice of the stack.
%   rec = REC_SIRT(stack, iter, start_slice, end_slice, time) shows a progress bar
%       and reports the overall time taken for reconstruction. Default is enabled (1).
%
% Inputs:
%   stack       - Structure containing the tomographic data and corresponding angles.
%   iterations  - Number of iterations for the SIRT algorithm (default: 150).
%   start_slice - Starting slice index for reconstruction (default: 1).
%   end_slice   - Ending slice index for reconstruction (default: all slices).
%   time        - Flag to display progress and time (default: 1).
%
% Output:
%   rec         - Reconstructed volume from the specified slices.
%
% Example:
%   stack.data = rand(128, 128, 100);  % Synthetic projection data
%   stack.angles = linspace(0, 180, 100);  % Projection angles
%   rec = rec_sirt(stack, 100, 10, 20);  % Perform reconstruction
%
% Requires:
%   ASTRA Toolbox installed and a CUDA-supporting GPU.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Validate input parameters and set defaults
if nargin < 5, time = 1; end
if nargin < 2 || isempty(iterations), iterations = 150; end
if nargin < 3 || isempty(start_slice), start_slice = 1; end
if nargin < 4 || isempty(end_slice), end_slice = size(stack.data, 1); end

% Ensure data is suitable for reconstruction
if ndims(stack.data) ~= 2 && ndims(stack.data) ~= 3
    error('Stack data should be 2D or 3D projections');
end
if size(stack.data, 3) ~= length(stack.angles)
    error('Number of specified angles does not match the number of projections in the stack.');
end

% Setup for reconstruction
cols = size(stack.data, 2);
angles_rad = deg2rad(stack.angles); % Convert angles to radians

% Create ASTRA geometries
proj_geom = astra_create_proj_geom('parallel', 1, cols, angles_rad);
vol_geom = astra_create_vol_geom(cols, cols);

% Initialize the reconstruction volume
rec = zeros(cols, cols, end_slice - start_slice + 1, 'single');

% Choose SIRT configuration based on GPU availability
cfg = astra_struct(gpuDeviceCount() > 0 ? 'SIRT_CUDA' : 'SIRT');
if ~contains(cfg.type, 'CUDA')
    cfg.ProjectorId = astra_create_projector('linear', proj_geom, vol_geom);
end

% Reconstruction loop for each slice
for slice = start_slice:end_slice
    if time
        fprintf('Processing slice %d of %d...\n', slice, end_slice);
    end
    
    sino_slice = squeeze(stack.data(:, :, slice));
    sino_id = astra_mex_data2d('create', '-sino', proj_geom, sino_slice);
    rec_id = astra_mex_data2d('create', '-vol', vol_geom);

    % Setup and run the algorithm
    cfg.ProjectionDataId = sino_id;
    cfg.ReconstructionDataId = rec_id;
    alg_id = astra_mex_algorithm('create', cfg);
    astra_mex_algorithm('iterate', alg_id, iterations);

    % Retrieve the reconstructed slice
    rec(:,:,slice-start_slice+1) = astra_mex_data2d('get', rec_id);

    % Cleanup
    astra_mex_algorithm('delete', alg_id);
    astra_mex_data2d('delete', sino_id, rec_id);
end

end
