% Little Routine to read in a fits file, crop to the object, display%%
%
% Author: Nathan Houtz
% date: 2021-09-18
% dependencies: 
% 00095337_labeled_stars.png for display
% 00095337.fit fits image
%
%

format shortg
format compact
close all
clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants

MU_E = 398600.4418; %[km3 s-2], gravitational parameter
R_E = 6378.137; %[km] mean earth radius
omega_E = [0;0;7.2921150e-5]; %[rad s-1] rotation rate of Earth

% Telescope information:
lat = 32.903342; %[deg] site latitude
lon = -105.529344; %[deg] site longitude
alt = 2.225; %[km] site altitude above sea level

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a FITS image

fname = '00095337.fits';
fInfo = fitsinfo(fname);
img = fitsread(fname);

% Crop the image to show just the object:
img_cropped = img(1980:2030,1720:1780);

% Load the labeled image
img_labeled = imread('00095337_labeled_stars.png');
img_labeled = img_labeled(102:863,605:1363,:);

% Get rid of "hot" pixels (cosmic rays, disfunctional pixels)
max_acceptable_value = 1300;
img(img>max_acceptable_value) = max_acceptable_value;


% Plot the images
f1 = figure();
tgroup1 = uitabgroup('Parent',f1);
tab(1) = uitab('Parent', tgroup1, 'Title', 'Raw image');
ax(1) = axes('parent',tab(1));
imagesc(img)
axis equal
axis([0,size(img,2),0,size(img,1)]+0.5)
colormap(gray(256));
xlabel('x [px]')
ylabel('y [px]')
title('Raw image of 29486')

tab(2) = uitab('Parent', tgroup1, 'Title', 'cropped image');
ax(2) = axes('parent',tab(2));
imagesc(img_cropped)
axis equal
axis([0,size(img_cropped,2),0,size(img_cropped,1)]+0.5)
colormap(gray(256));
xlabel('x [px]')
ylabel('y [px]')
title('Cropped image of 29486')

tab(3) = uitab('Parent', tgroup1, 'Title', 'Matched Stars');
ax(3) = axes('parent',tab(3));
imagesc(img_labeled);
axis equal
axis([0,size(img_labeled,2),0,size(img_labeled,1)]+0.5)
xlabel('x [px]')
ylabel('y [px]')
title('Background stars matched and labeled')





