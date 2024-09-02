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

%% Problem 1

% LEO ORBIT
ecc = 0.0011185;            % Eccentricity
inc = 51.6410;              % Inclination
raan = 297.9317;            % Right Ascending Ascension Node
arg_perigee = 307.1458;     % Argument of Perigee
sma = 6796.5e3;             % Semi-major Axis
t_anomaly = 0;              % True Anomaly

% Define LEO Orbit Class
orbit_LEO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);

% MEO ORBIT
ecc = 0.00802;              % Eccentricity
inc = 55.1542;              % Inclination
raan = 115.4685;            % Right Ascending Ascension Node
arg_perigee = 238.575;      % Argument of Perigee
sma = 12543.0e3;            % Semi-major Axis
t_anomaly = 0;              % True Anomaly

% Define MEO Orbit Class
orbit_MEO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);

% GEO Orbit - Stationary
ecc = 0.0;                  % Eccentricity
inc = 0.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 0.0;          % Argument of Perigee
sma = 42164.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GEO Stationary Orbit Class
orbit_GEO_STAT = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);

% GEO Orbit - Synchronous
ecc = 0.001;                % Eccentricity
inc = 5.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 0.0;          % Argument of Perigee
sma = 42264.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GEO Synch Orbit Class
orbit_GEO_SYNCH = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);

% GTO Orbit
ecc = 0.7312;               % Eccentricity
inc = 7.0;                  % Inclination
raan = 0.0;                 % Right Ascending Ascension Node
arg_perigee = 180.0;        % Argument of Perigee
sma = 24478.0e3;            % Semi-major Axis
t_anomaly = 0.0;            % True Anomaly

% Define GTO Orbit Class
orbit_GTO = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, MU_EARTH);

% Populate Orbit Object Parameters
orbit_array = [orbit_LEO, orbit_MEO, orbit_GEO_STAT, orbit_GEO_SYNCH, orbit_GTO];

% Clearing Duplicate Object Variables
clear orbit_LEO orbit_MEO orbit_GEO_SYNCH orbit_GEO_STAT orbit_GTO

% Define Propagation Properties for Each Orbit Object
for object_index = 1:length(orbit_array)

    % Calculate Orbital Period
    orbit_array(object_index).orbit_period = orbital_period(MU_EARTH, ...
        orbit_array(object_index).semi_major_axis);

    % Set dt, t0, and tend
    orbit_array(object_index).t0 = 0.0;
    orbit_array(object_index).tend = 2 * orbit_array(object_index).orbit_period;
    orbit_array(object_index).dt = 15.0;

    % Calculate ECI Initial Conditions from Orbital Elements
    orbit_array(object_index).x0 = kepler_to_eci_cartesian(orbit_array(object_index).semi_major_axis, ...
                                    orbit_array(object_index).inclination, ...
                                    orbit_array(object_index).RAAN, ...
                                    orbit_array(object_index).true_anomaly, ...
                                    orbit_array(object_index).argument_of_perigee, ...
                                    orbit_array(object_index).eccentricity, ...
                                    MU_EARTH);


end

% Generate Orbit in Parallel
for obj_index = 1:length(orbit_array)
    [tn, xn] = orbit_array(obj_index).propagate_simple_kepler();
    orbit_array(obj_index).tn = tn;
    orbit_array(obj_index).xn = xn;
end
toc;

% Generate Orbit Plots
figure(1)
for obj_index = 1:length(orbit_array)
    obj = orbit_array(obj_index);
    X = obj.xn(:, 1);
    Y = obj.xn(:, 2);
    Z = obj.xn(:, 3);
    plot3(X, Y, Z);
    hold on
end
