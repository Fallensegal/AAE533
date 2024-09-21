% AAE 533 Homework 3
% Author: Wasif Islam
% Date: Sep 19th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

% Initialize Problem Variables - J2000

% X, Y, Z in Km - Obs 1
ISS_OBS_1.obs_t1 = [-5558.082269000000; 176.170673000000; -3909.745697000000];
ISS_OBS_1.obs_t2 = [-6077.020846075970; -1187.526562175400; -2801.059165642000];
ISS_OBS_1.obs_t3 = [-6154.069043656380; -2464.846712251270; -1488.14264248893];
ISS_OBS_1.v2 = [-1.25746818075924; -5.56989208874611; 5.10696813683801];
ISS_OBS_1.t1 = datetime('2024-09-18T15:07:01.900');
ISS_OBS_1.t2 = datetime('2024-09-18T15:11:01.900');
ISS_OBS_1.t3 = datetime('2024-09-18T15:15:01.900');

% X, Y, Z in Km - Obs 2
ISS_OBS_2.obs_t1 = [-5936.711093571230; -3294.639088057420; -216.673358957611]; 
ISS_OBS_2.obs_t2 = [-5210.246686742630; -4183.505595818840; 1214.134853256750];
ISS_OBS_2.obs_t3 = [-4103.785845413550; -4767.250417725080; 2556.134001207910];
ISS_OBS_2.v2 = [3.86564448499101; -3.10582295923938; 5.84815562473533];
ISS_OBS_2.t1 = datetime('2024-09-18T23:03:01.900');
ISS_OBS_2.t2 = datetime('2024-09-18T23:07:01.900');
ISS_OBS_2.t3 = datetime('2024-09-18T23:11:01.900');

% Change MU Constants to be in Km
MU_EARTH = MU_EARTH * 1e-9;

% Change Elevation Units
STAT_ECEF = GDLL2ECEF(Purdue.GD_LAT, Purdue.GD_LONG, Purdue.STATION_ALT) * 1e-3;

% Topcenter ECI - OBS 1
O1_R1 = ecef2eci(ISS_OBS_1.t1, STAT_ECEF);
O1_R2 = ecef2eci(ISS_OBS_1.t2, STAT_ECEF);
O1_R3 = ecef2eci(ISS_OBS_1.t3, STAT_ECEF);

% Topocenter ECI - OBS 2
O2_R1 = ecef2eci(ISS_OBS_2.t1, STAT_ECEF);
O2_R2 = ecef2eci(ISS_OBS_2.t2, STAT_ECEF);
O2_R3 = ecef2eci(ISS_OBS_2.t3, STAT_ECEF);

% Generate IOD - RA, Dec Observation

% OBS 1
[ra1_1, dec1_1] = ECI2DEC_RA(ISS_OBS_1.obs_t1, O1_R1);
[ra1_2, dec1_2] = ECI2DEC_RA(ISS_OBS_1.obs_t2, O1_R2);
[ra1_3, dec1_3] = ECI2DEC_RA(ISS_OBS_1.obs_t3, O1_R3);

% OBS 2
[ra2_1, dec2_1] = ECI2DEC_RA(ISS_OBS_2.obs_t1, O2_R1);
[ra2_2, dec2_2] = ECI2DEC_RA(ISS_OBS_2.obs_t2, O2_R2);
[ra2_3, dec2_3] = ECI2DEC_RA(ISS_OBS_2.obs_t3, O2_R3);

% Assign Result to Observation Struct
obs_ra1.o1.RA = ra1_1;
obs_ra1.o2.RA = ra1_2;
obs_ra1.o3.RA = ra1_3;

obs_ra1.o1.DEC = dec1_1;
obs_ra1.o2.DEC = dec1_2;
obs_ra1.o3.DEC = dec1_3;

obs_ra2.o1.RA = ra2_1;
obs_ra2.o2.RA = ra2_2;
obs_ra2.o3.RA = ra2_3;

obs_ra2.o1.DEC = dec2_1;
obs_ra2.o2.DEC = dec2_2;
obs_ra2.o3.DEC = dec2_3;

[r2_obs1_gauss, v2_obs1_gauss] = gauss_v2_iod(obs_ra1.o1, obs_ra1.o2, obs_ra1.o3, ...
    ISS_OBS_1.t1, ISS_OBS_1.t2, ISS_OBS_1.t3, STAT_ECEF, MU_EARTH);

[r2_obs2_gauss, v2_obs2_gauss] = gauss_v2_iod(obs_ra2.o1, obs_ra2.o2, obs_ra2.o3, ...
    ISS_OBS_2.t1, ISS_OBS_2.t2, ISS_OBS_2.t3, STAT_ECEF, MU_EARTH);

% Generate IOD - Range Observation
v2_obs1_gibbs = gibbs_v2_iod(ISS_OBS_1.obs_t1, ISS_OBS_1.obs_t2, ISS_OBS_1.obs_t3, MU_EARTH);
v2_obs2_gibbs = gibbs_v2_iod(ISS_OBS_2.obs_t1, ISS_OBS_2.obs_t2, ISS_OBS_2.obs_t3, MU_EARTH);

