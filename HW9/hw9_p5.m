% AAE 533 Homework 9
% Author: Wasif Islam
% Date: November 14th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));
load("constants.mat");

%% Problem Five
[ASTRA_INIT, epoch_time] = read_3le('ASTRA_TLE.txt');
epoch_time = epoch_time{1};
TT_ADJUST = seconds(64.184);
epoch_TT = epoch_time + TT_ADJUST;
JD_TT = juliandate(epoch_TT);

% Manual Input from TLE (angles in deg)
ASTRA.inc = 0.0757;
ASTRA.RAAN = 318.8725;
ASTRA.ecc = .0003036;
ASTRA.argp = 265.9036;
ASTRA.TA = 26.8254;
ASTRA.MM = 1.00273517;

motion_rads = ASTRA.MM * 2 * pi / 86400;
ASTRA.sma = (MU_EARTH / (motion_rads^2)) ^(1/3);

% Initial State TEME
ASTRA_TEME = kepler_to_eci_cartesian(ASTRA.sma, ASTRA.inc, ASTRA.RAAN, ASTRA.TA, ...
                                    ASTRA.argp, ASTRA.ecc, MU_EARTH);

precession_matrix = calc_precession(JD_TT);
nutation_matrix = calc_nutation(JD_TT);
ASTRA_J2000 = precession_matrix' * nutation_matrix' * ASTRA_TEME(1:3);
date_time_array = [year(epoch_time), month(epoch_time), day(epoch_time), ...
    hour(epoch_time), minute(epoch_time), second(epoch_time)];
LLA = eci2lla(ASTRA_J2000', date_time_array);
Lat = LLA(1);
Long = LLA(2);
Alt = LLA(3);
format_str = sprintf("Station Geodedic Coordinates [deg] - Latitude: %.4f, Longitude: %.4f", Lat, Long);
disp(format_str)

%% Create CCD Image

% Parameters
pixel_scale = 1;          % arcsec per pixel
image_size = 30;          % 30x30 pixel grid
fwhm_total = 2.0;         % arcsec (combined FWHM from diffraction and seeing)
sigma = fwhm_total / (2 * sqrt(2 * log(2)));

% Meshgrid Creation
half_size = image_size / 2;
x = (-half_size + 0.5 : half_size - 0.5) * pixel_scale;
y = (-half_size + 0.5 : half_size - 0.5) * pixel_scale;
[X, Y] = meshgrid(x, y);

% Making sure the high intensity image is not perfectly centered
offset_x = (rand - 0.5) * pixel_scale;
offset_y = (rand - 0.5) * pixel_scale;

% Generate CCD Image
X_offset = X + offset_x;
Y_offset = Y + offset_y;
psf = exp(-((X_offset).^2 + (Y_offset).^2) / (2 * sigma^2));
psf = psf / sum(psf(:));

figure;
imagesc(x, y, psf);        % Pass x and y as vectors for proper axis scaling
axis xy;                    % Correct the y-axis direction
axis image;                % Equal scaling for both axes
colormap(gray);            % Grayscale colormap for better visualization
colorbar;                  % Display color scale
title('Noiseless CCD Image of Astra 2E Satellite (30x30 Pixels)');
xlabel('Arcseconds');
ylabel('Arcseconds');

%% Create Noisy CCD Image

SNR_values = [100, 10, 2];
noisy_images = struct();

for i = 1:length(SNR_values)
    current_SNR = SNR_values(i);
    
    % Calculate the total photon counts based on desired SNR
    % SNR = sqrt(N) => N = SNR^2
    N_total = current_SNR^2;
    
    % Scale the noiseless PSF to have total counts N_total
    psf_scaled = psf * N_total;
    
    % Generate Gaussian noise based on the scaled PSF
    sigma_noise = current_SNR / image_size;
    noise = sigma_noise * randn(image_size, image_size);

    % Add Gaussian Noise to clean image
    psf_noisy = psf_scaled + noise;
    
    % Store the noisy image in the structure
    noisy_images(i).SNR = current_SNR;
    noisy_images(i).image = psf_noisy;
    
    % Display the Noisy CCD Images
    figure('Name', ['Noisy CCD Image - SNR = ' num2str(current_SNR)], 'NumberTitle', 'off');
    imagesc(x, y, psf_noisy);          % Pass x and y as vectors for proper axis scaling
    axis xy;                            % Correct the y-axis direction
    axis image;                         % Equal scaling for both axes
    colormap(gray);                     % Grayscale colormap for better visualization
    colorbar;                           % Display color scale
    title(['Noisy CCD Image of Astra 2E Satellite (SNR = ' num2str(current_SNR) ')']);
    xlabel('Arcseconds');
    ylabel('Arcseconds');
    
    % Display the PSF as a 3D Mesh
    figure('Name', ['PSF Surface - SNR = ' num2str(current_SNR)], 'NumberTitle', 'off');
    mesh(X, Y, psf_noisy);
    title(['PSF Surface (SNR = ' num2str(current_SNR) ')']);
    xlabel('Arcseconds');
    ylabel('Arcseconds');
    zlabel('Photon Counts');
end