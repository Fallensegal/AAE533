% Function: eci2ecef
% Desc: Generate Station ECEF coordinates from ECI coordinates and LMST
%
% Inputs:
%   RT: ECI Coordinate Vector [X; Y; Z]
%   GMST: Local Mean Sideral Time [rad]
%
% Outputs:
%   R_ECEF: ECEF Coordinate Vector [X; Y; Z]

function R_ECEF = eci2ecef_sidereal(RT, GMST)

    % Define the rotation matrix for rotation about the Z-axis by GMST
    Rz_minus_GMST = [cos(GMST), sin(GMST), 0; ...
                    -sin(GMST), cos(GMST), 0; ...
                          0,         0,  1];
    
    % Apply the inverse rotation to convert ECI to ECEF
    R_ECEF = Rz_minus_GMST * RT;

end
