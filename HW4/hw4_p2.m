% AAE 533 Homework 3
% Author: Wasif Islam
% Date: Sep 28th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 2

% Define observations and its epochs - ISS.OEM_J2K_EPH_9_29.txt
ISS.r_t1 = 1e3 * [4986.512504142630; -3485.770944263830; 3023.386450300860];
ISS.r_t2 = 1e3 * [-2593.943544152480; 4275.261372985110; -4608.396879826420];

ISS.v_t1 = 1e3 * [5.06545575383698; 2.93258157653538; -4.94456950381827];
ISS.v_t2 = 1e3 * [-6.96054913600662; -0.97203254568219; 3.02635778574540];

ISS.t1 = datetime('2024-09-27T12:00:00.000'); 
ISS.t2 = datetime('2024-09-27T12:40:00.000');

time_diff = seconds(ISS.t2 - ISS.t1);

% Home LLA - Gaitherburg, MD
Home.LAT = 39.1968;         % [deg]
Home.LONG = 282.8082;       % [deg]
Home.Alt = 106.68;          % [deg]

% Station - ECEF
STAT_ECEF = GDLL2ECEF(Home.LAT, Home.LONG, Home.Alt);

% Topocentric ECI - OBS 1/2
O1_ECI = ecef2eci(ISS.t1, STAT_ECEF);
O2_ECI = ecef2eci(ISS.t2, STAT_ECEF);

% Topocentric ECI Derivative - OBS 1/2
omega = [0;0;7.2921150e-5];     % Earth Rotation Rate
O1_DOT_ECI = cross(omega, O1_ECI);
O2_DOT_ECI = cross(omega, O2_ECI);

% Generate Dec/RA States
[ra1, dec1] = ECI2DEC_RA(ISS.r_t1, O1_ECI);
[ra2, dec2] = ECI2DEC_RA(ISS.r_t2, O2_ECI);

% Approximation of Derivative of RA and Declination (Computed Separately
% using chain rule)

ra1_dot = 5.82e-4;      % [rad/s]
dec1_dot = -4.57e-4;    % [rad/s]

ra2_dot = -3.806e-3;    % [rad/s]
dec2_dot = 7.9e-4;       % [rad/s]

% Define Angular Momentum Constraint
norm_h = norm(cross(ISS.r_t1, ISS.v_t1));

% Define Constraints
E_ZERO = 0;
E_SEMI_CONST = -MU_EARTH / (2 * 6738e3);
E_ECC = (-(MU_EARTH^2) * (1 - (0.4^2))) / (2 * norm_h^2);

% Calculate Admissible Regions
rho = linspace(0, 20000e3, 1000);

% Admissible Region T1
[rho_0, rho_dot_0, v0, r0] = admissible_region(deg2rad(ra1), deg2rad(dec1), ra1_dot, dec1_dot, O1_ECI, ...
                        O1_DOT_ECI, rho, MU_EARTH, E_ZERO);
[rho_1, rho_dot_1, v1, r1] = admissible_region(deg2rad(ra1), deg2rad(dec1), ra1_dot, dec1_dot, O1_ECI, ...
                        O1_DOT_ECI, rho, MU_EARTH, E_SEMI_CONST);
[rho_2, rho_dot_2, v2, r2] = admissible_region(deg2rad(ra1), deg2rad(dec1), ra1_dot, dec1_dot, O1_ECI, ...
                        O1_DOT_ECI, rho, MU_EARTH, E_ECC);

% Uniformly Sample Distributions - T1
total_vec_amnt = numel(rho_0);
uniform_sample_t1 = randi([0,total_vec_amnt], 1, 10);
orbit_init_t1 = [];
i = 1;      % Need this for Indexing
for index = uniform_sample_t1
    orbit_init_t1(i, 1:3) = r0(index, :);
    orbit_init_t1(i, 4:6) = v0(index, :);
    i = i + 1;
end

% Create Orbits - Generate the Orbit Objects
orbits = {};
for orb_i = 1:length(orbit_init_t1)
    orb = KeplerOrbitSimple();
    orb.mu = MU_EARTH;
    orb.t0 = 0.0;
    orb.tend = 86400;
    orb.dt = 15.0;
    orb.x0 = [orbit_init_t1(orb_i, 1:3), orbit_init_t1(orb_i, 4:6)];
    [~, xn] = orb.propagate_simple_kepler();
    orbits{orb_i} = xn;
end


figure(1)
% Plot the Actual Orbits
for orb_i = 1:length(orbit_init_t1)
    obj = orbits{orb_i};
    X = obj(:, 1);
    Y = obj(:, 2);
    Z = obj(:, 3);
    plot3(X, Y, Z, 'LineWidth', 2);
    hold on
end

% Plot Spherical (Representing Earth)
earth_radius = 6378e2;        % DIM: [m]
[x_earth, y_earth, z_earth] = sphere;
x_earth = x_earth * earth_radius;
y_earth = y_earth * earth_radius;
z_earth = z_earth * earth_radius;
surf(x_earth, y_earth, z_earth, 'FaceColor', 'k');
axis equal;




% Plot Admissible Region  - T1
figure(2)
plot(rho_0./6378e3, rho_dot_0, 'DisplayName', "Zero")
hold on
plot(rho_1./6378e3, rho_dot_1, 'DisplayName', "Semi-Major Axis = 6738km")
plot(rho_2./6378e3, rho_dot_2, "DisplayName", "Eccentricity = 0.4")
hold off
ax = gca;
ax.ColorOrderIndex = 1;
grid on
title('Admissible Regions with SMA and Eccentricity Constraints - Obs 1')
xlabel('Range (\rho) [Earth Radii]')
ylabel('Range Rate (\rho'') [m/s]')
legend()

% Admissible Region T2
norm_h = norm(cross(ISS.r_t2, ISS.v_t2));


% Define Constraints
E_ZERO = 0;
E_SEMI_CONST = -MU_EARTH / (2 * 6738e3);
E_ECC = (-(MU_EARTH^2) * (1 - (0.4^2))) / (2 * norm_h^2);

[rho_0, rho_dot_0] = admissible_region(deg2rad(ra2), deg2rad(dec2), ra2_dot, dec2_dot, O2_ECI, ...
                        O2_DOT_ECI, rho, MU_EARTH, E_ZERO);
[rho_1, rho_dot_1] = admissible_region(deg2rad(ra2), deg2rad(dec2), ra2_dot, dec2_dot, O2_ECI, ...
                        O2_DOT_ECI, rho, MU_EARTH, E_SEMI_CONST);
[rho_2, rho_dot_2] = admissible_region(deg2rad(ra2), deg2rad(dec2), ra2_dot, dec2_dot, O2_ECI, ...
                        O2_DOT_ECI, rho, MU_EARTH, E_ECC);


% Plot Admissible Region  - T2
figure(3)
plot(rho_0./6378e3, rho_dot_0, 'DisplayName', "Zero")
hold on
plot(rho_1./6378e3, rho_dot_1, 'DisplayName', "Semi-Major Axis = 6738km")
plot(rho_2./6378e3, rho_dot_2, "DisplayName", "Eccentricity = 0.4")
hold off
ax = gca;
ax.ColorOrderIndex = 1;
grid on
title('Admissible Regions with SMA and Eccentricity Constraints - Obs 2')
xlabel('Range (\rho) [Earth Radii]')
ylabel('Range Rate (\rho'') [m/s]')
legend()


