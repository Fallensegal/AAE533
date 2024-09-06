% Function: verify_topo_coordinates
% Desc: Given topocentric declination and right ascension, reverse solve
% for r_topo (distance between sat and station) and calculate the error.
%
% Inputs:
%   sat_eci: cell matrix of eci XYZ coords of satellite/object      [km]
%   stat_eci: cell matrix of eci XYZ coords of station/observer     [km]
%   topo_dec: Topocentric declination of object                     [deg]
%   topo_ra: Topocentric right ascension of object                  [deg]
%
% Outputs:
%   r_topo_error: magnitude of error between reverse calculate r_topo, and
%   quantity derived r_topo

function [r_topo_error] = verify_topo_coordinates(sat_eci, stat_eci, topo_dec, topo_ra)
    % Initialize error storage
    max_error = 0;
    total_error = 0;
    r_topo_error = zeros(length(topo_dec), 1);

    for i = 1:length(sat_eci)
        % Original vector
        original_vec = sat_eci{i} - stat_eci{i};
        original_range = norm(original_vec);

        % Reconstruct vector from declination and RA
        dec_rad = deg2rad(topo_dec(i));
        ra_rad = deg2rad(topo_ra(i));
        reconstructed_vec = original_range * [
            cos(dec_rad) * cos(ra_rad);
            cos(dec_rad) * sin(ra_rad);
            sin(dec_rad)
        ];

        % Calculate error
        error_vec = original_vec - reconstructed_vec;
        error_magnitude = norm(error_vec);
        
        % Update max and total error
        max_error = max(max_error, error_magnitude);
        total_error = total_error + error_magnitude;

        % Print individual errors if they're significant
        if error_magnitude > 1e2
            fprintf('Significant error at index %d: %.6f km\n', i, error_magnitude);
        end

        r_topo_error(i) = error_magnitude;
    end

    % Print summary
    fprintf('Maximum error: %.6f km\n', max_error);
    fprintf('Average error: %.6f km\n', total_error / length(sat_eci));
end