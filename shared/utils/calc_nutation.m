% Function: calc_nutation
% Desc: Calculate Earth Nutation based on JD and nutation parameters from
% 'earthNutation' function in Matlab
%
% Input
%   JD: Julian Date Terrestrial Time (TT)
%
% Output
%   N_MATRIX: Nutation Matrix
%

function [N_MATRIX] = calc_nutation(JD)
    
    % Calculate Delta Psi and Epsilon
    nut_angles = earthNutation(JD);
    dpsi = nut_angles(1);
    depsilon = nut_angles(2);

    T = (JD - 2451545.0) ./ 36525.0;

    % Calculate Epsilon and Epsilon Prime

    epsilon = 23.43929111 - sec2deg(arcsec2sec(46.8150)) * T ...
                - sec2deg(arcsec2sec(0.00059)) * T^2 ...
                + sec2deg(arcsec2sec(0.001813)) * T^3;

    % Convert to Radians
    epsilon = deg2rad(epsilon);
    epsilon_prime = epsilon + depsilon;

    % Calculate Nutation Matrix Components
    n11 = cos(dpsi);
    n12 = -cos(epsilon) * sin(dpsi);
    n13 = -sin(epsilon) * sin(dpsi);

    n21 = cos(epsilon_prime) * sin(dpsi);
    n22 = cos(epsilon) * cos(epsilon_prime) * cos(dpsi) ...
                        + sin(epsilon) * sin(epsilon_prime);
    n23 = sin(epsilon) * cos(epsilon_prime) * cos(dpsi) ...
                        - cos(epsilon) * sin(epsilon_prime);

    n31 = sin(epsilon_prime) * sin(dpsi);
    n32 = cos(epsilon) * sin(epsilon_prime) * cos(dpsi) ...
                        - sin(epsilon) * cos(epsilon_prime);
    n33 = sin(epsilon) * sin(epsilon_prime) * cos(dpsi) ...
                        + cos(epsilon) * cos(epsilon_prime);

    N_MATRIX = [n11, n12, n13; n21, n22, n23; n31, n32, n33];
    

end

