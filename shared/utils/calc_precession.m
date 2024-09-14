% Function: calc_precession
% Desc: Calculate precession of earth given JD. Precession is calculated in
% Terrestial Time (TT)
%
% Input:
%   JD: Julian Date of Observation
%
% Output:
%   P_MATRIX: Precession Rotation Matrix

function [P_MATRIX] = calc_precession(JD)
    
    T = (JD - 2451545.0) ./ 36525.0;

    % Calculate Precession Parameters (zeta, theta, z)
    zeta = 2306.218100 .* T + 0.3018800 .* T.^2 + 0.01799800 .* T.^3;
    theta = 2004.310900 .* T - 0.4266500 .* T.^2 - 0.04183300 .* T.^3;
    z = zeta + 0.7928000 .* T.^2 + 0.00020500 .* T.^3;

    % Convert Parameters from Arcsec to Rad
    zeta = arcsec2sec(zeta);
    zeta = sec2deg(zeta);
    zeta = deg2rad(zeta);

    theta = arcsec2sec(theta);
    theta = sec2deg(theta);
    theta = deg2rad(theta);

    z = arcsec2sec(z);
    z = sec2deg(z);
    z = deg2rad(z);
    
    % Matrix Column 1
    p11 = -sin(z) * sin(zeta) + cos(z) * cos(theta) * cos(zeta);
    p21 = cos(z) * sin(zeta) + sin(z) * cos(theta) * cos(zeta);
    p31 = sin(theta) * cos(zeta);

    % Matrix Column 2
    p12 = -sin(z) * cos(zeta) - cos(z) * cos(theta) * sin(zeta);
    p22 = cos(z) * cos(zeta) - sin(z) * cos(theta) * sin(zeta);
    p32 = -sin(theta) * sin(zeta);

    % Matrix Column 3
    p13 = -cos(z) * sin(theta);
    p23 = -sin(z) * sin(theta);
    p33 = cos(theta);
    
    P_MATRIX = [p11, p12, p13; p21, p22, p23; p31, p32, p33];
    
end

