% Function: EarthGravField_A
% Description: Calculate satellite acceleration due to Earth Gravitational
% Field in the ECI frame. This implementation only consider the second
% order zonal perturbations or J2
%
% Inputs:
% sat_eci:      Satellite Position in ECI Frame [meters]
%               (use column vectors as the input)
% date_time:    The UTC datetime object required to convert from ECI to
%               ECEF

function [a_earth_grav_eci] = EarthGravField_A(sat_eci, date_time, mu)
    
    J2 = -4.8416983732E-04; % J2 coefficient [Zonal]
    Re = 6378e3;    
    
    % Convert from ECI frame to ECEF
    sat_ecef = eci2ecef(date_time, sat_eci);

    % Normalized Components
    r = norm(sat_ecef);
    u_ecef = sat_ecef ./ r;

    % Normalized XYZ
    s = sat_ecef(1) / r;
    t = sat_ecef(2) / r;
    u = sat_ecef(3) / r;

    u_j2 = (3/2) .* [(5 * s * (u^2)) - s; ...
                     (5 * t * (u^2)) - t; ...
                     (5 * (u^3) - (3*u))];

    % Acceleration Components
    a1 = (-mu / (r^2)) .* u_ecef;
    a2 = (((mu * J2) / (r^2)) * ((Re / r)^2)) .*  u_j2;

    a_total = a1 + a2;

    a_earth_grav_eci = ecef2eci(date_time, a_total);


end

