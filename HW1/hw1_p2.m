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
station_data.AZ = coordinate_data.SatelliteAzimuth_deg_;
station_data.ELEV = coordinate_data.SatelliteElevation_deg_;

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


% Question Flag:
switch_geoc_geod = false;       % For problem 2b, flag to switch geocentric
                                % latitude with geodedic and vice versa
if switch_geoc_geod
     temp = station_data.GEOC_LAT;
     station_data.GEOC_LAT = station_data.GEOD_LAT;
     station_data.GEOD_LAT = temp;
end

%% Problem 2a/b

% Calculate Local and Greenwich Mean Sidereal Time
[GMST, LMST] = mjd2sidereal(station_data.MJD, station_data.GEOC_LONG);

% Acquire ECEF R magnitude (technically should be the same for ECI)
R = station_data.StationR_ECEF;

stat_eci_calc = cell(length(LMST), 1);     % Pre-allocating Matrix Array
stat_eci_error = zeros(length(LMST), 1);   % Pre-allocating error term array

for matrix_index = 1:length(LMST)

    % Acquire ECI Coordinates for Station
    stat_eci_calc{matrix_index} = lmst_lat2R_topo(R, station_data.GEOC_LAT(matrix_index), ...
                                                  LMST(matrix_index));
    % Calculate error between derived and actual
    stat_eci_error(matrix_index) = norm(stat_eci_calc{matrix_index} - stat_eci{matrix_index});

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
az_error = az_calc - station_data.AZ;
elev_error = elev_calc - station_data.ELEV;

% Generate Error Graphs
if ~switch_geoc_geod
    title1 = "Station ECI Coordinate Error (Calculated vs. Given)";
    title2 = "Satellite Range (\rho) Calculation Error";
    title3 = "r_{topo} Calculation Error (Calculated using RA/Declination)";
    title4 = "Azimuth and Elevation Error from Reference";
else
    title1 = "Station ECI Coordinate Error (Incorrect Latitude)";
    title2 = "Satellite Range (\rho) Calculation Error (Incorrect Latitude)";
    title3 = "r_{topo} Calculation Error (Incorrect Latitude)";
    title4 = "Azimuth and Elevation Error from Reference (Incorrect Latitude)";
end
figure(1)

% ECI Coordinate Calculation Errors
subplot(2,2,1)
plot(LMST, stat_eci_error, 'bo')
yline(0.5, '--', {'0.5KM'})
yline(-0.5, '--', {'-0.5KM'}, 'LabelVerticalAlignment', 'bottom')
if ~switch_geoc_geod
    ylim([-2, 2])
end
xlabel("Local Sidereal TIme [rad]")
ylabel("Norm Error [km]")
grid on
title(title1);

% Sat Range from Topocenter Error
subplot(2,2,2)
plot(LMST, sat_range_error, 'ro')
yline(1, '--', {'1KM'})
yline(-1, '--', {'-1KM'}, 'LabelVerticalAlignment', 'bottom')
if ~switch_geoc_geod
    ylim([-2, 2])
end
xlabel("Local Sidereal Time [rad]")
ylabel("Norm Error [km]")
grid on
title(title2);

% Satellite r_{topo} Calculation Error
subplot(2,2,3)
plot(LMST, dec_ra_error_mag, 'mo')
yline(0.5, '--', {'0.5KM'})
yline(-0.5, '--', {'-0.5KM'}, 'LabelVerticalAlignment', 'bottom')
if ~switch_geoc_geod
    ylim([-2, 2])
end
xlabel("Local Sidereal Time [rad]")
ylabel("Norm Error [km]")
grid on
title(title3)

% Azimuth and Elevation Calculation Error
subplot(2,2,4)
plot(LMST, az_error, 'LineStyle', 'none', 'Marker', 'o', 'DisplayName', "Azimuth Error [deg]")
hold on
plot(LMST, elev_error, 'LineStyle', 'none', 'Marker','.', 'MarkerSize', 12, 'DisplayName', "Elevation Error [deg]")
hold off
xlabel("Local Sidereal Time [rad]")
ylabel("Error [deg]")
legend()
grid on
title(title4)

%% Problem 2b

%% Problem 2d


