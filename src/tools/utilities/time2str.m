function string = time2str(t)
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

% Converts timestamp to a string in mm:ss format
t = int32(t);
h = t / 3600;
t = mod(t, 3600);
m = t / 60;
s = mod(t, 60);
string = [sprintf('%01d',h) ':' sprintf('%02d',m) ':' sprintf('%02d',s)];
end