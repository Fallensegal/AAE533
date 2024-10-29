% AAE 533 Homework 7
% Author: Wasif Islam
% Date: October 25th, 2024

%% Initialization
clear;
clc;

% Import Necessary Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem One

% Acquire Initial Conditions from Last Homework

% Defined Constants
ISS_PERIOD = 5400;      % Period [s]
start_epoch = datetime('2024-10-18T12:00:00.000');

% Gravitational Parameters
mu.earth = MU_EARTH;
mu.moon = 4.9028695e12;
mu.sun = 1.327e20;

% SRP Parameters
srp.area = 5500;                % Solar Radiation Area [m^2]
srp.mass = 419725;              % Mass [kg]
srp.C = ((1/4) + (1/9)*1.4);    % Reflectivity Constant

% Drag Parameters
drag.rho = 2.72e-12;             % Atmospheric Density [kg/m3]
drag.area = 1702.82;             % Drag Affected Area [m^2]
drag.mass = 419725;              % Mass [kg]

% ISS Initial State
iss_state = [1206.536023117490; 6341.948632667270; 2103.445062025980; ...
    -5.24121309257951; -0.85217709490634; 5.53106828735412] * 1e3;
tspan = [0, 10*ISS_PERIOD];
options = odeset('RelTol',1e-12,'AbsTol',1e-12);

% Perform Integration
[tx, Y] = ode45(@(t, r_state) Kepler_Peturbations(t, r_state, mu, srp, drag, start_epoch), ...
                                                 tspan, iss_state, options);
[tx1, Y1] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, mu.earth), tspan, iss_state, options);
[tx2, Y2] = ode45(@(t, r_state) FULL_ORBITAL_MODEL(t, r_state, mu, srp, drag, start_epoch), ...
                                                 tspan, iss_state, options);

% Plot The ISS
figure(1)
earth_radius = 6378e3;        % DIM: [m]
[x_earth, y_earth, z_earth] = sphere;
x_earth = x_earth * earth_radius;
y_earth = y_earth * earth_radius;
z_earth = z_earth * earth_radius;
surf(x_earth, y_earth, z_earth, 'FaceColor', 'k', 'DisplayName', 'Earth');
axis equal;
hold on
plot3(Y(:,1), Y(:,2), Y(:,3), 'DisplayName', 'With Perturbations')
plot3(Y1(:,1), Y1(:,2), Y1(:,3), 'DisplayName', 'Without Perturbations')
plot3(Y2(:,1), Y2(:,2), Y2(:,3), 'DisplayName', 'J2 With Perturbations')
hold off
title("ISS Orbit with Perturbations: Wasif Islam")
xlabel("R1 [meters]");
ylabel("R2 [meters]");
zlabel("R3 [meters]");
grid("on");
legend()

% Visualize Diff

figure(2)
subplot(3,1,1)
plot(tx, Y(:,1), 'DisplayName', "Point-Mass Perturbed")
hold on
plot(tx1, Y1(:,1), 'DisplayName', "Point-Mass Unperturbed")
plot(tx2, Y2(:,1), 'DisplayName', "Gravity-Field Perturbed")
hold off
title("Position Vector X vs. Time")
xlabel("Time [sec]")
ylabel("R_{x} [meters]")
grid("on")
legend('Location', 'eastoutside')

subplot(3,1,2)
plot(tx, Y(:,2), 'DisplayName', "Point-Mass Perturbed")
hold on
plot(tx1, Y1(:,2), 'DisplayName', "Point-Mass Unperturbed")
plot(tx2, Y2(:,2), 'DisplayName', "Gravity-Field Perturbed")
hold off
title("Position Vector Y vs. Time")
xlabel("Time [sec]")
ylabel("R_{y} [meters]")
grid("on")
legend('Location', 'eastoutside')

subplot(3,1,3)
plot(tx, Y(:,3), 'DisplayName', "Point-Mass Perturbed")
hold on
plot(tx1, Y1(:,3), 'DisplayName', "Point-Mass Unperturbed")
plot(tx2, Y2(:,3), 'DisplayName', "Gravity-Field Perturbed")
hold off
title("Position Vector Z vs. Time")
xlabel("Time [sec]")
ylabel("R_{z} [meters]")
grid("on")
legend('Location', 'eastoutside')