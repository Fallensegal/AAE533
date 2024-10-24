% PDFunction: STM_2BD_CORR
% Desc: Differential equation solving for both states of orbiting object
% and the state transition matrix
%
% Inputs:
%   t: Propagation Time [sec]
%   xPhi: State stacked on top of reshaped STM
%   mu: [km3/s2] Gravitational Parameter
%
% Outputs:
%   dxPhi: derivative and STM components
%
% Author: Nathan Houtz (2020)

function [dxPhi] = STM_2BD_CORR(t, xPhi, mu)
    dxPhi = zeros(42, 1);

    % State Vectors
    r = xPhi(1:3);          % Position Vector [km]
    v = xPhi(4:6);          % Velocity Vector [km/s]

    % Intermediate Quantities
    r2 = r' * r;            % Magnitude of r^2
    r1 = sqrt(r2);          % Magnitude of r
    r3 = r1 * r2;           % Magnitude of r^3
    
    % Velocity and STM Components
    Phi = reshape(xPhi(7:42), [6,6]);
    dxPhi(1:3) = v;
    dxPhi(4:6) = -mu/(r3) * r;

    % Derivative Statements
    G = mu/(r3*r2) * (3*(r*r') - r2*eye(3));
    F = [zeros(3,3), eye(3,3);
         G, zeros(3,3)];

    dPhi = F * Phi;
    dxPhi(7:42) = dPhi(:);

    % Extract State and STM from xPhi
end

