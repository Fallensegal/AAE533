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