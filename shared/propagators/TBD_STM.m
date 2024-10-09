% Function: TBD_STM 
% Desc: - Computes the derivatives of the state vector and STM for 2-Body
% Inputs:
%   t - Current time (s)
%   Y - Combined state vector [state; STM] as a 42x1 vector
%
% Outputs:
%   dYdt - Derivatives of the combined state vector as a 42x1 vector
function dYdt = TBD_STM(t, Y)
    % Earth's gravitational parameter (mu) in m^3/s^2
    mu = 398600.4418e9;

    % Extract position and velocity from Y
    r = Y(1:3);      % Position vector [x; y; z] in km
    v = Y(4:6);      % Velocity vector [vx; vy; vz] in km/s

    % Compute the norm of the position vector
    norm_r = norm(r);

    % Compute acceleration due to gravity
    a = -mu / norm_r^3 * r;

    % State derivatives
    drdt = v;        % dx/dt = vx, dy/dt = vy, dz/dt = vz
    dvdt = a;        % dv/dt = acceleration due to gravity

    % Combine state derivatives
    state_derivatives = [drdt; dvdt];

    % Initialize the A matrix (Jacobian of the equations of motion)
    % A is a 6x6 matrix
    A = zeros(6,6);

    % Partial derivatives of acceleration w.r. position
    A(4:6,1:3) = -mu / norm_r^3 * (eye(3) - 3 * (r * r.') / norm_r^2);
    
    % Partial derivatives of acceleration w.r. velocity are zero
    % A(4:6,4:6) remains zero

    % The upper right block of A (partial derivatives of position w.r. velocity)
    A(1:3,4:6) = eye(3);

    % The lower left block of A (partial derivatives of acceleration w.r. position)
    % is already set above

    % The lower right block of A (partial derivatives of acceleration w.r. velocity)
    % is zero and already set

    % Reshape A into a 36x1 vector (column-wise)
    dPhi_dt = A(:);

    % Extract the STM from Y (elements 7 to 42)
    Phi = reshape(Y(7:42), 6, 6);

    % Compute the derivative of Phi
    Phi_derivative = A * Phi;

    % Reshape Phi_derivative into a 36x1 vector
    dPhi_dt = Phi_derivative(:);

    % Combine state derivatives and Phi derivatives
    dYdt = [state_derivatives; dPhi_dt];
end
