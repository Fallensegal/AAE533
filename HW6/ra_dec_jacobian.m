% ra_dec_jacobian.m
% Function: ra_dec_jacobian
% Desc: Computes the Jacobian matrix of RA and Dec with respect to the state vector
%
% Inputs:
%   x: State vector [6x1] in ECI frame [m; m/s]
%
% Outputs:
%   H: Jacobian matrix [2x6] [degrees/m]

function H = ra_dec_jacobian(x)
    % Extract position components
    r = x(1:3); % [m]
    rx = r(1);
    ry = r(2);
    rz = r(3);
    r_norm = norm(r);
    rxy2 = rx^2 + ry^2;
    rxy = sqrt(rxy2);
    
    % Avoid division by zero
    if rxy2 < 1e-6
        error('rxy2 is too small, leading to numerical instability in Jacobian computation.');
    end
    
    % Partial derivatives of RA with respect to position (in radians/m)
    dRA_dr_rad = [ -ry / rxy2, rx / rxy2, 0 ];
    
    % Partial derivatives of Dec with respect to position (in radians/m)
    dDec_dr_rad = [ (rz * rx) / (r_norm^2 * rxy), ...
                   (rz * ry) / (r_norm^2 * rxy), ...
                   rxy / r_norm^2 ];
               
    % Convert radians/m to degrees/m
    dRA_dr_deg = dRA_dr_rad * (180/pi);
    dDec_dr_deg = dDec_dr_rad * (180/pi);
    
    % Assemble Jacobian Matrix
    H = [dRA_dr_deg, zeros(1,3);
         dDec_dr_deg, zeros(1,3)];
end
