% Function: tclm2ah
% Desc: From topocentric local meridian X,Y,Z coordinates, calculate
% azimuth and elevation
% Inputs:
%   tclm_coords: cell matrix of topocentric equitorial X, Y, Z coords
%   sample_size: Number of samples in data set
%
% Outputs:
%   [az, elevation]: arrays of azimuth and elevation values [deg]

function [az, elevation] = tclm2ah(tclm_coords, sample_size)

% Pre-allocate Output Arrays
elevation = zeros(sample_size, 1);
az = zeros(sample_size, 1);

for sample_index = 1:sample_size
    X = tclm_coords{sample_index}(1);
    Y = tclm_coords{sample_index}(2);
    Z = tclm_coords{sample_index}(3);

    % Calculate Azimuth and Elevation
    elevation(sample_index) = rad2deg(asin(Z));
    az(sample_index) = 180 - atan2d(Y, X);
end


end