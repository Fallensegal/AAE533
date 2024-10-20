% Differential Equation - Kepler N-Body with Drag and SRP
% Desc: Differential equation describing the EoM of satellite orbiting
% Earth
%
% Inputs:
%   mu: 
%
% Outputs:
%
%

function [dxdt] = Kepler_Peturbations(t, r_state, mu, srp, drag, start_epoch)
    % Constants
    EARTH_RAD = 6378e3;     % Earth Radius [m]
    AU = 1.496e11;          % Astronomical Unit [m]
    E = 1367;               % Solar Flux [W/m^2]
    c = 299792458;          % Speed of Light [m/s]
    OMEGA = 7.29e-5;        % Rotation Rate of Earth [rad/s]

    % Define Body State
    position = r_state(1:3, :);
    velocity = r_state(4:6, :);
    current_epoch = start_epoch + seconds(t);
    JD = juliandate(current_epoch);

    % Intermediate Quantity - Norm of Position Vector
    position_norm = norm(position);

    % Calculate Third-Body Perturbations
    moon_r = EARTH_RAD .* moon(JD)';
    sun_r = AU .* sun(JD)';

    a_moon = -mu.moon .* (((position - moon_r) ...
        / (norm(position - moon_r))^3) + (moon_r / (norm(moon_r)^3)));

    a_sun = -mu.sun .* (((position - sun_r) ...
        / (norm(position - sun_r))^3) + (sun_r / (norm(sun_r)^3)));

    % Calculate SRP
    SH = (position - sun_r) ./ norm(position - sun_r); 
    a_srp = -(srp.area / srp.mass) * (E / c) * (AU^2 / (norm(position - sun_r)^2)) ...
                .* (srp.C .* SH);

    % Calculate Drag
    v_prime = velocity - cross([0; 0; OMEGA], position);
    vp_unit = v_prime / norm(v_prime);
    a_drag = -drag.rho * (drag.area / drag.mass) * norm(v_prime)^2 .* vp_unit; 

    % Peturbed Acceleration Components
    a_peturbed = a_sun + a_moon + a_srp + a_drag;

    % Derivative Sate
    v_dot = ((-mu.earth ./ (position_norm^3)) * position) + a_peturbed;
    p_dot = velocity;

    dxdt = [p_dot; v_dot];
end

