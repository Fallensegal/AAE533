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
epoch_time = epoch_time{1};

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
TT_ADJUST = seconds(64.184);
tspan_sgp4 = tspan ./ 60;
sgp4_final_state = [];
for i = 1:length(tspan_sgp4)
    if i == 1
        continue
    end
    [~,r,~] = sgp4(GEO_INIT{1}, tspan_sgp4(i));

    % Adjust Time for TT Time
    target_time = epoch_time + minutes(tspan_sgp4(i));
    target_time_TT = target_time + TT_ADJUST;

    JD_TT = juliandate(target_time_TT);

    % Convert to ECI Reference Frame
    precession_matrix = calc_precession(JD_TT);
    nutation_matrix = calc_nutation(JD_TT);
    r_J2000 = precession_matrix' * nutation_matrix' * r';
    sgp4_final_state(i, :) = r_J2000;


end

% Plotting SGP4 vs Numerical Integration Outputs
figure(1)
hold on;
axis equal;
grid on;
title("GOES 4 Orbit w.r.t Earth")
xlabel('X Position (km)');
ylabel('Y Position (km)');
zlabel('Z Position (km)');

[X, Y, Z] = sphere(50);
X = X * (EARTH_RAD * 1e-3);
Y = Y * (EARTH_RAD * 1e-3);
Z = Z * (EARTH_RAD * 1e-3);
surf(X, Y, Z, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Earth');
plot3(StateA(:,1), StateA(:,2), StateA(:,3), 'DisplayName', 'Numerical Integration')
plot3(sgp4_final_state(:,1), sgp4_final_state(:,2), sgp4_final_state(:,3), 'DisplayName', 'SGP4')
hold off

% Plot X, Y, Z, Residuals
figure(2)
subplot(3,1,1)
plot(tspan, StateA(:,1) - sgp4_final_state(:,1), 'r')
title("X-Axis Position Diff: SGP4 vs. Numerical Integration")
xlabel("Time [sec]")
ylabel("X Residual [km]")
grid on

subplot(3,1,2)
plot(tspan, StateA(:,2) - sgp4_final_state(:,2), 'g')
title("Y-Axis Position Diff: SGP4 vs. Numerical Integration")
xlabel("Time [sec]")
ylabel("Y Residual [km]")
grid on

subplot(3,1,3)
plot(tspan, StateA(:,3) - sgp4_final_state(:,3), 'b')
title("Z-Axis Position Diff: SGP4 vs. Numerical Integration")
xlabel("Time [sec]")
ylabel("Z Residual [km]")
grid on


