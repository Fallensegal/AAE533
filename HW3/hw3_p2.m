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
ISS_OBS_1.t1 = datetime('2024-09-18T15:07:01.900');
ISS_OBS_1.t2 = datetime('2024-09-18T15:11:01.900');
ISS_OBS_1.t3 = datetime('2024-09-18T15:15:01.900');

% X, Y, Z in Km - Obs 2
ISS_OBS_2.obs_t1 = [3602.807338947890; -2578.956715773420; 5146.335993511110]; 
ISS_OBS_2.obs_t2 = [4819.675844045330; -1320.910653608590; 4601.454936466590];
ISS_OBS_2.obs_t3 = [5686.365561077790; 33.107790076274; 3721.296031977380];
ISS_OBS_2.t1 = datetime('2024-09-18T17:19:01.900');
ISS_OBS_2.t2 = datetime('2024-09-18T17:23:01.900');
ISS_OBS_2.t3 = datetime('2024-09-18T17:27:01.900');

% Change MU Constants to be in Km
MU_EARTH = MU_EARTH * 1e-9;

% Change Elevation Units
Purdue.STATION_ALT = Purdue.STATION_ALT * 1e-3;

% Generate IOD - RA, Dec Observation

% Generate IOD - Range Observation


