% AAE 533 Homework 6
% Author: Wasif Islam
% Date: Oct 17th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 2

% ISS Observations
ISS_DATA = readtable('Ephemeris_ISS.txt', 'Delimiter', ' ');
time = ISS_DATA.Var1;
time_vec = datevec(time);
r = [ISS_DATA.Var2, ISS_DATA.Var3, ISS_DATA.Var4] * 1e3;
v = [ISS_DATA.Var5, ISS_DATA.Var6, ISS_DATA.Var7] * 1e3;

% Purdue Ground Station
STATION_ECEF = GDLL2ECEF(Purdue.GD_LAT, Purdue.GD_LONG, Purdue.STATION_ALT);

% Calculate Station J2K for UTC Time with RA and Dec
for index = 1:length(time)
    STATION_ECI(index, :) = ecef2eci(time_vec(index, :), STATION_ECEF);
    stat_eci = STATION_ECI(index, :)';
    sat_eci = r(index, :)';
    [ra(index), dec(index)] = ECI2DEC_RA(sat_eci, stat_eci);
end

% Reshape RA and Dec to Column Vectors
ra = ra(:);  % [20x1]
dec = dec(:); % [20x1]

%% Setup LUMVE Solution

% Calculate Measurement Noise
sigma_arcsec = 2;
sigma_rad = (sigma_arcsec / 3600) * (pi / 180);
sigma_deg = rad2deg(sigma_rad);

% Calculate Perturbed Initial Guess
peturbed_x_init = 1.02 .* r(1,:)';
peturbed_v_init = 1.02 .* v(1,:)';
x_est = [peturbed_x_init; peturbed_v_init];

% Number of Observations
num_obs = length(ra); % 20

% Iterative Parameters
max_iter = 20;     % Maximum number of iterations
tolerance = 1e-6;  % Convergence tolerance

% Initialize Time Vector (relative to initial time)
t_initial = time(1);           % Initial time [seconds]
time_rel = seconds(time - t_initial);   % Relative times [seconds]


% Preallocate for Efficiency
H_total = zeros(2 * num_obs, 6); % Design Matrix [40x6]
y_total = zeros(2 * num_obs, 1); % Residuals Vector [40x1]

% Measurement Vector: Interleave RA and Dec
y_obs = reshape([ra, dec]', 2*num_obs, 1); % [40x1]

% Iterative Loop
for iter = 1:max_iter
    % Reset Design Matrix and Residuals
    H_total(:) = 0;
    y_total(:) = 0;
    
    for i = 1:num_obs
        t_i = time_rel(i); % Propagation Time [seconds]
        
        % Propagate Current Estimate to Observation Time
        [x_prop, ~] = HW6_PS(x_est, t_i, @STM_2BD_CORR, MU_EARTH);

        % Convert Propagated State to RA and Dec
        sat_eci = x_prop(1:3);
        stat_eci = STATION_ECI(i, :)';

        [RA_pred, Dec_pred] = ECI2DEC_RA(sat_eci, stat_eci);
        
        % Compute Residuals (Observed - Predicted)
        y_R = y_obs(2*i-1) - RA_pred; % [degrees]
        y_D = y_obs(2*i)   - Dec_pred; % [degrees]
        y_total(2*i-1) = y_R;
        y_total(2*i)   = y_D;
        
        % Compute Jacobian
        H_i = ra_dec_jacobian(x_prop); % [2x6]
        H_total(2*i-1:2*i, :) = H_i;
    end
    % Measurement Covariance Matrix
    R = (sigma_deg^2) * eye(2 * num_obs); % [40x40] [degrees^2]
    
    % Compute Delta_x using Weighted Least Squares
    % delta_x = (H' * inv(R) * H) \ (H' * inv(R) * y)
    % Using MATLAB's backslash for numerical stability
    delta_x = (H_total' / R * H_total) \ (H_total' / R * y_total); % [6x1] [m; m/s]
    
    % Update Estimate
    x_est = x_est + delta_x;
    % Ensure x_est remains a column vector
    x_est = x_est(:);
    
    % Compute Norm of Delta_x for Convergence Check
    delta_norm = norm(delta_x);
    fprintf('Iteration %d: delta_x norm = %.6e\n', iter, delta_norm);
    
    % Check for Convergence
    if delta_norm < tolerance
        fprintf('Converged in %d iterations.\n', iter);
        break;
    end
    
    % If Maximum Iterations Reached
    if iter == max_iter
        warning('Maximum iterations reached without convergence.');
    end
end








