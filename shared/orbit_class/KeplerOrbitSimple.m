classdef KeplerOrbitSimple
    % Orbit Class - Kepler Simple 2-Body
    % Desc: This class is a definition for holding orbital parameters, orbit generation parameters,
    % and associated methods in order to succintly organize orbit generation and its outputs.

    properties
        % Keplerian Orbital Elements
        semi_major_axis = 0.0;             % [DIM: m]
        inclination = 0.0                  % [DIM: deg]     
        RAAN = 0.0                         % [DIM: deg]
        true_anomaly = 0.0                 % [DIM: deg]
        argument_of_perigee = 0.0          % [DIM: deg]
        eccentricity = 0.0                 % [DIM: N/A]

        % Propagation Properties
        mu = 0.0                           % [DIM: m^3/s^2]
        orbit_period            double     % [DIM: sec]
        dt                      double     % [DIM: sec]
        t0                      double     % [DIM: sec]
        tend                    double     % [DIM: sec]
        x0              (6,1)   double     % [DIM: (:3, 1) m, (3:6, 1) m/s] - CARTESIAN COORDS

        % Generated Orbit Properties
        xn                      double     % [DIM: (:3, 1) m, (3:6, 1) m/s]
        tn                      double     % [DIM: sec]
      
    end
    methods

        % Class Construction Method
        % Desc: Method defined to instantiate the object with initial properties
        % Inputs:
        %   sma: semi-major axis    [m]
        %   inc: inclination        [deg]
        %   raan: Right Ascension of Ascending Node     [deg]
        %   t_anomaly: True Anomaly                     [deg]
        %   arg_perigee: Argument of Perigee            [deg]
        %   ecc: Eccentricity                           [nil]
        %
        % Outputs:
        %   obj: Instance of KeplerOrbitSimple class with keplerian orbital elements initialized
        %

        function obj = KeplerOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc, mu)
            if nargin > 0
                obj.semi_major_axis = sma;
                obj.inclination = inc;
                obj.RAAN = raan;
                obj.true_anomaly = t_anomaly;
                obj.argument_of_perigee = arg_perigee;
                obj.eccentricity = ecc;
                obj.mu = mu;
            end
        end

        % Orbit Propagation Method
        % Desc: Method for propagating orbit based on class defined parameters
        % Inputs:
        %   orbit_object: The KeplerOrbitSimple that contain parameters used to generate orbit
        % 
        % Outputs:
        %   [tx, xn]: The time and state vector of numerical integration of equation of motion 
        %   [sec, (:,:3) m, (:,3:6) m/s] -> Dimensions of Outputs
        %

        function [tn, xn] = propagate_simple_kepler(orbit_object)

            % Set numerical integrator options
            options = odeset('Reltol', 1E-12, 'AbsTol', 1E-12, 'InitialStep', orbit_object.dt, 'MaxStep', orbit_object.dt);

            % Generate orbit
            [tn, xn] = ode45(@(t, r_state) simple_kepler_orbit_pde(r_state, orbit_object.mu), [orbit_object.t0, orbit_object.tend], orbit_object.x0, options);
        end

    end
end