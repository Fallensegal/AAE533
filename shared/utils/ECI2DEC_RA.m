% Function: ECI2DEC_RA
% Desc: Calculate right ascension and declination given ECI coordinates of
% the station and the orbiting object
%
% Inputs:
%   sat_eci: Satellite coordinates in the ECI frame
%   stat_eci: Station coordinates in the ECI frame
%
% Outputs:
%   ra: Topocentric Right Ascension [deg]
%   dec: Topocentric Declination [deg]

function [ra, dec] = ECI2DEC_RA(sat_eci, stat_eci)

    dist_array = sat_eci - stat_eci;
    range = norm(dist_array);       
    l_hat = dist_array ./ range;        

    % Calculate Topocentric Declination and RA (Right Ascension) [deg]
    dec = asind(l_hat(3));
    ra = atan2d(l_hat(2), l_hat(1)); 
    
end

