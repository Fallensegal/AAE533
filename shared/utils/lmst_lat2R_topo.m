% Function: lmst_lat2R_topo
% Desc: Generate Station ECI coordinates from geocentric latitude, LMST,
% and magnitude of distance from center of earth to topocenter
% 
% Inputs:
%   R: magnitude of distance from center of earth to topocenter [km]
%   GEOC_LAT: Geocentric Latitude [deg]
%   LMST: Local Mean Sideral Time [rad]
%
% Outputs:
%   RT: ECI Coordinate Vector [X; Y; Z]


function RT = lmst_lat2R_topo(R, GEOC_LAT, LMST)

    RT = [R .* cos(deg2rad(GEOC_LAT)) .* cos(LMST); ...
        R .* cos(deg2rad(GEOC_LAT)) .* sin(LMST); ...
        R .* sin(deg2rad(GEOC_LAT))];

end