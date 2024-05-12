%% ex01__step02_N4Liquid.m
% Quantitative Indicators on N=4 colloidal assembly acquired in HAADF-STEM
% mode with liquid-cell holder
% Note that the reconstruction must be obtained with CS-DART-type 
% reconstruction algorithm
%
% This script computes various quantitative descriptors from the 3D
% reconstructed volume and saves the results.
% 
% Author:
%   Ajinkya Kadu
%   EMAT, May 20, 2023

%% Clean up the workspace and close all figures

clc; 
clearvars; 
close all;


%% Initialization

% The 'home_folder' is assumed to be the parent directory of 'examples'
homeDir = '../';
dataDir = fullfile(homeDir, 'data/N4/');  % Data directory where results are saved

stack.pix_sz = 0.367; % Pixel size in nm (adjust according to your acquisition parameters)

%% Load reconstructed volume

reconFile = fullfile(dataDir, 'csdart_reconstructed_volume.rec');
I = read_rec(reconFile);

%% Process volume 
% Parameters for processing:
% - cropRadius: Used to define the cropping around detected particles; 0.8-1.0 based on visibility
% - minArea: Minimum voxel count to consider an object a particle; depends on expected size

cropRadius = 0.9; % Define cropping radius (relative to the particle size)
minArea    = 150; % Minimum area (in pixels) for consideration in particle statistics


% Process the reconstruction to detect particles and refine the volume
[K, It] = processCSDARTRec(I, cropRadius, minArea);

%% Compute statistics for each particle

% Initialize matrices to store particle properties
N = length(K); % Number of detected particles
PartCentroid            = zeros(N, 3);
PartVolume              = zeros(N, 1);
PartSurfaceArea         = zeros(N, 1);
PartSolidity            = zeros(N, 1);
PartPrincipleAxisLength = zeros(N, 3);

% Compute per-particle properties using regionprops3
for i = 1:N
    stats = regionprops3(K{i}, 'Centroid', 'Volume', 'SurfaceArea', 'Solidity', 'PrincipalAxisLength');
    PartCentroid(i, :)              = stats.Centroid;
    PartVolume(i)                   = stats.Volume;
    PartSurfaceArea(i)              = stats.SurfaceArea;
    PartSolidity(i)                 = stats.Solidity;
    PartPrincipleAxisLength(i, :)   = stats.PrincipalAxisLength;
end

%% Compute global shape properties using alpha shape
% Alpha shape to describe the overall geometry of the assembly
% Adjust the alpha radius based on the particle spacing and distribution

shp = alphaShape(PartCentroid(:, 1), PartCentroid(:, 2), PartCentroid(:, 3));

%% Compute shape parameters
% Compute various metrics from the alpha shape to describe the global structure

ShpAlphaSpectrum = alphaSpectrum(shp);
ShpCriticalAlpha = criticalAlpha(shp, "all-points");
ShpSurfaceArea   = surfaceArea(shp);
ShpVolume        = volume(shp);
ShpRegIndex      = computeRegularityIndex(shp);

%% Save data

% Structure to hold all quantitative descriptors
strOut = struct();
strOut.centroid         = PartCentroid;
strOut.volume           = PartVolume * stack.pix_sz^3;
strOut.surfaceArea      = PartSurfaceArea * stack.pix_sz^2;
strOut.solidity         = PartSolidity;
strOut.principleAxLength= PartPrincipleAxisLength;
strOut.n_voxels         = size(I);

% Additional shape properties
strOut.shape = struct('object', shp, ...
                      'alphaSpectrum', ShpAlphaSpectrum, ...
                      'criticalAlpha', ShpCriticalAlpha, ...
                      'surfaceArea', ShpSurfaceArea * stack.pix_sz^2, ...
                      'volume', ShpVolume * stack.pix_sz^3, ...
                      'RegularityIndex', ShpRegIndex);

% Mean inter-particle distance
strOut.meanID = mean(pdist(strOut.centroid) * stack.pix_sz);

% Save the structured output to the same directory as the input data
save([saveDir 'quant_descriptors_NP.mat'], 'strOut');

%% Visualize the alpha shape of the assembly

figure;
plot(shp);
title('Alpha Shape of the Assembly');
xlabel('X (pixels)');
ylabel('Y (pixels)');
zlabel('Z (pixels)');
axis equal;
grid on;

%% Display the structure output for review

disp('Structured Output:');
disp(strOut);
disp('Shape Metrics:');
disp(strOut.shape);
