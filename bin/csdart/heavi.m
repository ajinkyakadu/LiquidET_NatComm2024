function [h, d, s] = heavi(x, epsi)
%HEAVI Smoothed Heaviside function and its derivatives.
%   [h, d, s] = HEAVI(x, epsi) calculates a smoothed Heaviside function h,
%   its first derivative d, and second derivative s, based on the input x
%   and smoothing parameter epsi. The function uses a cosine interpolation
%   within the interval [-epsi, epsi] to smooth transitions.
%
% Inputs:
%   x    : Array of values where the Heaviside and its derivatives are calculated.
%   epsi : Smoothing parameter defining the width of the transition region
%          (default is 1e-16 if not provided).
%
% Outputs:
%   h    : Smoothed Heaviside function.
%   d    : First derivative of the Heaviside function.
%   s    : Second derivative of the Heaviside function (optional).
%
% Example:
%   x = linspace(-1, 1, 100);
%   [h, d, s] = heavi(x, 0.1);
%   plot(x, h, x, d, x, s);
%   legend('Heaviside', 'First derivative', 'Second derivative');
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Set default value for epsi if not provided
if nargin < 2, epsi = 1e-16; end

% Initialize Heaviside function
h = zeros(size(x));
h(x >= epsi) = 1;
h(x <= -epsi) = 0;

% Calculate values within the transition region
id = find(abs(x) < epsi);
if ~isempty(id)
    x1 = (pi/epsi) * x(id);
    h(id) = 0.5 * (1 + x(id) / epsi + (1 / pi) * sin(x1));
end

% Calculate first derivative if requested
if nargout > 1
    d = zeros(size(x));
    if ~isempty(id)
        d(id) = (0.5 / epsi) * (1 + cos(x1));
    end
end

% Calculate second derivative if requested
if nargout > 2
    s = zeros(size(x));
    if ~isempty(id)
        s(id) = -((0.5 * pi) / epsi^2) * sin(x1);
    end
end

end
