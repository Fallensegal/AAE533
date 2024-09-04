% AAE 533 Homework 1
% Author: Wasif Islam
% Date: Aug 31st, 2024

%% Initialization
tic;
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");
coordinate_data = readtable("new_validation_data.xlsx");



%% Problem 2
%MJD = 57923.66667;
[JD, GMST, LMST] = mjd2sidereal(coordinate_data.Time_MJD_(1), coordinate_data.StationGeodeticLongitude_deg_(1));

% Test
X = coordinate_data.StationXECEF_Km_(1);
Y = coordinate_data.StationYECEF_Km_(1);
Z = coordinate_data.StationZECEF_Km_(1);

R = norm([X, Y, Z]);
R3_Rot = [cos(LMST) -sin(LMST) 0; sin(LMST) cos(LMST) 0; 0 0 1];
RT = [R * cos(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1))) * cos(LMST); ...
      R * cos(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1))) * sin(LMST); ...
      R * sin(deg2rad(coordinate_data.StationGeocentricLatitude_deg_(1)))];

