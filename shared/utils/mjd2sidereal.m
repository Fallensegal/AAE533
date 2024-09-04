% Function: mjd2sidereal
% Desc: Transform modified Julian Date to Local Mean Sidereal Time
% and Greenwich Mean Sidereal Time (LMST, GMST)
% Inputs:
%   MJD: Modified Julian Date, days counting from specific reference 
%       [Days + day fraction since noon]
%
%   logitude: Longitude of observation point
%
% Outputs:
%   [GMST, LMST]: Greenwich and Local Mean Sidereal Time [rad]

function [GMST, LMST] = mjd2sidereal(MJD, longitude)
    JD = MJD + 2400000.5;
    JD0 = floor(JD) - 0.5;

    T0 = (JD0 - 2451545.0)/36525.0;
    T1 = (JD - 2451545.0)/36525.0;
    UT = (JD - JD0) * 86400;

    theta0 = 24110.54841 + (8640184.812866 * T0) + (0.093104 * (T1^2)) ... 
                                                 - (6.2e-6 * (T1^3)) ...
                                                 + (1.0027279093 * UT);
                                                 % Greenwich Mean Sidereal
                                                 % Time [sec]

    % Convert from seconds to radians
    theta0 = (theta0/43200) * pi;
    
    % Remove Radian cycles with modulo
    GMST = mod(theta0, 2*pi);

    % Define local sidereal time
    LMST = GMST + deg2rad(longitude);

end