function [] = plotOrthoSlices(I, J)
%PLOTORTHOSLICES Display orthogonal slices and summed projections of 3D images.
%   PLOTORTHOSLICES(I, J) displays orthogonal slices and summed projections
%   for two 3D images I and J. The function adjusts the contrast of the images
%   and shows XY, XZ, YZ slices, and their sums for each image.
%
% Inputs:
%   I : First input 3D image.
%   J : Second input 3D image (comparison image).
%
% Example:
%   I = rand(100,100,100); % Random 3D image
%   J = rand(100,100,100); % Another random 3D image
%   plotOrthoSlices(I, J); % Visualize the slices and projections
%
% Author:
%   Ajinkya Kadu
%   EMAT, University of Antwerp
% 
% May 20, 2023

% Adjust the contrast of the images for better visualization
I = imadjustn(I, [], [], 0.5);
J = imadjustn(J, [], [], 0.5);

% Create a figure window with a specific figure number
figure(99); clf; % Clear the figure to avoid superposition of plots

% Plot the middle slices from the second image (J)
subplot(3,3,1); imshow(J(:,:,floor(end/2)), []); title('J-XY');
subplot(3,3,2); imshow(squeeze(J(:,floor(end/2),:)), []); title('J-XZ');
subplot(3,3,3); imshow(squeeze(J(floor(end/2),:,:)), []); title('J-YZ');

% Plot the middle slices from the first image (I)
subplot(3,3,4); imshow(I(:,:,floor(end/2)), []); title('I-XY');
subplot(3,3,5); imshow(squeeze(I(:,floor(end/2),:)), []); title('I-XZ');
subplot(3,3,6); imshow(squeeze(I(floor(end/2),:,:)), []); title('I-YZ');

% Plot the summed projections of the first image (I)
subplot(3,3,7); imshow(sum(I, 3), []); title('I-XY Sum');
subplot(3,3,8); imshow(squeeze(sum(I, 2)), []); title('I-XZ Sum');
subplot(3,3,9); imshow(squeeze(sum(I, 1)), []); title('I-YZ Sum');

% Include a brief pause to ensure the figures update properly
pause(0.001);

end
