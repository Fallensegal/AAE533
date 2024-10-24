% AAE 533 Homework 6
% Author: Wasif Islam
% Date: Oct 17th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 1

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

% Plot The ISS
figure(1)
earth_radius = 6378e3;        % DIM: [m]
[x_earth, y_earth, z_earth] = sphere;
x_earth = x_earth * earth_radius;
y_earth = y_earth * earth_radius;
z_earth = z_earth * earth_radius;
surf(x_earth, y_earth, z_earth, 'FaceColor', 'k');
axis equal;
hold on
plot3(Y(:,1), Y(:,2), Y(:,3), 'DisplayName', 'With Perturbations')
plot3(Y1(:,1), Y1(:,2), Y1(:,3), 'DisplayName', 'Without Perturbations')
hold off
title("ISS Orbit with Perturbations: Wasif Islam")
xlabel("R1 [meters]");
ylabel("R2 [meters]");
zlabel("R3 [meters]");
grid("on");
legend()

% Position Difference between 2-body and Perturbed
position_diff = [Y(:,1) Y(:,2) Y(:,3)] - [Y1(:,1) Y1(:,2) Y1(:,3)];
diff_norm = vecnorm(position_diff, 2, 2);

figure(2)
plot(tx(1:26500), diff_norm(1:26500))
title("L_{2} Norm Difference between Perturbed and Non-Perturbed ISS State")
xlabel("Time [sec]")
ylabel("|X_{Perturbed} - X_{2-Body}|")
grid("on")

% Natural De-Orbit
scaled_height = 58.2 * 1e3;       % Scaled Atmosphere Height [km]
SMA = 6738e3;                     % Semi-major Axis
ALT = SMA - EARTH_RAD;

iter_sma = SMA;
iter_rho = drag.rho;
orbits = 0;
while ALT > 0
    if ALT > 350
        iter_rho = 6.98e-12;
    elseif ALT > 300
        iter_rho = 1.95e-11;
    elseif ALT > 250
        iter_rho = 6.24e-11;
    elseif ALT > 200
        iter_rho = 2.53e-10;
    elseif ALT > 150
        iter_rho = 1.61e-9;
    elseif ALT > 100
        iter_rho = 4.79e-7;
    elseif ALT > 0
        iter_rho = 1.2;
    end

    da = -2*pi*((2 * drag.area) / drag.mass)*iter_rho*(iter_sma^2);
    iter_sma = iter_sma - da;
    ALT = ALT + da;
    orbits = orbits + 1;
end

delta_a = -2*pi*((2 * drag.area) / drag.mass)*drag.rho*(SMA^2);
L = -scaled_height / delta_a;


