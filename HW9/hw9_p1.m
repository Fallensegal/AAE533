% AAE 533 Homework 9
% Author: Wasif Islam
% Date: November 14th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));
load("constants.mat");

%% Problem 1
sc = satelliteScenario;
sat1 = satellite(sc, 'ISS_TLE.txt');
elem1 = orbitalElements(sat1);
epoch_time = elem1.Epoch;
TT_ADJUST = seconds(64.184);
epoch_TT = epoch_time + TT_ADJUST;
JD_TT = juliandate(epoch_TT);

% Manual Input from TLE (angles in deg)
MA = elem1.MeanAnomaly;
elem1.MeanMotion = 15.49883;    %For whatever reason, the parser did not acquire mean motion correctly
motion_rads = elem1.MeanMotion * 2 * pi / 86400;
ISS_SMA = (MU_EARTH / (motion_rads^2)) ^(1/3);

ISS_TEME = kepler_to_eci_cartesian(ISS_SMA, elem1.Inclination, elem1.RightAscensionOfAscendingNode, ...
                                    elem1.MeanAnomaly, elem1.ArgumentOfPeriapsis, ...
                                    elem1.Eccentricity, MU_EARTH);

% TEME to J2000
precession_matrix = calc_precession(JD_TT);
nutation_matrix = calc_nutation(JD_TT);
ISS_J2000_x = precession_matrix' * nutation_matrix' * ISS_TEME(1:3);
ISS_J2000_v = precession_matrix' * nutation_matrix' * ISS_TEME(4:6);
ISS_J2000 = [ISS_J2000_x', ISS_J2000_v'];

% Generating Measurements
t0 = 0;
dt = 15.0;
tf = dt * 100;
tspan = t0:dt:tf;
options = odeset('AbsTol', 1e-9, 'RelTol', 1e-9);

[tmeas, X] = ode45(@(t, r_state)simple_kepler_orbit_pde(r_state, MU_EARTH), ...
                tspan, ISS_J2000, options);

LAT = Purdue.GD_LAT;
LONG = Purdue.GD_LONG;
ALT = Purdue.STATION_ALT;

Epoch_Array = [epoch_time.Year, epoch_time.Month, epoch_time.Day, ...
                epoch_time.Hour, epoch_time.Minute, epoch_time.Second];

Station_J2000 = lla2eci([LAT, LONG, ALT], Epoch_Array);

% Measurements
[z, H_TILD] = genRA_DEC(X', Station_J2000');

% Dropping the First t value in tmeas to not propagate to 0
tmeas(1) = [];

% Initial State Mean, Covariance, Measurement Noise
m0 = X(1, :) + (X(1,:) .* 0.01);
P0 = blkdiag((1.0e3)^2 * eye(3), (1e0)^2 * eye(3));
Rk = (2.0 * (1.0/3600.0) * (pi/180.0))^2 * eye(2);

% Empty Arrays
sigma_plot = [];

% Implement Kalman Filter
tkm1 = 0;
mkm1 = m0';
Pkm1 = P0;
for k = 1:length(tmeas)
    tk = tmeas(k);
    x_obj = X(k, 1:3);
    v_obj = X(k, 4:6);

    % Measurement - 1st position is Right Ascension, then Declination
    zk = [z(1,k), z(2,k)] + (chol(Rk)' * randn(2,1))';

    % Propagate to Get Mean and Cov
    [~, XX] = ode45(@(t, xPhi) STM_2BD_CORR(t, xPhi, MU_EARTH), ...
                    [tkm1, tk], [mkm1; Pkm1(:)], options);

    % Propagated Mean and Cov
    mkm = XX(end, 1:6)';
    Pkm = reshape(XX(end, 7:42)', 6, 6);

    % Force Symmetry
    Pkm = (Pkm + Pkm') / 2;
    %Pkm = Pkm + 1e-9 * eye(size(Pkm));

    % Compute Estimate Measures
    epoch_t = epoch_time + seconds(tk);
    Epoch_A = [epoch_t.Year, epoch_t.Month, epoch_t.Day, ...
                epoch_t.Hour, epoch_t.Minute, epoch_t.Second];
    Station_J2K = lla2eci([LAT, LONG, ALT], Epoch_A);
    [z_est, H_TILD] = genRA_DEC(mkm, Station_J2K');

    % Calculate Kalman Gain
    Ck = Pkm * H_TILD';
    Wk = H_TILD * Ck + Rk;
    Kk = Ck / Wk;

    % Kalman Update
    mkp = mkm + Kk * (zk' - z_est);
    Pkp = Pkm - Kk * H_TILD * Pkm;

    % Force Symmetry
    Pkp = (Pkp + Pkp') / 2;
    %Pkp = Pkp + 1e-9 * eye(size(Pkp));

    % Plot Variables
    sigma_plot(:, k) = sqrt(diag(Pkp));
    resid_plot(:, k) = zk' - z_est;

    tkm1 = tk;
    mkm1 = mkp;
    pkm1 = Pkp;
    
end

%% Plotting Kalman Filter Performance
figure(1)
plot(tmeas, resid_plot)
xlabel("Time [sec]")
ylabel("Angle Residual [deg]")
grid on
title("Observation Residual - True vs. Estimated")
legend('Right Ascension', 'Declination')

figure(2)
plot(tmeas, sigma_plot(1:3, :))
xlabel("Time [sec]")
ylabel("Standard Deviation \sigma [m]")
grid on
title("Kalman Filter Standard Deviation")
legend('X - Axis', 'Y - Axis', 'Z - Axis')

%% Perform the Entire Stack (IOD, LUMVE, Kalman)- [Please Run This Separately]