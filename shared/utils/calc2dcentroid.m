% calculateCentroid computes the centroid of an object in a grayscale image
%
% Inputs:
%   img         - 2D image matrix
%   upper_thrs  - Upper intensity limit of pixel
%   lower_thrs  - Lower intensity limit of pixel
%
% Outputs:
%   centroid_x - x-coordinate of the centroid
%   centroid_y - y-coordinate of the centroid
function [centroid_x, centroid_y] = calc2dcentroid(img, upper_thrsh, lower_thrsh)
    
    % Apply Intensity Threshold
    binary_mask = (img > lower_thrsh) & (img < upper_thrsh);

    % Compute Total Intensity
    [rows, cols] = find(binary_mask);
    intensities = double(img(binary_mask));
    total_int = sum(intensities);

    % Avoid division by zero
    if total_int == 0
        centroid_x = NaN;
        centroid_y = NaN;
        warning('Total intensity is zero. Centroid is undefined.');
        return;
    end

    w_sum_x = sum(cols .* intensities);
    w_sum_y = sum(rows .* intensities);

    centroid_x = w_sum_x / total_int;
    centroid_y = w_sum_y / total_int;
end
