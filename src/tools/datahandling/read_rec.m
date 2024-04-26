function array = read_rec(filename, normalize)
%READ_REC Read REC file as 3D array.
%   array = READ_REC(filename) reads a REC file as a 3D array. The REC file format is
%   typically used to store volume data, such as in electron microscopy and tomography.
%
%   array = READ_REC(filename, normalize) specifies if automatic normalization
%   of data between 0 and 1 is applied. Normalization is true by default.
%
%   array = READ_REC() opens a GUI dialog to select a file to read.
%
% Inputs:
%   filename - String, path to the REC file.
%   normalize - Logical, true if normalization between 0 and 1 is to be applied (default: true).
%
% Output:
%   array - 3D array containing the volume data from the REC file.
%
% Example:
%   volData = read_rec('sample.rec', true);
%
% See also:
%   uigetfile, fopen, fread, fclose

% Handle input arguments
if nargin < 2, normalize = true; end
if nargin < 1, filename = find_rec(); end
if isempty(filename), error('No file selected.'); end

% Open file
fid = fopen(filename, 'r');
if fid == -1
    error('Failed to open file: %s', filename);
end

% Read dimensions
nx = fread(fid, 1, '*int32');
ny = fread(fid, 1, '*int32');
nz = fread(fid, 1, '*int32');

% Read data type
datatype = fread(fid, 1, '*int32');
datatype = getDataType(datatype);

% Read header size and skip to data start
fseek(fid, 92, 'bof'); % Move to header size location
header_size = fread(fid, 1, '*int32');
fseek(fid, 1024 + header_size, 'bof'); % Skip to start of data

% Read volume data
volumeData = fread(fid, nx*ny*nz, datatype);
array = reshape(volumeData, [nx ny nz]);
array = permute(array, [2 1 3]); % Adjust dimensions to standard orientation

% Close file
fclose(fid);

% Normalize data if requested
if normalize
    array = normalizeData(array);
end

end

function datatype = getDataType(code)
% Retrieve the MATLAB datatype string based on the REC file code.
switch code
    case 0, datatype = '*uint8';
    case 1, datatype = '*int16';
    case 2, datatype = '*float32';
    case 6, datatype = '*uint16';
    otherwise, error('Unsupported datatype code %d in REC file', code);
end
end

function data = normalizeData(data)
% Normalize data to the range 0 to 1.
data = double(data);
data = (data - min(data(:))) / (max(data(:)) - min(data(:)));
end

function filename = find_rec()
% Open a file dialog to select a REC file.
[filename, pathname] = uigetfile({'*.rec';'*.mrc'}, 'Select a REC file');
if isequal(filename, 0)
    filename = [];
else
    filename = fullfile(pathname, filename);
end
end
