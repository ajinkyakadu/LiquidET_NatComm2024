function str = time2str(t)
%TIME2STR Converts time in seconds to a formatted string in 'hh:mm:ss' format.
%
% Usage:
%   str = TIME2STR(t)
%
% Input:
%   t - Time in seconds, a non-negative scalar.
%
% Output:
%   str - Formatted time string in 'hh:mm:ss' format.
%
% Examples:
%   str1 = time2str(3661); % returns '01:01:01'
%   str2 = time2str(45);   % returns '00:00:45'
%   str3 = time2str(360);  % returns '00:06:00'
%
% Note:
%   This function is designed to handle non-negative inputs. If a negative
%   input is provided, it will still compute a valid time string, assuming
%   the absolute value of the time.
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Ensure input is non-negative
t = abs(t);

% Calculate hours, minutes, and seconds
hours = floor(t / 3600);
minutes = floor(mod(t, 3600) / 60);
seconds = mod(t, 60);

% Format the string as 'hh:mm:ss'
str = sprintf('%02d:%02d:%02d', hours, minutes, seconds);
end
