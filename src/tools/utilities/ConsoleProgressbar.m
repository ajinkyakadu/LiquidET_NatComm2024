classdef ConsoleProgressbar < handle
% ConsoleProgressbar Prints current progress and timings of a for loop in the console.
%
% Example:
%   pbar = ConsoleProgressbar(100);
%   for i = 1:100
%       pbar.update();
%       pause(0.1); % Simulated task
%   end
% 
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023


    properties (Access = private)
        total_iterations % Total number of iterations expected
        current_iteration % Current iteration number
        length % Length of the progress bar in characters
        start_time % Timer handle for tracking total elapsed time
        prev_iter_time % Time since last update was printed
    end

    methods
        function obj = ConsoleProgressbar(total_iterations, length)
            % Constructor for ConsoleProgressbar
            % Inputs:
            %   total_iterations - Integer, total number of iterations to expect
            %   length - Optional, length of the progress bar; default is 30 characters
            
            if nargin < 2
                length = 30; % Default length of the progress bar
            end
            obj.total_iterations = total_iterations;
            obj.current_iteration = 0;
            obj.length = length;
            obj.start_time = tic();
            obj.prev_iter_time = tic();
            fprintf('\n'); % Ensure the progress starts on a new line
        end

        function update(obj)
            % Updates the progress bar display with current progress and estimated time left
            if toc(obj.prev_iter_time) < 0.1 && obj.current_iteration ~= obj.total_iterations
                return;
            end
            obj.current_iteration = obj.current_iteration + 1;

            % Calculate the fraction of work done
            fraction_done = obj.current_iteration / obj.total_iterations;

            % Calculate progress bar segments
            num_hashes = round(obj.length * fraction_done);
            num_dots = obj.length - num_hashes;

            % Calculate times
            elapsed_time = toc(obj.start_time);
            estimated_total = elapsed_time / fraction_done;
            time_left = estimated_total - elapsed_time;

            % Assemble the display buffer
            progress_str = ['[', repmat('#', 1, num_hashes), repmat('.', 1, num_dots), ']'];
            percent_done = sprintf(' %3.0f%% ', fraction_done * 100);
            time_str = sprintf('Elapsed/Left: %s/%s', time2str(elapsed_time), time2str(time_left));
            
            % Print the progress bar
            fprintf(repmat('\b', 1, length(obj.prev_str)));
            obj.prev_str = [progress_str percent_done time_str];
            fprintf(obj.prev_str);

            obj.prev_iter_time = tic(); % Reset the timer for update frequency
        end
    end
end
