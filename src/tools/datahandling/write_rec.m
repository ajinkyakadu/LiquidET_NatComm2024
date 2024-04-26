function write_rec(array, filename, pixelsize, normalize)
%WRITE_REC Save 3D array as REC file.
%   WRITE_REC(ARRAY, FILENAME) saves the 3D ARRAY as a REC file, assuming a
%   pixel size of 1 and normalization applied.
%
%   WRITE_REC(ARRAY, FILENAME, PIXELSIZE) additionally specifies the pixel size
%   for saving physical dimensions of the data.
%
%   WRITE_REC(ARRAY, FILENAME, PIXELSIZE, NORMALIZE) specifies whether
%   automatic normalization of data between 0 and 1 is applied. Default is true.
%
% Inputs:
%   array      - 3D array to be saved.
%   filename   - String specifying the path and filename of the REC file.
%   pixelsize  - Numeric scalar specifying the pixel size. Default is 1.
%   normalize  - Logical flag indicating whether to normalize the array. Default is true.
%
% Example:
%   vol = rand(100, 100, 100); % Example volume data
%   write_rec(vol, 'output.rec', 0.5, true); % Save with pixel size 0.5 and normalization
%
% Note:
%   The function expects `array` to be a 3D numeric array. The file is saved
%   in a format compatible with typical REC file readers and conforms to the
%   conventions used by FEI software.
%
% Author:
%   Ajinkya Kadu
%   EMAT, May 20, 2023

% Input handling
if nargin < 4, normalize = 1; end
if nargin < 3, pixelsize = 1; end

% Usually structures are stacks of projection images with some metadata
if isstruct(array)
    array = array.data;
    pixelsize = array.pixelsize;
    warning(['This function is intended for saving 3D array in REC format.' ...
             'To save projection stack use `write_mrc` function']);
end

array = rot90(array); % Rotate data 90 degrees to match FEI convention

% Assemble standard header
std_header = zeros(256, 1, 'int32');
sizes = size(array);
std_header(1:3) = sizes; % Number of columns, rows, sections

if normalize || isa(array, 'single')
    std_header(4) = 2;
elseif isa(array, 'uint8')
    std_header(4) = 0;
elseif isa(array, 'int16')
    std_header(4) = 1;
elseif isa(array, 'uint16')
    std_header(4) = 6;
else
    error('Unsupported data type for writing in REC file.');
end
    
std_header(8:10) = sizes; % Number of intervals along x, y and z
std_header(11:13) = typecast(single(sizes * pixelsize * 0.1), 'int32'); % Physical dimensions in angstroms
std_header(24) = 4*32*1024; % Size of extended header

% Extended header is empty for volume data
ext_header = zeros(32*1024, 1, 'single');

% Write headers and data
fid = fopen(filename, 'w');
fwrite(fid, std_header, 'int32');
fwrite(fid, ext_header, 'float32');
if normalize
    array = single(array);
    array = array - min(array(:));
    array = array / max(array(:));
end
fwrite(fid, array, class(array));

% Add magic cookie to mimick FEI software
fseek(fid, 224, 'bof');
fwrite(fid, 'Fei Company (C) Copyright 2003', 'char');

fclose(fid);

end