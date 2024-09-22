% AAE 533 Homework 2
% Author: Wasif Islam
% Date: Sep 13th, 2024

clc;
clear;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

% Purdue Station Coordinates
GEO_HEIGHT = 35786e3;       % Geostationary Height [m]
GD_LAT = 40.43157;          % Geodedic Latitude [deg]
GD_LONG = 273.085549;       % Geodedic Longitude [deg]
STATION_ALT = 192.5e-3;      % Station Altitude [km]

%% Problem 3a

% Atmospheric Parameters (Septmeber 14th)
p = 1017.9;     % Pressure [millibars]
T = 18.8889 + 273.15;
RH = 0.84;

% Observation Elevations
obs_elev = [90, 75, 25];

% Calculate DeltaZ and Absolute Difference (Using Slant Rule)
dz = zeros(3,1);
dz_km = zeros(3,1);
R = zeros(3,1);          % Range given Slant angle calculation
t_sat = zeros(3, 1);     % Time for light to arrive at satellite
for index = 1:3
    dz(index) = calc_refraction(p, T, RH, obs_elev(index));
    R(index) = GEO_HEIGHT / cos(deg2rad(90 - obs_elev(index)));
    dz_km(index) = (R(index) * dz(index)) * 1e-3;
    t_sat(index) = R(index) ./ c;
end

%% Problem 3b

% Establish Time
STARTING_TIME = datetime(2024, 09, 05, 12, 00, 00, 'TimeZone', 'UTC');
OBS_TIME = STARTING_TIME + seconds(t_sat);
OBS_TIME_TT = OBS_TIME + seconds(64.184);
INT_DURATION = seconds(OBS_TIME - STARTING_TIME);

% Calculate Observation Position of Topocenter
R_ECEF = GDLL2ECEF(GD_LAT, GD_LONG, STATION_ALT);
% RJ2000 = ITRF2J2000(R_ECEF, )
% 
% GEO Orbit - Stationary
ecc = 0.0;                  % Eccentricity
inc = 0.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 0.0;          % Argument of Perigee
sma = 42164.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GEO Stationary Orbit Class
orbit_GEO_STAT = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);
orbit_GEO_STAT.t0 = 0.0;
orbit_GEO_STAT.dt = 0.005;
orbit_GEO_STAT.x0 = kepler_to_eci_cartesian(orbit_GEO_STAT.semi_major_axis, ...
                                            orbit_GEO_STAT.inclination, ...
                                            orbit_GEO_STAT.RAAN, ...
                                            orbit_GEO_STAT.true_anomaly, ...
                                            orbit_GEO_STAT.argument_of_perigee, ...
                                            orbit_GEO_STAT.eccentricity, ...
                                            MU_EARTH);
x0 = orbit_GEO_STAT.x0;
positional_diff_light = zeros(3, 1);
for index = 1:3
    orbit_GEO_STAT.tend = INT_DURATION(index);
    [tn, xn] = orbit_GEO_STAT.propagate_simple_kepler();
    positional_diff_light(index) = norm(x0(1:3) - xn(end, 1:3)');
end






