% Differential Equation - Kepler Simple 2-Body
% Desc: Differential equation describing the EoM regarding Keplar 2-Body
% with no peturbations.
%
% Inputs:
%   r_state: State vector for position and velocity
%   mu: Standard graviational parameter of central orbiting body
% 
% Outputs:
%   end_state : State vector for velocity and acceleration
%


function [end_state] = simple_kepler_orbit_pde(r_state, mu)
    
    % Define Body State
    position = r_state(1:3, :);
    velocity = r_state(4:6, :);
    
    % Intermediate Quantity - Norm of Position Vector
    position_norm = norm(position);

    % Derivative Sate
    v_dot = (-mu ./ (position_norm^3)) * position;
    p_dot = velocity;

    end_state = [p_dot; v_dot];

    
end
