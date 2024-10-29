% AAE 533 Homework 7
% Author: Wasif Islam
% Date: October 25th, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 3

% Set Distribution Initial Conditions
mu0 = [
    153446.180;   % m
    41874155.872; % m
    0;            % m
    3066.875;     % m/s
    -11.374;      % m/s
    0             % m/s
];

P0 = [
    6494.080, -376.139, 0, 0.0160, -0.494, 0;
    -376.139, 22.560, 0, -9.883e-4, 0.0286, 0;
    0, 0, 1.205, 0, 0, -6.071e-5;
    0.0160, -9.883e-4, 0, 4.437e-8, -1.212e-6, 0;
    -0.494, 0.0286, 0, -1.212e-6, 3.762e-5, 0;
    0, 0, -6.071e-5, 0, 0, 3.390e-9
];

% Covariance Matrix Scaling - Positive Semi-Definite
P0 = (P0 + P0') / 2;
P0 = P0 + 1e-9 * eye(size(P0));

num_samples = 200;
state_samples = mvnrnd(mu0, P0, num_samples);

% Propagate Orbits and Generate Mean and Covariance
t0 = 0;
tend = 5400 * 2;
tspan = [t0, tend];
final_states = zeros(num_samples, 6);
options = odeset('RelTol',1e-9,'AbsTol',1e-12);

parfor i = 1:num_samples
    xi0 = state_samples(i, :)';

    % Integrate
    [~, xi] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, MU_EARTH), tspan, xi0, options);

    final_states(i, :) = xi(end, :);
end

mu_final_monte_carlo = mean(final_states, 1)';
P_final_monte_carlo = cov(final_states);

% Propagate Orbit with STM
Phi0 = eye(6);
xPhi0 = [mu0; Phi0(:)];

[t, xPhi] = ode45(@(t, xPhi) STM_2BD_CORR(t, xPhi, MU_EARTH), tspan, xPhi0, options);

% Extract 1st and 2nd Moments
mu_final_analytical = xPhi(end, 1:6)';
Phi_final = reshape(xPhi(end, 7:42), [6, 6]);
P_final_analytical = Phi_final * P0 * Phi_final';