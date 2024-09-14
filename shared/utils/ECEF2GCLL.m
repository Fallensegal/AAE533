% Function: ECEF2GCLL
% Desc: Calculate geocentric latitude and longitude from ECEF coordinates
% to determine observer GC LAT/LONG
% 
% Reference: Jeffrey Pekosh  Purdue University (AAE533 HW1 Solutions Fall
% 2024)
%
% Inputs:
%   R_ECEF: ECEF Position vector of observer [m]
%
% Outputs:
%   GC_LAT: Geocentric Latitude     [deg]
%   GC_LONG: Geocentric Longitude   [deg]

function [GC_LAT, GC_LONG] = ECEF2GCLL(R_ECEF)

    % Components of ECEF Vectors
    X = R_ECEF(:, 1);
    Y = R_ECEF(:, 2);
    Z = R_ECEF(:, 3);

    GC_LAT = 90 - acosd (Z ./ norm(R_ECEF));
    GC_LONG = atan2d(Y, X);

end

