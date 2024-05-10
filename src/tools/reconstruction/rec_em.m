function rec = rec_em(stack, iterations, time)
%REC_EM Perform reconstruction using the expectation minimization (EM) algorithm.
%   rec = REC_EM(stack) performs reconstruction of the whole stack using 150 iterations.
%   rec = REC_EM(stack, iter) specifies the number of iterations.
%   rec = REC_EM(stack, iter, start_slice, end_slice) specifies the range of 
%       stack rows to use for reconstruction.
%   rec = REC_EM(stack, iter, time) shows a progress bar
%       and overall time taken for reconstruction. The default is 1.
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
%   rec = rec_em(stack, 100, 1);
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

if nargin < 2 || isempty(iterations), iterations = 15; end
if nargin < 3, time = true; end

if  ~isa(stack, 'TiltSeries') && ...
    ~(isfield(stack, 'data') && isfield(stack, 'angles'))
    error(['Insufficient data. The input must provide a series of ' ...
           'images and the corresponding tilt angles'])
end

if ismatrix(stack.data)
    stack.data = reshape(stack.data, ...
                               [1 size(stack.data)]);
end

[n_rows, n_columns, n_angles] = size(stack.data);

if n_angles ~= length(stack.angles)
    error(['Number of specified angles is different from number of ' ...
           'projections in stack.'])
end

% We will reconstruct the object slice-by-slice, so geometry is 2D
% In Astra the object is assumed to be rotating around vertical axis
angles = deg2rad(stack.angles);
proj_geom = astra_create_proj_geom('parallel', 1, n_columns, angles);
vol_geom = astra_create_vol_geom(n_columns, n_columns);
stack.data = permute(stack.data, [3 2 1]); % To simplify slicing
reconstruction = zeros(n_columns, n_columns, n_rows, 'like', stack.data);

if time
    disp(['Performing reconstruction using EM algorithm...']);
    progress_bar = ConsoleProgressbar(n_rows);
end

initial_value = 1;

for slice = 1:n_rows
    % Convert slice to 2D array
    sino_slice = stack.data(:, :, slice);
    % Send sinogram to ASTRA
    sinogram_id = astra_mex_data2d('create','-sino', proj_geom, sino_slice);
    % Allocate space for slice reconstruction in ASTRA
    reconstruction_id = astra_mex_data2d('create', '-vol', vol_geom, initial_value);

    % Initialize algorithm
    algorithm_config = astra_struct('EM_CUDA');
    algorithm_config.ProjectionDataId = sinogram_id;
    algorithm_config.ReconstructionDataId = reconstruction_id;
    algorithm_id = astra_mex_algorithm('create', algorithm_config);

    % Perform reconstruction of the slice
    astra_mex_algorithm('iterate', algorithm_id, iterations);

    % Save reconstructed slice
    reconstruction(:,:,slice) = astra_mex_data2d('get', reconstruction_id);

    % Clean GPU memory
    astra_mex_algorithm('delete', algorithm_id)
    astra_mex_data2d('delete', sinogram_id, reconstruction_id)

    % Print progress if needed
    if time
        progress_bar.update();
    end
end