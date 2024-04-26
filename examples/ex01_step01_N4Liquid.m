%% ex01_step01_N4Liquid.m
% CS-DART Reconstruction on N=4 colloidal assembly acquired in HAADF-STEM
% mode with liquid-cell holder. Note that the dataset must be pre-processed. 
%
% This script processes tilt series for 3D reconstruction using both EM
% and DART methods, visualizes results, and saves the outputs.
%
% Author:
%   Ajinkya Kadu
%   EMAT, May 20, 2023

%% Clean up the workspace and close all figures

clc; clearvars; close all;

%% Load data
% Define the directory where preprocessed data is stored

saveDir = ['']; 
load([saveDir 'dataset.mat'], 'stack');

% Prepare the tilt series by converting data type and rescaling
stack.data = rescale(im2single(stack.data));

%% Compute and store EM reconstruction

I_em = rec_em(stack, 30);
I_em = rescale(I_em);

write_rec(I_em, [saveDir 'em_reconstructed_volume.rec']);

%% Visualize the histogram of EM reconstruction

figure;
imhist(I_em);
title('Histogram of EM Reconstruction');
ylim([0 1000]);

%% Perform CS-DART reconstruction

css_opt = struct('nDCT', [10 10 10], ... % Smoothing coefficients
                 'innerIt', 40, ...      % Number of inner iterations
                 'kappa', 0.01, ...      % Regularization parameter
                 'kappaUp', 0.8);        % Kappa update factor
                 
maxIter = 50;       % Maximum number of iterations
numMat = 2;         % Number of materials

uval = [0.2 0.9];   % Intensity values for materials

[I, uval, I_EM] = rec_csdart(stack, maxIter, numMat, css_opt, uval);

% Save CS-DART reconstruction results
write_rec(I, [saveDir 'csdart_reconstructed_volume.rec']);


