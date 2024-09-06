% AAE 533 Homework 1
% Author: Wasif Islam
% Date: Aug 31st, 2024

%% Initialization
tic;
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");
coordinate_data = readtable("new_validation_data.xlsx");

% Put Data into new Struct with smaller name
station_data.MJD = coordinate_data.Time_MJD_;
station_data.GEOD_LAT = coordinate_data.StationGeodeticLatitude_deg_;
station_data.GEOD_LONG = coordinate_data.StationGeodeticLongitude_deg_;
station_data.GEOC_LAT = coordinate_data.StationGeocentricLatitude_deg_;
station_data.GEOC_LONG = coordinate_data.StationGeocentricLongitude_deg_;
station_data.StationX_ECI = coordinate_data.StationXECI_Km_;
station_data.StationY_ECI = coordinate_data.StationYECI_Km_;
station_data.StationZ_ECI = coordinate_data.StationZECI_Km_;
station_data.StationX_ECEF = coordinate_data.StationXECEF_Km_;
station_data.StationY_ECEF = coordinate_data.StationYECEF_Km_;
station_data.StationZ_ECEF = coordinate_data.StationZECEF_Km_;
station_data.StationR_ECEF = norm([station_data.StationX_ECEF(1), ...
                                   station_data.StationY_ECEF(1), ...
                                   station_data.StationZ_ECEF(1)]);

station_data.SATX_ECI = coordinate_data.SatelliteXECI_Km_;
station_data.SATY_ECI = coordinate_data.SatelliteYECI_Km_;
station_data.SATZ_ECI = coordinate_data.SatelliteZECI_Km_;
station_data.SAT_RANGE = coordinate_data.SatelliteRange_Km_;

% Define Cell Arrays for ECI XYZ Coords for Station and Satellite
sat_eci = cell(length(station_data.StationX_ECEF), 1);
stat_eci = cell(length(station_data.StationX_ECEF), 1);

for sample_length = 1:length(station_data.StationX_ECEF)
    sat_XYZ = [station_data.SATX_ECI(sample_length); station_data.SATY_ECI(sample_length); ... 
                station_data.SATZ_ECI(sample_length)];

    stat_XYZ = [station_data.StationX_ECI(sample_length); station_data.StationY_ECI(sample_length); ...
                station_data.StationZ_ECI(sample_length)];
    
    sat_eci{sample_length} = sat_XYZ;
    stat_eci{sample_length} = stat_XYZ;
end

%% Problem 2a

% Calculate Local and Greenwich Mean Sidereal Time
[GMST, LMST] = mjd2sidereal(station_data.MJD, station_data.GEOC_LONG);

% Acquire ECEF R magnitude (technically should be the same for ECI)
R = station_data.StationR_ECEF;

stat_eci_calc = cell(length(LMST), 1);     % Pre-allocating Matrix Array
stat_eci_error = zeros(length(LMST), 1);   % Pre-allocating error term array

for matrix_index = 1:length(LMST)

    % Acquire ECI Coordinates for Station
    RT = [R .* cos(deg2rad(station_data.GEOC_LAT(matrix_index))) .* cos(LMST(matrix_index)); ...
          R .* cos(deg2rad(station_data.GEOC_LAT(matrix_index))) * sin(LMST(matrix_index)); ...
          R .* sin(deg2rad(station_data.GEOC_LAT(matrix_index)))];

    stat_eci_calc{matrix_index} = RT;       % R_topo

    % Calculate error between derived and actual
    stat_eci_error(matrix_index) = norm(RT - stat_eci{matrix_index});

end

% Calculate Range
sat_range_calc = zeros(length(LMST), 1);
r_topo = cell(length(LMST), 1);               % eq. 2.28 in the script
topo_dec = zeros(length(LMST), 1);
topo_ra = zeros(length(LMST), 1);
for sample_index = 1:length(LMST)
    dist_array = sat_eci{sample_index} - stat_eci_calc{sample_index};
    range = norm(dist_array);       
    l_hat = dist_array ./ range;        
    sat_range_calc(sample_index) = range;

    % Calculate Topocentric Declination and RA (Right Ascension) [deg]
    topo_dec(sample_index) = asind(l_hat(3));
    topo_ra(sample_index) = atan2d(l_hat(2), l_hat(1)); 
    r_topo{sample_index} = dist_array;
end

% Calculate Error for Range
sat_range_error = sat_range_calc - station_data.SAT_RANGE;

% Reverse calculate r_topo and r, then calculate error
[dec_ra_error_mag] = verify_topo_coordinates(sat_eci, stat_eci, topo_dec, topo_ra);

% Use Equation 2.37 to solve for azimuth and elevation
hour_angle = LMST - deg2rad(topo_ra);           % Calculate hour angle [rad]

% Topocentric Local Meridian X, Y, Z frame
tclm_sat = tce2tclm(station_data.GEOD_LAT, topo_dec, hour_angle);

% Calculate Azimuth and Elevation
[az_calc, elev_calc] = tclm2ah(tclm_sat, length(LMST));

% Calculate Error between Calculated Az, Elev and Reference

% Generate Error Graphs

%% Problem 2b

%% Problem 2d


