% ODE: pateraInt
% Desc: Integral Function for calculating cumulative probability of
% collision
%
% Inputs:
%   alpha: Transformation matrix to diagonalize P
%   rho: Hardbody Radius
%   F: Integral Constant
%   sig: Standard deviation of Object A position
%
%   NOTE: Function Acquired from Professor Freuh's Script

function [ q ] = pateraInt(theta, alpha, rho, F, sig, R)
    % precompute trig functions
    ct = cos(theta);
    st = sin(theta);
    ca = cos(alpha);
    sa = sin(alpha);
    % Compute r2
    %r2 = (R + (rho * ct))^2 * (ca^2+F^2 * sa^2) + rho^2 * st^2 * ...
    %(sa^2+F^2 * ca^2) + 2 * rho * (1 - F^2) * ca * sa * st * (R + rho * ct);
    r2 = (R + rho * ct).^2 .* (ca.^2 + F.^2 .* sa.^2) + rho.^2 .* st.^2 .* ... 
        (sa.^2 + F.^2 .* ca.^2) + 2 * rho .* (1 - F.^2) .* ca .* sa .* st .* (R + rho * ct);

    % Output the argument of integral at angle theta
    q = 1 / (2 * pi) * (F * rho^2+R * F * rho * ct) / r2 * (1 - exp(-r2 / (2 * sig^2)));
end