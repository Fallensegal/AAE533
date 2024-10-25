% AAE 533 Homework 7
% Author: Wasif Islam
% Date: October 25th, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem One

% Acquire Initial Conditions from Last Homework

% Defined Constants
ISS_PERIOD = 5400;      % Period [s]
start_epoch = datetime('2024-10-18T12:00:00.000');

% Gravitational Parameters
mu.earth = MU_EARTH;
mu.moon = 4.9028695e12;
mu.sun = 1.327e20;

% SRP Parameters
srp.area = 5500;                % Solar Radiation Area [m^2]
srp.mass = 419725;              % Mass [kg]
srp.C = ((1/4) + (1/9)*1.4);    % Reflectivity Constant

% Drag Parameters
drag.rho = 2.72e-12;             % Atmospheric Density [kg/m3]
drag.area = 1702.82;             % Drag Affected Area [m^2]
drag.mass = 419725;              % Mass [kg]

% ISS Initial State
iss_state = [1206.536023117490; 6341.948632667270; 2103.445062025980; ...
    -5.24121309257951; -0.85217709490634; 5.53106828735412] * 1e3;
tspan = [0, 10*ISS_PERIOD];
options = odeset('RelTol',1e-12,'AbsTol',1e-12);

