function [x_t, Phi_t] = HW6_PS(x0, t, stm_function, mu)
    % propagate_state Propagates the state and computes the STM.
    %
    % Inputs:
    %   x0         - Initial state vector [6x1]
    %   t          - Propagation time [seconds]
    %   stm_function - Function handle for STM differential equations
    %   mu         - Gravitational parameter [km^3/s^2]
    %
    % Outputs:
    %   x_t        - Propagated state vector at time t [6x1]
    %   Phi_t      - State Transition Matrix at time t [6x6]
    
    if t == 0
        x_t = x0;
        Phi_t = eye(6);
        return;
    end
    % ODE Solver Options
    options = odeset('RelTol',1e-12,'AbsTol',1e-12);
    
    % Initial Condition: [State; STM as Column Vector]
    Phi0 = eye(6);
    xPhi0 = [x0; Phi0(:)];
    
    % Integrate from 0 to t
    [~, xPhi] = ode45(@(tau, xPhi) stm_function(tau, xPhi, mu), [0 t], xPhi0, options);
    
    % Extract Final State and STM
    x_final = xPhi(end, 1:6)';
    Phi_t = reshape(xPhi(end,7:42), [6,6]);
    
    x_t = x_final;
end
