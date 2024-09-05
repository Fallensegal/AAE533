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

%% Problem 2

% Calculate Local and Greenwich Mean Sidereal Time
[GMST, LMST] = mjd2sidereal(station_data.MJD, station_data.GEOC_LONG);

% Acquire ECEF R magnitude (technically should be the same for ECI)
R = station_data.StationR_ECEF;

stat_eci_calc = cell(length(LMST), 1);     % Pre-allocating Matrix Array
for matrix_index = 1:length(LMST)

    % Acquire ECI Coordinates for Station
    RT = [R .* cos(deg2rad(station_data.GEOC_LAT(matrix_index))) .* cos(LMST(matrix_index)); ...
          R .* cos(deg2rad(station_data.GEOC_LAT(matrix_index))) * sin(LMST(matrix_index)); ...
          R .* sin(deg2rad(station_data.GEOC_LAT(matrix_index)))];

    stat_eci_calc{matrix_index} = RT;

end

% Compare ECI Values between Given and Calculated

% Calculate Range

% Subtract Rtopo from total r, divide by range, get l-hat

% solve for delta, raan


% Test
%X = coordinate_data.StationXECEF_Km_(1);
%Y = coordinate_data.StationYECEF_Km_(1);
%Z = coordinate_data.StationZECEF_Km_(1);

%R = norm([X, Y, Z]);
%R3_Rot = [cos(LMST) -sin(LMST) 0; sin(LMST) cos(LMST) 0; 0 0 1];
%RT = [R * cos(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1))) * cos(LMST); ...
%      R * cos(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1))) * sin(LMST); ...
%      R * sin(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1)))];

