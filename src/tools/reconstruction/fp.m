function projection = fp(volume, projection_angles)
%FP Forward projection of a volume along specified angles.
%   projection = FP(volume, projection_angles) creates a set of projections
%   from a 2D or 3D volume at specified angles using the ASTRA Toolbox. The 
%   function handles both 2D and 3D volumes and leverages GPU capabilities if
%   available.
%
% Parameters:
%   volume (2D or 3D array) - Input volume from which projections are to be made.
%   projection_angles (1D array) - Angles in degrees at which projections are required.
%
% Returns:
%   projection (2D or 3D array) - Resulting projections.
%
% Notes:
%   - Zero degrees corresponds to projecting along the row axis of the volume.
%   - Projections are aligned with the slices of the volume.
%
% Requires:
%   - ASTRA Toolbox installed and a compatible GPU for CUDA acceleration.
%
% See also:
%   bp, reconstruct
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Check for GPU availability
use_cuda = gpuDeviceCount() > 0;

% Process according to the dimensionality of the input volume
if ndims(volume) == 3
    % Handle 3D volume
    [n_rows, n_columns, n_slices] = size(volume);
    proj_width = max(n_rows, n_columns);
    % Adjust volume data type for compatibility with ASTRA
    volume = double(volume);
    
    if use_cuda
        % Adjust angles for ASTRA's conventions and calculate projections
        projection_angles = deg2rad(projection_angles + 90);
        vol_geom = astra_create_vol_geom(n_columns, n_rows, n_slices);
        proj_geom = astra_create_proj_geom('parallel3d', 1, 1, n_slices, proj_width, projection_angles);
        [id, sino] = astra_create_sino3d_cuda(volume, proj_geom, vol_geom);
        astra_mex_data3d('delete', id);
        projection = permute(sino, [3 1 2]);
    else
        % Handle lack of 3D CPU projection support in ASTRA by processing slice-by-slice
        projection = zeros(proj_width, proj_width, length(projection_angles), 'like', volume);
        for slice = 1:n_slices
            projection(:,:,slice) = fp(volume(:,:,slice), projection_angles);
        end
    end
elseif ismatrix(volume)
    % Handle 2D volume
    projection_angles = deg2rad(projection_angles);
    [n_rows, n_columns] = size(volume);
    vol_geom = astra_create_vol_geom(n_rows, n_columns);
    proj_geom = astra_create_proj_geom('parallel', 1, n_rows, projection_angles);
    
    if use_cuda
        [id, sino] = astra_create_sino_cuda(volume, proj_geom, vol_geom);
    else
        projector_id = astra_create_projector('linear', proj_geom, vol_geom);
        [id, sino] = astra_create_sino(volume, projector_id);
    end
    astra_mex_data2d('delete', id);
    projection = sino';
else
    error('Input volume must be either a 2D or 3D array.');
end

end
