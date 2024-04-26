function rec = rec_em(stack, iterations, start_slice, end_slice, time)
%REC_EM Perform reconstruction using the expectation minimization (EM) algorithm.
%   rec = REC_EM(stack) performs reconstruction of the whole stack using 150 iterations.
%   rec = REC_EM(stack, iter) specifies the number of iterations.
%   rec = REC_EM(stack, iter, start_slice, end_slice) specifies the range of 
%       stack rows to use for reconstruction.
%   rec = REC_EM(stack, iter, []) reconstructs the middle row of the stack.
%   rec = REC_EM(stack, iter, start_slice, end_slice, time) shows a progress bar
%       and overall time taken for reconstruction. The default is 1.
%
% Inputs:
%   stack       - Structure containing the tomographic data and corresponding angles.
%   iterations  - Number of iterations for the EM algorithm (default: 150).
%   start_slice - Starting slice index for reconstruction (default: 1).
%   end_slice   - Ending slice index for reconstruction (default: all slices).
%   time        - Flag to display progress and time (default: 1).
%
% Output:
%   rec         - Reconstructed volume based on the specified slices.
%
% Example:
%   stack.data = rand(128, 128, 100);
%   stack.angles = linspace(0, 180, 100);
%   rec = rec_em(stack, 100, 10, 20, 1);
%
% Requires:
%   ASTRA Toolbox installed and a CUDA-supporting GPU.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Validate the presence of a GPU
assert(gpuDeviceCount > 0, 'No CUDA-supporting GPU found. Try using SIRT.');

% Handle default parameters
if nargin < 2, iterations = 150; end  % Default number of iterations
if nargin < 3 || isempty(start_slice), start_slice = 1; end  % Default to the first slice
if nargin < 4 || isempty(end_slice), end_slice = size(stack.data, 1); end  % Default to the last slice
if nargin < 5, time = 1; end  % Default to showing time

% Display the progress initialization message
if time
    disp('Performing reconstruction by expectation minimization (EM) algorithm...');
end

% Validate dimensions and angles
[rows, cols, n_angles] = size(stack.data);
if n_angles ~= length(stack.angles)
    error('Number of specified angles is different from the number of projections in stack.');
end

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
        fprintf('Processing slice %d of %d...\n', slice, end_slice);
    end
    
    % Extract sinogram for the current slice
    sino_slice = squeeze(stack.data(:, :, slice));
    
    % Create sinogram in ASTRA
    sinogram_id = astra_mex_data2d('create', '-sino', proj_geom, sino_slice);
    
    % Create volume data in ASTRA
    reconstruction_id = astra_mex_data2d('create', '-vol', vol_geom);
    
    % Configure and create the EM algorithm object in ASTRA
    cfg = astra_struct('EM_CUDA');
    cfg.ProjectionDataId = sinogram_id;
    cfg.ReconstructionDataId = reconstruction_id;
    alg_id = astra_mex_algorithm('create', cfg);
    
    % Run the reconstruction algorithm
    astra_mex_algorithm('iterate', alg_id, iterations);
    
    % Retrieve reconstructed slice
    rec(:, :, slice - start_slice + 1) = astra_mex_data2d('get', reconstruction_id);
    
    % Cleanup
    astra_mex_algorithm('delete', alg_id);
    astra_mex_data2d('delete', sinogram_id, reconstruction_id);
end

end
