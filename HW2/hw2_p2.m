% AAE 533 Homework 2
% Author: Wasif Islam
% Date: Sep 13th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem Two
stat_data = readtable("AAE533_F24_HW2_Validation_Data.xlsx");
stat.MJD = stat_data.Time_MJD_;
JD_UTC = stat.MJD + MJD_MODIFIER;
JD_TT = JD_UTC + (64.184/86400);
stat.GC_LAT = stat_data.StationGeocentricLatitude_deg_;
stat.GC_LONG = stat_data.StationGeocentricLongitude_deg_;
stat.GD_LAT = stat_data.StationGeodeticLatitude_deg_;
stat.GD_LONG = stat_data.StationGeodeticLongitude_deg_;
stat.statX_J2000 = stat_data.StationXJ2000_km_;
stat.statY_J2000 = stat_data.StationYJ2000_km_;
stat.statZ_J2000 = stat_data.StationZJ2000_km_;
stat.statX_ITRF = stat_data.StationXITRF_km_;
stat.statY_ITRF = stat_data.StationYITRF_km_;
stat.statZ_ITRF = stat_data.StationZITRF_km_;
sample_size = length(stat.MJD);

% Calculate Coordinate Cells
stat_eci = cell(sample_size, 1);
stat_ecef = cell(sample_size, 1);

for sample_index = 1:sample_size
    stat_eci_XYZ = [stat.statX_J2000(sample_index); stat.statY_J2000(sample_index); ... 
                    stat.statZ_J2000(sample_index)];
    stat_ecef_XYZ = [stat.statX_ITRF(sample_index); stat.statY_ITRF(sample_index); ...
                    stat.statZ_ITRF(sample_index)];

    stat_eci{sample_index} = stat_eci_XYZ;
    stat_ecef{sample_index} = stat_ecef_XYZ;

end

% Calculate Sidreal Time
[GMST, LMST] = mjd2sidereal(stat.MJD, stat.GC_LONG);

% Pre-Allocate Error Value Arrays
stat_itrf_validation_err = zeros(sample_size, 1);
stat_j2000_validation_err = zeros(sample_size, 1);

% Calculate both ITRF and J2000 Coordinates and Compare with Validation
% File
for sample_index = 1:sample_size
    R_ITRF = J20002ITRF(stat_eci{sample_index}, GMST(sample_index), JD_UTC(sample_index), ...
                                                JD_TT(sample_index), MJD_MODIFIER);
    R_J2000 = ITRF2J2000(stat_ecef{sample_index}, JD_UTC(sample_index), JD_TT(sample_index), ...
                                                GMST(sample_index), MJD_MODIFIER);

    stat_itrf_validation_err(sample_index) = norm(R_ITRF - stat_ecef{sample_index});
    stat_j2000_validation_err(sample_index) = norm(R_J2000 - stat_eci{sample_index});
    
end

% Plot the Differences
figure(1)
subplot(2,1,1)
plot(LMST, stat_itrf_validation_err, 'bo')
xlabel("Local Mean Sidereal Time [rad]")
ylabel("Residual Norm Error [km]")
grid on
title("Calculated ITRF Coordinates Error")

subplot(2,1,2)
plot(LMST, stat_j2000_validation_err, 'ro')
xlabel("Local Mean Sidereal Time [rad]")
ylabel("Residual Norm Error [km]")
grid on
title("Calculated J2000 Coordinates Error")


















