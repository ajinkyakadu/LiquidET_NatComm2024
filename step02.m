%% ex01__step02_N4Liquid.m
% Quantitative Indicators on N=4 colloidal assembly acquired in HAADF-STEM
% mode with liquid-cell holder
% Note that the reconstruction must be obtained with CS-DART-type 
% reconstruction  algorithm
% 
% Author:
%   Ajinkya Kadu
%   EMAT, May 20, 2023

%% Clean up the workspace and close all figures

clc; clearvars; close all;

%% Initialization

saveDir = '';           % Define your save directory here
stack.pix_sz = 0.367;   % Pixel size in nm

%% Load reconstructed volume

I = read_rec([saveDir 'csdart_reconstructed_volume.rec']);

%% Process volume using CS-DART Reconstruction

cropRadius = 0.9; % Define cropping radius
minArea    = 150; % Minimum area for consideration in particle statistics

[K, It] = processCSDARTRec(I, cropRadius, minArea);

%% Compute statistics for each particle

N = length(K); % Number of detected particles
PartCentroid            = zeros(N, 3);
PartVolume              = zeros(N, 1);
PartSurfaceArea         = zeros(N, 1);
PartSolidity            = zeros(N, 1);
PartPrincipleAxisLength = zeros(N, 3);

for i = 1:N
    stats = regionprops3(K{i}, 'Centroid', 'Volume', 'SurfaceArea', 'Solidity', 'PrincipalAxisLength');
    PartCentroid(i, :)              = stats.Centroid;
    PartVolume(i)                   = stats.Volume;
    PartSurfaceArea(i)              = stats.SurfaceArea;
    PartSolidity(i)                 = stats.Solidity;
    PartPrincipleAxisLength(i, :)   = stats.PrincipalAxisLength;
end

%% Compute global shape properties using alpha shape

shp = alphaShape(PartCentroid(:, 1), PartCentroid(:, 2), PartCentroid(:, 3));

%% Compute shape parameters

ShpAlphaSpectrum = alphaSpectrum(shp);
ShpCriticalAlpha = criticalAlpha(shp, "all-points");
ShpSurfaceArea   = surfaceArea(shp);
ShpVolume        = volume(shp);
ShpRegIndex      = computeRegularityIndex(shp);

%% Save data

strOut = struct();
strOut.centroid         = PartCentroid;
strOut.volume           = PartVolume * stack.pix_sz^3;
strOut.surfaceArea      = PartSurfaceArea * stack.pix_sz^2;
strOut.solidity         = PartSolidity;
strOut.principleAxLength= PartPrincipleAxisLength;
strOut.n_voxels         = size(I);

strOut.shape = struct('object', shp, ...
                      'alphaSpectrum', ShpAlphaSpectrum, ...
                      'criticalAlpha', ShpCriticalAlpha, ...
                      'surfaceArea', ShpSurfaceArea * stack.pix_sz^2, ...
                      'volume', ShpVolume * stack.pix_sz^3, ...
                      'RegularityIndex', ShpRegIndex);

strOut.meanID = mean(pdist(strOut.centroid) * stack.pix_sz);

save([saveDir 'quant_descriptors_NP.mat'], 'strOut');

%% Visualize the alpha shape of the assembly

figure;
plot(shp);
title('Alpha Shape of the Assembly');
pause(0.001);

%% Display the structure output for review

disp(strOut);
disp(strOut.shape);
