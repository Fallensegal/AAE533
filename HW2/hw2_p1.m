% AAE 533 Homework 2
% Author: Wasif Islam
% Date: Sep 13th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem One - A

% Station Properties
GD_LAT = 40.43157;          % Geodedic Latitude [deg]
GD_LONG = 273.085549;       % Geodedic Longitude [deg]
STATION_ALT = 192.5;        % Station Altitude [m]

% Convert Time to Acquire Sidereal Time at Local Observation
STARTING_TIME = datetime(2024, 09, 05, 12, 00, 00, 'TimeZone', 'UTC');
OBSERVATION_TIME = datetime(2024, 09, 06, 04, 30, 00, 'TimeZone', 'UTC');

% UTC to TT Based on Script 2.5
OBSERVATION_TIME_TT = OBSERVATION_TIME + seconds(64.184);
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
observation_position_eci = xn(end, 1:3)';
    
% Acquire Station ECEF Position
R_ECEF = GDLL2ECEF(GD_LAT, GD_LONG, STATION_ALT)';

% Calculate Observation Sidereal Time
JD_UTC = juliandate(OBSERVATION_TIME);
JD_TT = juliandate(OBSERVATION_TIME_TT);
MJD_UTC = JD_UTC - MJD_MODIFIER;
[GMST, LMST] = mjd2sidereal(MJD_UTC, GD_LONG);

rj2000 = ITRF2J2000(R_ECEF, JD_UTC, JD_TT, GMST, MJD_MODIFIER);

% Calculate Right Ascension and Declination, Az, El
[ra, dec] = ECI2DEC_RA(observation_position_eci, rj2000);
hour_angle = LMST - deg2rad(ra);
tclm_coords = tce2tclm(GD_LAT, dec, hour_angle);
[az, elev] = tclm2ah(tclm_coords, 1);

%% Problem One: B

precession_matrix = calc_precession(JD_TT);
nutation_matrix = calc_nutation(JD_TT);
TOD_MATRIX = nutation_matrix * precession_matrix;

range_eci = norm(observation_position_eci - rj2000);

% Calculate tau and t_satellite
tau_light = range_eci / c;
t_sat = tn(end) - tau_light;
orbit_object.tend = t_sat;
[tn, xn] = orbit_object.propagate_simple_kepler();

% Fix Times
JD_UTC_FIX = juliandate(OBSERVATION_TIME - seconds(tau_light));
JD_TT_FIX = juliandate(OBSERVATION_TIME + seconds(64.184) - seconds(tau_light));
MJD_UTC_FIX = JD_UTC_FIX - MJD_MODIFIER;
[GMST_FIX, ~] = mjd2sidereal(MJD_UTC_FIX, GD_LONG);

rj2000_fix = ITRF2J2000(R_ECEF, JD_UTC_FIX, JD_TT_FIX, GMST_FIX, MJD_MODIFIER);
sat_eci_fix = xn(end, 1:3)';

sat_tod = TOD_MATRIX * sat_eci_fix;
stat_tod = TOD_MATRIX * rj2000_fix;
[ra_tod, dec_tod] = ECI2DEC_RA(sat_tod, stat_tod);














