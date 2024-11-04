% AAE 533 Homework 8
% Author: Wasif Islam
% Date: October 30th, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 2
target_date = datetime(2024, 11, 12, 4, 0, 0);
target_date.TimeZone = 'UTC';
GEO_TLE_STRUCT = read_propagate_3LE('GEO_3LE.txt', target_date);