% Function: GDLL2ECEF
% Descrption: Calculate topocentric position vector of observer in ECEF
% frame (assume ITRF)
%
% Reference: Jeffrey Pekosh  Purdue University (AAE533 HW1 Solutions Fall
% 2024)
%
% Inputs:
%   GD_LAT: Geodedic Latitude       [deg]
%   GD_LONG: Geodedic Longitude     [deg]
%   alt: Altitude of Observer       [m]
%
% Outputs:
%   R_ECEF: X, Y, Z Coordinates in ECEF Frame
%   

function [R_ECEF] = GDLL2ECEF(GD_LAT, GD_LONG, alt)

    distance_to_surface = 6378.137e3;        % Distance to surface of earth [m]
    f = 1 ./ 298.257223563;                  % Melony factor of earth

    % Eccentricty of Earth
    e = sqrt(2 .* f - f.^2);

    % Geodedic Radius
    N = distance_to_surface ./ sqrt (1 - e .^2 .* sind( GD_LAT ).^2);

    % Calculate Observer Position Vector (ECEF)
    R_ECEF = [(N + alt) .* cosd( GD_LAT ) .* cosd( GD_LONG )...
    (N + alt) .* cosd( GD_LAT ) .* sind( GD_LONG )...
    (N .*(1 - e.^2) + alt) .* sind( GD_LAT )];

    
end