% Generate Orbit from Original RV2 - OBS1
orb_o1_orig = KeplerOrbitSimple();
orb_o1_orig.mu = MU_EARTH;
orb_o1_orig.t0 = 0.0;
orb_o1_orig.tend = 86400;
orb_o1_orig.dt = 15.0;
orb_o1_orig.x0 = [ISS_OBS_1.obs_t2; ISS_OBS_1.v2];
[tx_o1_orig, xn_o1_orig] = orb_o1_orig.propagate_simple_kepler();

% Generate Orbit from Original RV2 - OBS2
orb_o2_orig = KeplerOrbitSimple();
orb_o2_orig.mu = MU_EARTH;
orb_o2_orig.t0 = 0.0;
orb_o2_orig.tend = 86400;
orb_o2_orig.dt = 15.0;
orb_o2_orig.x0 = [ISS_OBS_2.obs_t2; ISS_OBS_2.v2];
[tx_o2_orig, xn_o2_orig] = orb_o1_orig.propagate_simple_kepler();

% Generate Orbit from IOD RV2 - Optical - OBS1
orb_o1_gauss = KeplerOrbitSimple();
orb_o1_gauss.mu = MU_EARTH;
orb_o1_gauss.t0 = 0.0;
orb_o1_gauss.tend = 86400;
orb_o1_gauss.dt = 15.0;
orb_o1_gauss.x0 = [r2_obs1_gauss; v2_obs1_gauss];
[tx_o1_gauss, xn_o1_gauss] = orb_o1_gauss.propagate_simple_kepler();

% Generate Orbit from IOD RV2 - Optical - OBS2
orb_o2_gauss = KeplerOrbitSimple();
orb_o2_gauss.mu = MU_EARTH;
orb_o2_gauss.t0 = 0.0;
orb_o2_gauss.tend = 86400;
orb_o2_gauss.dt = 15.0;
orb_o2_gauss.x0 = [r2_obs2_gauss; v2_obs2_gauss];
[tx_o2_gauss, xn_o2_gauss] = orb_o2_gauss.propagate_simple_kepler();

% Generate Orbit from IOD RV2 - Range - OBS1
orb_o1_gibbs = KeplerOrbitSimple();
orb_o1_gibbs.mu = MU_EARTH;
orb_o1_gibbs.t0 = 0.0;
orb_o1_gibbs.tend = 86400;
orb_o1_gibbs.dt = 15.0;
orb_o1_gibbs.x0 = [ISS_OBS_1.obs_t2; v2_obs1_gibbs];
[tx_o1_gibbs, xn_o1_gibbs] = orb_o1_gibbs.propagate_simple_kepler();

% Generate Orbit from IOD RV2 - Range - OBS2
orb_o2_gibbs = KeplerOrbitSimple();
orb_o2_gibbs.mu = MU_EARTH;
orb_o2_gibbs.t0 = 0.0;
orb_o2_gibbs.tend = 86400;
orb_o2_gibbs.dt = 15.0;
orb_o2_gibbs.x0 = [ISS_OBS_2.obs_t2; v2_obs2_gibbs];
[tx_o2_gibbs, xn_o2_gibbs] = orb_o2_gibbs.propagate_simple_kepler();

% Plot Results

% Plot Spherical (Representing Earth)
earth_radius = 6378;        % DIM: [km]
[x_earth, y_earth, z_earth] = sphere;
x_earth = x_earth * earth_radius;
y_earth = y_earth * earth_radius;
z_earth = z_earth * earth_radius;

figure(1)
plot3(xn_o1_orig(:,1), xn_o1_orig(:,2), xn_o1_orig(:,3), 'DisplayName', 'Original')
hold on
plot3(xn_o1_gauss(:,1), xn_o1_gauss(:,2), xn_o1_gauss(:,3), 'DisplayName', 'Gauss')
plot3(xn_o1_gibbs(:,1), xn_o1_gibbs(:,2), xn_o1_gibbs(:,3), 'DisplayName', 'Gibbs')
surf(x_earth, y_earth, z_earth, 'FaceColor', 'k', 'DisplayName', 'Earth');
axis equal;
hold off
grid on
legend()
title("Observation 1: Original vs. Gibbs vs Gauss")
xlabel("R1 [km]")
ylabel("R2 [km]")
zlabel("R3 [km]")

figure(2)
plot3(xn_o2_orig(:,1), xn_o2_orig(:,2), xn_o2_orig(:,3), 'DisplayName', 'Original')
hold on
plot3(xn_o2_gauss(:,1), xn_o2_gauss(:,2), xn_o2_gauss(:,3), 'DisplayName', 'Gauss')
plot3(xn_o2_gibbs(:,1), xn_o2_gibbs(:,2), xn_o2_gibbs(:,3), 'DisplayName', 'Gibbs')
surf(x_earth, y_earth, z_earth, 'FaceColor', 'k', 'DisplayName', 'Earth');
axis equal;
hold off
grid on
legend()
title("Observation 2: Original vs. Gibbs vs Gauss")
xlabel("R1 [km]")
ylabel("R2 [km]")
zlabel("R3 [km]")


