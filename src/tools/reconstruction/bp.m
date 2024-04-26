function backprojection = bp(projections, angles)
%BP Backprojects a set of images onto a volume.
%   backprojection = BP(projections, angles) backprojects a set of 2D or 3D 
%   projections along specified angles into a volume using the ASTRA Toolbox. 
%   The function handles both 2D and 3D projection arrays.
%
% Parameters:
%   projections (2D or 3D array) - Set of projection images.
%   angles (1D array) - Angles in degrees to backproject the images along.
%
% Returns:
%   backprojection (2D or 3D array) - Resulting backprojected volume.
%
% Notes:
%   - Zero degrees corresponds to projecting along the row axis of the volume.
%   - Rows of the projection are parallel to the slices of the volume.
%   - Uses CUDA if available, otherwise defaults to CPU-based methods.
%
% Requires:
%   - ASTRA Toolbox installed and a compatible GPU for CUDA acceleration.
%
% See also:
%   fp, reconstruct
% 
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Check GPU availability
use_cuda = gpuDeviceCount() > 0;

% Determine dimensions and process based on the number of dimensions
if ndims(projections) == 3
    % Handle 3D projections
    [n_rows, n_cols, ~] = size(projections);
    if use_cuda
        % Adjust angles for ASTRA's conventions and backproject
        angles = deg2rad(angles + 90);
        sino = permute(projections, [2 3 1]);
        proj_geom = astra_create_proj_geom('parallel3d', 1, 1, n_rows, n_cols, angles);
        vol_geom = astra_create_vol_geom(n_cols, n_cols, n_rows);
        [id, backprojection] = astra_create_backprojection3d_cuda(sino, proj_geom, vol_geom);
        astra_mex_data3d('delete', id);
    else
        % ASTRA lacks CPU support for 3D backprojection; handle slice-by-slice
        backprojection = zeros(n_cols, n_cols, n_rows, 'like', projections);
        for slice = 1:n_rows
            projections_slice = squeeze(projections(slice, :, :));
            backprojection(:, :, slice) = bp(projections_slice, angles);
        end
    end
elseif ismatrix(projections)
    % Handle 2D projections
    angles = deg2rad(angles);
    n_cols = size(projections, 1);
    sino = projections';
    proj_geom = astra_create_proj_geom('parallel', 1, n_cols, angles);
    vol_geom = astra_create_vol_geom(n_cols, n_cols);
    if use_cuda
        backprojection = astra_create_backprojection_cuda(sino, proj_geom, vol_geom);
        astra_mex_data2d('clear');
    else
        projector_id = astra_create_projector('linear', proj_geom, vol_geom);
        [id, backprojection] = astra_create_backprojection(sino, projector_id);
        astra_mex_data2d('delete', id);
    end
else
    error('Projections must be either 2D or 3D arrays.');
end

end
