% AAE 533 Homework 1
% Author: Wasif Islam
% Date: Aug 31st, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("standard_gravitation_parameter.mat");

%% Problem 1

% LEO ORBIT
ecc = 0.0011185;            % Eccentricity
inc = 51.6410;              % Inclination
raan = 297.9317;            % Right Ascending Ascension Node
arg_perigee = 307.1458;     % Argument of Perigee
sma = 6796.5e3;             % Semi-major Axis
t_anomaly = 0;              % True Anomaly

% Define LEO Orbit Class
orbit_LEO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc);

% MEO ORBIT
ecc = 0.00802;              % Eccentricity
inc = 55.1542;              % Inclination
raan = 115.4685;            % Right Ascending Ascension Node
arg_perigee = 238.575;      % Argument of Perigee
sma = 12543.0e3;            % Semi-major Axis
t_anomaly = 0;              % True Anomaly

% Define MEO Orbit Class
orbit_MEO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc);

% GEO Orbit - Stationary
ecc = 0.0;                  % Eccentricity
inc = 0.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 0.0;          % Argument of Perigee
sma = 42164.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GEO Stationary Orbit Class
orbit_GEO_STAT = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc);

% GEO Orbit - Synchronous
ecc = 0.001;                % Eccentricity
inc = 5.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 0.0;          % Argument of Perigee
sma = 42264.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GEO Synch Orbit Class
orbit_GEO_SYNCH = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc);

% GTO Orbit
ecc = 0.7312;               % Eccentricity
inc = 7.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 180.0;        % Argument of Perigee
sma = 24478.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GTO Orbit Class
orbit_GTO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc);