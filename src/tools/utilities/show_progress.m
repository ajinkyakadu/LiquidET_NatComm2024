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

L = 30; % Length of progress bar
buf = ''; % Create buffer to accumulate output

if i == N1
    t_start = tic; % Remember the timestamp of start
    t_prev = t_start;
elseif toc(t_prev) < 0.1  && i ~= N2 % Add limit on update frequecy
    return
else
    t_prev = tic; % Reset update timeout
    for k = 1:(L + 40)
        buf = [buf '\b']; % Clear output from the previous iteration
    end
end

if N2 ~= N1
    p = (i - N1) / (N2 - N1) / step; % Current progress as fraction of time
else
    p = 1;
end

buf = [buf '['];
for k = 1:round(L * p) % Fill progress bar for elapsed time
    buf = [buf '#'];
end
for k = 1:(L - round(L * p)) % Fill the rest with white spaces
    buf = [buf '.'];
end
buf = [buf ']'];

buf = [buf sprintf('%4d', round(100 * p)) '%%']; % Print progress in percents

% Print elapsed time and time left in mm:ss format
elapsed = toc(t_start);
if p > 0 % Avoid division by zero
    left = elapsed / p - elapsed;
else
    left = 0;
end
buf = [buf sprintf(' (elapsed/left: %s/%s)\n', time2str(elapsed), time2str(left))];
% Print to stdout
fprintf(buf);

end