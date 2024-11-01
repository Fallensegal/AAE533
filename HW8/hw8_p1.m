% AAE 533 Homework 8
% Author: Wasif Islam
% Date: October 30th, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 1

% Constant Definition
num_samples = 2 * 1e2;

% Object Definitions - Object A
objA.mu = [153446.180;
           41874155.872;
           0;
           3066.875;
           -11.374;
           0];

objA.cov = [
    6494.080, -376.139,      0,      0.0160, -0.494,      0;
    -376.139,   22.560,      0, -9.883e-4,  0.0286,      0;
         0,        0,   1.205,         0,       0, -6.071e-5;
      0.0160, -9.883e-4,      0, 4.437e-8, -1.212e-6,      0;
     -0.494,   0.0286,      0, -1.212e-6,  3.762e-5,      0;
         0,        0, -6.071e-5,      0,      0,  3.390e-9
];

objA.cov = (objA.cov + objA.cov') / 2;
objA.cov = objA.cov + 1e-9 * eye(size(objA.cov));

% Object Definition - Object B
objB.mu = [153446.679;
           41874156.372;
           5.000;
           3066.865;
           -11.364;
           -1.358e-6];

objB.cov = [
    6494.224, -376.156, -4.492e-5,  0.0160, -0.494, -5.902e-8;
   -376.156,   22.561,  2.550e-6, -9.885e-3,  0.0286,  3.419e-9;
   -4.492e-5,  2.550e-6,   1.205, -1.180e-10,  3.419e-9, -6.072e-5;
    0.0160, -9.885e-3, -1.180e-10,  4.438e-8, -1.212e-6, -1.448e-13;
   -0.494,    0.0286,  3.419e-9, -1.212e-6,  3.762e-5,  4.492e-12;
   -5.902e-8,  3.419e-9, -6.072e-5, -1.448e-13,  4.492e-12,  3.392e-9
];

objB.cov = (objA.cov + objA.cov') / 2;
objB.cov = objA.cov + 1e-9 * eye(size(objA.cov));

hardbody_radius_combined = 15;      % Radius in meters

% Generate Samples
objA.state_samples = mvnrnd(objA.mu, objA.cov, num_samples);
objB.state_samples = mvnrnd(objB.mu, objB.cov, num_samples);

% Propagate Orbits
t0 = 0;
tend = 86400;
dt = 5;
tspan = t0:dt:tend;
final_states = zeros(num_samples, 6);
options = odeset('RelTol',1e-9,'AbsTol',1e-12);

parfor i = 1:num_samples
    % Object A
    init_stateA = objA.state_samples(i, :);
    [t1, StateA] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, MU_EARTH), tspan, init_stateA, options);
    positionA(i, :, :) = StateA(:, 1:3);

    % Object B
    init_stateB = objB.state_samples(i, :);
    [t2, StateB] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, MU_EARTH), tspan, init_stateB, options);
    positionB(i, :, :) = StateB(:, 1:3);
end

%% Creating Plots
figure(1);
hold on;
grid on;
axis equal;
title("Object Trajectory w.r.t Earth")
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Z Position (m)');

[X, Y, Z] = sphere(50);
X = X * EARTH_RAD;
Y = Y * EARTH_RAD;
Z = Z * EARTH_RAD;
surf(X, Y, Z, 'FaceColor', 'cyan', 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Earth');

scat_obj_a = scatter3(NaN, NaN, NaN, 5, 'b', 'DisplayName', 'Object A');
scat_obj_b = scatter3(NaN, NaN, NaN, 5, 'r', 'DisplayName', 'Object B');
for i = 1:num_samples
    sample_data_a = reshape(positionA(i, :, :), length(tspan), 3);
    sample_data_b = reshape(positionB(i, :, :), length(tspan), 3);

    % Update Figure
    set(scat_obj_a, 'XData', sample_data_a(:,1), 'YData', sample_data_a(:,2), 'ZData', sample_data_a(:,3))
    set(scat_obj_b, 'XData', sample_data_b(:,1), 'YData', sample_data_b(:,2), 'ZData', sample_data_b(:,3))

end
legend('Location', 'eastoutside')
hold off;

figure(2)
hold on;
grid on;
axis equal;
title("Point Cloud Sample at t=0")
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Z Position (m)');

scat_obj_a = scatter3(NaN, NaN, NaN, 5, 'b', 'DisplayName', 'Object A');
scat_obj_b = scatter3(NaN, NaN, NaN, 5, 'r', 'DisplayName', 'Object B');

% Update Figure
set(scat_obj_a, 'XData', positionA(:,1,1), 'YData', positionA(:,1,2), 'ZData', positionA(:,1,3))
set(scat_obj_b, 'XData', positionB(:,1,1), 'YData', positionB(:,1,2), 'ZData', positionB(:,1,3))
hold off
legend('Location', 'eastoutside')

figure(3)
hold on;
grid on;
axis equal;
title("Point Cloud Sample at t=86400")
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Z Position (m)');

scat_obj_a = scatter3(NaN, NaN, NaN, 5, 'b', 'DisplayName', 'Object A');
scat_obj_b = scatter3(NaN, NaN, NaN, 5, 'r', 'DisplayName', 'Object B');

% Update Figure
set(scat_obj_a, 'XData', positionA(:,end,1), 'YData', positionA(:,end,2), 'ZData', positionA(:,end,3))
set(scat_obj_b, 'XData', positionB(:,end,1), 'YData', positionB(:,end,2), 'ZData', positionB(:,end,3))
hold off
legend('Location', 'eastoutside')
