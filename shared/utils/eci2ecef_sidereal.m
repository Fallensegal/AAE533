% Function: eci2ecef
% Desc: Generate Station ECEF coordinates from ECI coordinates and LMST
%
% Inputs:
%   RT: ECI Coordinate Vector [X; Y; Z]
%   LMST: Local Mean Sideral Time [rad]
%
% Outputs:
%   R_ECEF: ECEF Coordinate Vector [X; Y; Z]

function R_ECEF = eci2ecef_sidereal(RT, LMST)

    % Define the rotation matrix for rotation about the Z-axis by -LMST
    Rz_minus_LMST = [cos(LMST), sin(LMST), 0; ...
                    -sin(LMST), cos(LMST), 0; ...
                          0,         0,  1];
    
    % Apply the inverse rotation to convert ECI to ECEF
    R_ECEF = Rz_minus_LMST * RT;

end
