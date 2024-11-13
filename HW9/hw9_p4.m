% AAE 533 Homework 9
% Author: Wasif Islam
% Date: November 12th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 4
[GEO_INIT, epoch_time] = read_3le('GEO_TLE_HW9.txt');

% Manual Input from TLE (angles in deg)
GOES.inc = 9.2564;
GOES.RAAN = 307.4218;
GOES.ecc = 0.0029976;
GOES.argp = 95.8778;
GOES.TA = 70.7006;
GOES.MM = 0.99230085121663;

% Calculate Semi-Major Axis from Mean Motion
motion_rads = GOES.MM * 2 * pi / 86400;
GOES.sma = (MU_EARTH / (motion_rads^2))^(1/3);

% Initial State ECI
GOES_ECI = kepler_to_eci_cartesian(GOES.sma, GOES.inc, GOES.RAAN, GOES.TA, GOES.argp, GOES.ecc, MU_EARTH);
orbital_period = (86400/(GOES.MM));

% Propagate 2-Body Orbit
t0 = 0;
tend = orbital_period * 2;
dt = 15;
tspan = t0:dt:tend;
options = odeset('RelTol',1e-9,'AbsTol',1e-12);
x0 = GOES_ECI;

[t1, StateA] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, MU_EARTH), tspan, x0, options);

% Propagate SGP4 Orbit
tspan_sgp4 = tspan ./ 60;
for i = 1:length(tspan_sgp4)
    [~,r,~] = sgp4(GEO_INIT, tsince);

            % Convert to ECI Reference Frame
            precession_matrix = calc_precession(JD_TT);
            nutation_matrix = calc_nutation(JD_TT);
            r_J2000 = precession_matrix' * nutation_matrix' * r';

            tle_dict_new = insert(tle_dict_new, sat_name, {r_J2000});