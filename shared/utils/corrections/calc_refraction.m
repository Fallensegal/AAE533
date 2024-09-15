% Function: calc_refraction
% Desc: Calculate dz in radians that calculates the refraction between true
% and observed elevation
%
% Inputs
%   p: pressure (millibars)
%   T: temp     (Kelvin)
%   RH: Relative Humidity
%   elev: Observed Elevation (deg)
%
% Outputs:
%   delta_z:  Difference in elevation (deg)

function [delta_z] = calc_refraction(p, T, RH, elev)
    
    z_p = deg2rad(90 - elev);

    % Calculate e

    % Empirical Constants
    A = 1.2378847e-5;
    B = -1.9121316e-2;
    C = 33.93711047;
    D = -6.3431645e3;
    e = 0.01 * RH * exp((A * T^2) + (B * T) + C + (D/T));

    delta_z = deg2rad(sec2deg(arcsec2sec(16.271))) * tan(z_p) ...
    * (1 + 0.0000394 * (tan(z_p)^2) * ((p - 0.156 * e) / T)) ...
    * ((p - 0.156 * e) / T) - deg2rad(sec2deg(arcsec2sec(0.0749))) ...
    * ((tan(z_p)^3) + tan(z_p)) * (p / 1000);
    
end

