% Function: tce2tclm
% Desc: Convert topocentric equitorial elements to calculate
% topocentric local meridian frame coordinates using equation 2.37 in
% script
%
% Inputs:
%   geod_lat: Geodedic Latitude [deg]
%   topo_dec: Topocentric Equitorial declination [deg]
%   hour_angle: Hour angle of LMST and topocentric equitorial RA [rad]
%
% Outputs:
%   tclm_coord: Cell matrix of XYZ coords of topocentric local meridian
%   frame
function [tclm_coord] = tce2tclm(geod_lat, topo_dec, hour_angle)

    % Change degree measures to rad
    geod_lat = deg2rad(geod_lat);
    topo_dec = deg2rad(topo_dec);

    % Calculate Components
    tclm_coordX = sin(geod_lat) .* cos(topo_dec) .* cos(hour_angle) ...
                                - cos(geod_lat) .* sin(topo_dec);

    tclm_coordY = cos(topo_dec) .* sin(hour_angle);
    tclm_coordZ = sin(geod_lat) .* sin(topo_dec) + cos(geod_lat) ...
                                .* cos(topo_dec) .* cos(hour_angle);

    % Create cell matrix of arrays and populate
    tclm_coord = cell(length(hour_angle), 1);
    for sample_index = 1:length(hour_angle)
        tclm_coord{sample_index} = [tclm_coordX(sample_index);
                                    tclm_coordY(sample_index);
                                    tclm_coordZ(sample_index)];
    end
end
