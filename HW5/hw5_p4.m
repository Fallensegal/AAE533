% AAE 533 Homework 5
% Author: Wasif Islam
% Date: Oct 8th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 4

ISS.r = [6006.021903425690; -2663.688355339750; 1740.841910572000] * 1e3;
ISS.v = [3.37867307304870; 3.87619981253494; -5.67778670831512] * 1e3;

% Initial State Transition Matrix
PHI0 = eye(6);

% Initial Conditions
X0 = [ISS.r; ISS.v; PHI0(:)];
t0 = 0;
tf = 1;
tvec = [t0, tf];

% Set ODE45 options for higher precision if necessary
options = odeset('RelTol',1e-12,'AbsTol',1e-12);

% Perform the integration
[~, Y] = ode45(@TBD_STM, tvec, X0, options);

% Extract the final STM from the last row of Y
Phi_final = reshape(Y(end, 7:42), 6, 6);

% Display the STM
disp('State Transition Matrix after 1 second (J2000 inertial frame):');
disp(Phi_final);