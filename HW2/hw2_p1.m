% AAE 533 Homework 2
% Author: Wasif Islam
% Date: Sep 13th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem One

% Station Properties
GD_LAT = 40.43157;          % Geodedic Latitude [deg]
GD_LONG = 273.085549;       % Geodedic Longitude [deg]
STATION_ALT = 192.5;        % Station Altitude [m]

% Convert Time to Acquire Sidereal Time at Local Observation
STARTING_TIME = datetime(2024, 09, 05, 12, 00, 00, 'TimeZone', 'UTC');
OBSERVATION_TIME = datetime(2024, 09, 06, 04, 30, 00, 'TimeZone', 'UTC');
INTEGRAL_DURATION_SEC = seconds(OBSERVATION_TIME - STARTING_TIME);

% Initialize Orbit Class
sma = 6782.5e3;       % [m]
ecc = 0.001;          % [NA]
inc = 51.5;           % [deg]
true_anom = 5;        % [deg]
arg_perigee = 20;     % [deg]
RAAN = 10;            % [deg]

orbit_object = KeplerOrbitSimple(sma, inc, RAAN, true_anom, arg_perigee, ecc, MU_EARTH);
orbit_object.t0 = 0.0;
orbit_object.tend = INTEGRAL_DURATION_SEC;
orbit_object.dt = 15.0;
orbit_object.x0 = kepler_to_eci_cartesian(orbit_object.semi_major_axis, ...
                                    orbit_object.inclination, ...
                                    orbit_object.RAAN, ...
                                    orbit_object.true_anomaly, ...
                                    orbit_object.argument_of_perigee, ...
                                    orbit_object.eccentricity, ...
                                    MU_EARTH);
% Generate Orbit
[tn, xn] = orbit_object.propagate_simple_kepler();
orbit_object.tn = tn;
orbit_object.xn = xn;

% Extract Final State (X, Y, Z)
observation_position_eci = xn(end, 1:3);
    
% Acquire Station ECEF Position
R_ECEF = GDLL2ECEF(GD_LAT, GD_LONG, STATION_ALT);

% Calculate GC LAT/LONG
[GC_LAT, GC_LONG] = ECEF2GCLL(R_ECEF);

% Calculate Observation Sidereal Time
MJD = juliandate(OBSERVATION_TIME) - MJD_MODIFIER;
[GMST, LMST] = mjd2sidereal(MJD, GD_LONG);