%% ex01_step01_N4Liquid.m
% CS-DART Reconstruction on N=4 colloidal assembly acquired in HAADF-STEM
% mode with liquid-cell holder. Note that the dataset must be pre-processed. 
%
% This script processes tilt series for 3D reconstruction using both EM
% and CS-DART methods, visualizes results, and saves the outputs in the
% corresponding data directory.
%
% Author:
%   Ajinkya Kadu
%   EMAT, May 20, 2023

%% Clean up the workspace and close all figures

clc;
clearvars;
close all;

%% Define Directories
% The 'home_folder' is one level up from the examples folder.

homeDir = '../';
dataDir = fullfile(homeDir, 'data/N4/');  % Path to the data directory

%% Load data
% Load the preprocessed dataset from the specified directory
% The 'dataset.mat' file should contain a variable 'stack' with the tilt series data.


load([dataDir 'N4_liquid_sample_stack.mat'], 'stack');

% Convert to single precision for computational efficiency and normalize intensities.
stack.data = rescale(im2single(stack.data));

%% Compute and store EM reconstruction
% Reconstruct the 3D volume using the Expectation Maximization (EM) algorithm.
% Parameter selection:
%   - numIter: Number of iterations for reconstruction, typically 10-100.

numIter = 30;
I_em = rec_em(stack, numIter);
I_em = rescale(I_em);

% Save the EM reconstruction result in the same data directory
emOutputPath = fullfile(dataDir, 'em_reconstructed_volume.rec');
write_rec(I_em, emOutputPath);

%% Visualize the histogram of EM reconstruction
% Adjust the histogram display according to intensity levels
% This helps in understanding the data distribution and in setting thresholds.

figure;
imhist(I_em);
title('Histogram of EM Reconstruction');
ylim([0 1000]); % Adjust this based on your data's intensity distribution

%% Perform CS-DART reconstruction
% CS-DART combines compressed sensing and discrete tomography for reconstruction.
% Parameter selection for CS-DART:
%   css_opt:
%     - nDCT: Number of DCT coefficients, adjust based on object complexity
%     and noise, typically [5 5 5] to [30 30 30]. Less number of DCT
%     coefficients will give a very smooth reconstruction while increasing
%     DCT coefficients will start adding details to surface. 
%     - innerIt: Number of inner iterations, typically 20-50.
%     - kappa: Regularization parameter, usually in the range 0.01-0.1.


css_opt = struct('nDCT', [10 10 10], ... % Smoothing coefficients
                 'innerIt', 40, ...      % Number of inner iterations
                 'kappa', 0.01);         % Regularization parameter
                 
maxIter = 50;       % Maximum number of iterations, typically 30-100
numMat  = 2;        % Number of materials to segment, adjust as necessary

uval = [0.1 0.6];   % Intensity values for materials, set based on histogram

[I, uval, I_EM] = rec_csdart(stack, maxIter, numMat, css_opt, uval);

% Save CS-DART reconstruction results in the same data directory
csdartOutputPath = fullfile(dataDir, 'csdart_reconstructed_volume.rec');
write_rec(I, csdartOutputPath);

%%% Conclusion
% The script has completed processing. The reconstructed volumes are saved
% in the respective directory, and the histogram provides insight into the intensity
% distribution of the EM reconstruction for further analysis and parameter adjustment.
disp('Reconstruction and saving completed.');

