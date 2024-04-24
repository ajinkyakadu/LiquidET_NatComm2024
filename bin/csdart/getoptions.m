function v = getoptions(options, name, v, mandatory)
%GETOPTIONS Retrieve an option parameter from a structure.
%   v = GETOPTIONS(options, name, v, mandatory) checks if the 'name' field 
%   exists within the 'options' structure. If it exists, the function returns 
%   its value. If it does not exist and 'mandatory' is true, it throws an error.
%   If 'mandatory' is false or omitted, it returns the default value 'v'.
%
% Inputs:
%   options   : A structure containing option name-value pairs.
%   name      : A string specifying the name of the option to retrieve.
%   v         : The default value to return if the option is not found.
%   mandatory : A logical flag indicating if the option is mandatory (optional).
%
% Outputs:
%   v : The value of the specified option or the default value.
%
% Example:
%   opts.color = 'blue';
%   color = getoptions(opts, 'color', 'red');  % Returns 'blue'
%   size = getoptions(opts, 'size', 10);       % Returns 10
%   % Below will throw an error because 'height' is mandatory and missing
%   height = getoptions(opts, 'height', [], true);  
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

if nargin < 4, mandatory = 0; end % Check if 'mandatory' parameter was provided

if isfield(options, name)
    v = eval(['options.' name ';']); % Retrieve the value from options
elseif mandatory
    error(['You have to provide options.' name '.']); % Throw error if missing mandatory field
end

end
