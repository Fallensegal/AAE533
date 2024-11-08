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
LEO_TLE_STRUCT = read_propagate_3LE('LEO_3LE.txt', target_date);
MEO_TLE_STRUCT = read_propagate_3LE('MEO_3LE.txt', target_date);

%% Plot GEO, MEO, LEO
LEO_KEYS = keys(LEO_TLE_STRUCT);
N_LEO = length(LEO_KEYS);

GEO_KEYS = keys(GEO_TLE_STRUCT);
N_GEO = length(GEO_KEYS);

MEO_KEYS = keys(MEO_TLE_STRUCT);
N_MEO = length(MEO_KEYS);

% Initialize empty arrays for GEO, LEO, MEO
geo_X = [];
geo_Y = [];
geo_Z = [];

meo_X = [];
meo_Y = [];
meo_Z = [];

leo_X = [];
leo_Y = [];
leo_Z = [];

for i = 1:N_GEO
    sample_geo = GEO_KEYS{i};  % Correct indexing
    sample_r_cell = GEO_TLE_STRUCT(sample_geo);
    sample_r = sample_r_cell{1};  % Assuming sample_r is a 3x1 vector
    
    geo_X(i) = sample_r(1);
    geo_Y(i) = sample_r(2);
    geo_Z(i) = sample_r(3);
end

%% Accumulate MEO Positions
for i = 1:N_MEO
    sample_meo = MEO_KEYS{i};
    sample_r_cell = MEO_TLE_STRUCT(sample_meo);
    sample_r = sample_r_cell{1};
    
    meo_X(i) = sample_r(1);
    meo_Y(i) = sample_r(2);
    meo_Z(i) = sample_r(3);
end

%% Accumulate LEO Positions
for i = 1:N_LEO
    sample_leo = LEO_KEYS{i};
    sample_r_cell = LEO_TLE_STRUCT(sample_leo);
    sample_r = sample_r_cell{1};
    
    leo_X(i) = sample_r(1);
    leo_Y(i) = sample_r(2);
    leo_Z(i) = sample_r(3);
end

% Found some positions for LEO that ran into numerical runaway. Removing
% them here

threshold = 1e5;
remove_indecies = find((leo_X > threshold) | (leo_X < -threshold));
leo_X(remove_indecies) = [];
leo_Y(remove_indecies) = [];
leo_Z(remove_indecies) = [];

%% Plot Earth
figure(1)
hold on;
axis equal;
grid on;
title("TLE Object Position w.r.t Earth")
xlabel('X Position (km)');
ylabel('Y Position (km)');
zlabel('Z Position (km)');

[X, Y, Z] = sphere(50);
X = X * (EARTH_RAD * 1e-3);
Y = Y * (EARTH_RAD * 1e-3);
Z = Z * (EARTH_RAD * 1e-3);
surf(X, Y, Z, 'FaceColor', 'black', 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Earth');


%% Plot GEO, MEO, LEO Satellites
scatter3(geo_X, geo_Y, geo_Z, 3, 'm', 'DisplayName', 'GEO');
scatter3(meo_X, meo_Y, meo_Z, 3, 'r', 'DisplayName', 'MEO');
scatter3(leo_X, leo_Y, leo_Z, 3, 'b', 'DisplayName', 'LEO');
legend('Location', 'eastoutside')
hold off;

% GPS and StarLink
starKeys = {}; 
gpsKeys = {}; 

% Loop through each key and check if it contains "starlink"
for i = 1:N_LEO
    key = LEO_KEYS{i};
    if contains(key, 'starlink', 'IgnoreCase', true) % Check if "starlink" is in the key
        starKeys{end + 1} = key; % Add key to the list
    end
end

for i = 1:N_MEO
    key = MEO_KEYS{i};
    if contains(key, 'navstar', 'IgnoreCase', true)
        gpsKeys{end + 1} = key;
    end
end

N_STARKEY = length(starKeys);
N_GPSKEY = length(gpsKeys);

% Initialize empty arrays for Starlink
star_X = [];
star_Y = [];
star_Z = [];

% Similarly, initialize GPS
gps_X = [];
gps_Y = [];
gps_Z = [];

%% Accumulate Starlink Positions
for i = 1:N_STARKEY
    sample_leo = starKeys{i};
    sample_r_cell = LEO_TLE_STRUCT(sample_leo);
    sample_r = sample_r_cell{1};
    
    star_X(i) = sample_r(1);
    star_Y(i) = sample_r(2);
    star_Z(i) = sample_r(3);
end

%% Accumulate GPS Positions
for i = 1:N_GPSKEY
    sample_leo = gpsKeys{i};
    sample_r_cell = MEO_TLE_STRUCT(sample_leo);
    sample_r = sample_r_cell{1};
    
    gps_X(i) = sample_r(1);
    gps_Y(i) = sample_r(2);
    gps_Z(i) = sample_r(3);
end

% Plot GPS
figure(2)
hold on;
axis equal;
grid on;
title("GPS Objects w.r.t Earth")
xlabel('X Position (km)');
ylabel('Y Position (km)');
zlabel('Z Position (km)');

[X, Y, Z] = sphere(50);
X = X * (EARTH_RAD * 1e-3);
Y = Y * (EARTH_RAD * 1e-3);
Z = Z * (EARTH_RAD * 1e-3);
surf(X, Y, Z, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Earth');
scatter3(gps_X, gps_Y, gps_Z, 15, 'm')

remove_indecies = find((star_X > threshold) | (star_X < -threshold));
star_X(remove_indecies) = [];
star_Y(remove_indecies) = [];
star_Z(remove_indecies) = [];

% Plot Starlink
figure(3)
hold on;
axis equal;
grid on;
title("StarLink w.r.t Earth")
xlabel('X Position (km)');
ylabel('Y Position (km)');
zlabel('Z Position (km)');

[X, Y, Z] = sphere(50);
X = X * (EARTH_RAD * 1e-3);
Y = Y * (EARTH_RAD * 1e-3);
Z = Z * (EARTH_RAD * 1e-3);
surf(X, Y, Z, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Earth');
scatter3(star_X, star_Y, star_Z, 8, 'r')
