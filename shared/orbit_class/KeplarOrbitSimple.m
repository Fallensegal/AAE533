classdef KeplarOrbitSimple
    properties
        % Keplerian Orbital Elements
        semi_major_axis         double     % [DIM: m]
        inclination             double     % [DIM: deg]     
        RAAN                    double     % [DIM: deg]
        true_anomaly            double     % [DIM: deg]
        argument_of_perigee     double     % [DIM: deg]
        eccentricity            double     % [DIM: N/A]

        % Propagation Properties
        orbit_period            double     % [DIM: sec]
        dt                      double     % [DIM: sec]
        t0                      double     % [DIM: sec]
        tend                    double     % [DIM: sec]
        x0              (1,6)   double     % [DIM: (1,:3) m, (1,3:6) m/s] - CARTESIAN COORDS
    end
    methods

        % Class Construction Function
        function obj = KeplarOrbitSimple(sma, inc, raan, t_anomaly, arg_perigee, ecc)
            obj.semi_major_axis = sma;
            obj.inclination = inc;
            obj.RAAN = raan;
            obj.true_anomaly = t_anomaly;
            obj.argument_of_perigee = arg_perigee;
            obj.eccentricity = ecc;
        end

        function [tn, xn] = propagate_simple_keplar(orbit_object)

            % Set numerical integrator options
            options = odeset('Reltol', 1E-12, 'AbsTol', 1E-12, 'InitialStep', orbit_object.dt, 'MaxStep', orbit_object.dt);

            % Generate orbit
            [tn, xn] = ode45('simple_kepler_orbit_pde', [orbit_object.t0, orbit_object.tend], orbit_object.x0, options);
        end

    end
end