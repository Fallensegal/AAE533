% Function: ITRF2J2000
% Desc: ecef2eci calculation, specifically going from ITRF ECEF frame to
% J2000 ECI frame. This takes into account polar motion, precession,
% nutation of the Earth

function [r_J2000] = ITRF2J2000(r_topocentric, JD_UTC, JD_TT, GMST, MJD_MODIFIER)
    

    MJD_UTC = JD_UTC - MJD_MODIFIER;

    precession_matrix = calc_precession(JD_TT);
    nutation_matrix = calc_nutation(JD_TT);
    polar_motion_matrix = calc_polarmotion(MJD_UTC);

    % R3(-GMST) to go to ECI
    theta_matrix = [cos(-GMST), sin(-GMST), 0; ...
                    -sin(-GMST), cos(-GMST), 0; ...
                          0,         0,  1];

    r_J2000 = precession_matrix' * nutation_matrix' * theta_matrix ...
        * polar_motion_matrix' * r_topocentric';
end

