% Function: verify_az_elev
% Desc: From Azimuth and Elevation calculate TCLM XYZ coordinates and
% compare them with tclm coordinates calculated from topocentric equatorial
% parameters
%
% Inputs:
%  tclm_coords: Cell matrix of TCLM coords from equatorial parameters
%  sample_length: number of data samples
%  az_calc: TCLM azimuth [deg]
%  elev_calc: TCLM elevation [deg]
function verify_az_elev(tclm_coords, az_calc, elev_calc, sample_length)

    % Convert degrees to radians
    az_rad = deg2rad(180-az_calc);     % Need to account for right-handedness
    elev_rad = deg2rad(elev_calc);
    
    
    % Equation Script 37 Left-Hand Side
    eq1_lhs = cos(elev_rad) .* cos(az_rad);
    eq2_lhs = cos(elev_rad) .* sin(az_rad);
    eq3_lhs = sin(elev_rad);

    reconstructed_tclm = [eq1_lhs, eq2_lhs, eq3_lhs];

    tol = 1e-10;        % Setting Reconstruction Error
    for sample_index = 1:sample_length
        diff = reconstructed_tclm(sample_index, :) - tclm_coords{sample_index}';
        disp(['Unit Vector Reconstruction Error: ', num2str(norm(diff))]);
        if diff < tol
            disp('Verification PASSED: Azimuth and Elevation are correct within tolerance.');
        else
             disp('Verification FAILED: Azimuth and Elevation do not satisfy the equations.');
        end
    end
