% Function: J20002ITRF
% Desc: Transform from J2000 reference frame to ITRF ECEF Reference Frame

function [R_ITRF] = J20002ITRF(R_J2000, GMST, JD_UTC, JD_TT, MJD_MOD)
    MJD_UTC = JD_UTC - MJD_MOD;
    precession_matrix = calc_precession(JD_TT);
    nutation_matrix = calc_nutation(JD_TT);
    polar_motion_matrix = calc_polarmotion(MJD_UTC);
    
    % R3(GMST) to go to ECI
    theta_matrix = [cos(GMST), sin(GMST), 0; ...
                    -sin(GMST), cos(GMST), 0; ...
                          0,         0,  1];

    R_ITRF = polar_motion_matrix * theta_matrix * nutation_matrix * precession_matrix * R_J2000;

end

