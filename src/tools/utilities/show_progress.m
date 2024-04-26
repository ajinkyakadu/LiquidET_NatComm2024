function show_progress(i, N1, N2, step)
%SHOW_PROGRESS Prints current progress and timings of a FOR loop.
%   SHOW_PROGRESS(I, N) prints a progress bar, current progress in percent,
%   and time elapsed/left based on the number of current iteration I and total
%   number of iterations N.
%   SHOW_PROGRESS(I, N1, N2) assumes iterations are between N1 and N2.
%   SHOW_PROGRESS(I, N1, N2, STEP) allows specifying an increment STEP
%   between iterations.
%
%   Parameters:
%   I    - Current iteration number.
%   N1   - Starting iteration number or total number of iterations if N2 is not provided.
%   N2   - Ending iteration number (optional).
%   STEP - Increment between iterations (optional, default is 1).
%
%   This function uses persistent variables to track the start time and
%   previous update time to manage output frequency and calculate time estimates.
%
%   Example:
%   for i = 1:100
%       show_progress(i, 100);
%       pause(0.1); % Simulated work
%   end
%
%   Author:
%       Ajinkya Kadu
%       EMAT, University of Antwerp
% 
%   May 20, 2023


persistent t_start t_prev

if nargin < 4, step = 1; end
if nargin < 3
    N2 = N1;
    N1 = 1;
end

L = 30; % Length of the progress bar
buf = ''; % Initialize buffer for building output string

% Start timing and initialize on the first iteration
if i == N1
    t_start = tic; % Store the start time
    t_prev = tic;  % Initialize previous update time
elseif toc(t_prev) < 0.1 && i ~= N2 % Limit update frequency
    return
else
    t_prev = tic; % Update the previous update time
    buf = repmat('\b', 1, L + 40); % Prepare to clear previous output
end

% Calculate progress percentage
p = (i - N1) / ((N2 - N1 + step) / step);

% Build progress bar string
bar = ['[' repmat('#', 1, round(L * p)) repmat('.', 1, L - round(L * p)) ']'];
percent = sprintf('%4d%%', round(100 * p)); % Format progress in percent

% Calculate elapsed and remaining time
elapsed = toc(t_start);
remaining = (elapsed / p) - elapsed; % Estimate remaining time

% Format times and build final string for output
time_str = sprintf(' (elapsed/left: %s/%s)\n', time2str(elapsed), time2str(remaining));
fprintf([buf bar percent time_str]);

end

