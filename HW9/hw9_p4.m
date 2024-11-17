% AAE 533 Homework 9
% Author: Wasif Islam
% Date: November 14th, 2024

%% Problem 4

% Make sure you run `ImageScript.m` first before running this script

% Binary Logical Mask
[total_rows, total_cols] = size(img);
cropped_mask = false(total_rows, total_cols);
cropped_rows = 1980:2030;
cropped_cols = 1720:1780;
cropped_mask(cropped_rows, cropped_cols) = true;

cropped_out_mask = ~cropped_mask;
cropped_out_img = img(cropped_out_mask);

% Compute statistical measures
background_mean = mean(cropped_out_img);
background_median = median(cropped_out_img);
background_std = std(double(cropped_out_img));

% Define Threshold
thrsh = background_mean + (3 * background_std);

high_i_mask = false(total_rows, total_cols);
high_i_mask(cropped_mask) = img(cropped_mask) > thrsh;

% Final Mask
final_mask = cropped_out_mask & ~high_i_mask;
final_img = img(final_mask);

final_mean = mean(final_img);
final_std = std(double(final_img));
final_median = median(final_img);

% Plot histogram of background pixels
figure(1);
histogram(final_img, 75);
xlabel('Pixel Intensity');
ylabel('Frequency');
title('Histogram of Background Pixel Intensities');
grid on;

% Overlay mean and median
hold on;
xline(background_mean, 'r', 'LineWidth', 2, 'Label', 'Mean');
xline(background_median, 'g', 'LineWidth', 2, 'Label', 'Median');
hold off;

% Display the high illumination mask
figure;
imagesc(high_i_mask(cropped_rows, cropped_cols));
colormap(gray);
colorbar;
title('High Illumination Areas (Objects) in Cropped-Out Region');
xlabel('x [px]');
ylabel('y [px]');

% Calculate Centroid
[x,y] = calc2dcentroid(img, 1800, 800);