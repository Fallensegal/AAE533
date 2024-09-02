% 
function [cart_state_vector] = kepler_to_eci_cartesian(sma, inc, raan, t_anom, arg_perigee, ecc, MU_EARTH)

    % Initialize Varibles
    orbital_parameter = sma * (1 - (ecc ^ 2));
    t_anom = deg2rad(t_anom);
    raan = deg2rad(raan);
    inc = deg2rad(inc);
    arg_perigee = deg2rad(arg_perigee);

    % Define Perifocal State
    r_perifocal = [((orbital_parameter * cos(t_anom)) / (1 + (ecc * cos(t_anom)))); ...
        ((orbital_parameter * sin(t_anom)) / (1 + (ecc * cos(t_anom)))); 0];
    
    v_perifocal = (sqrt(MU_EARTH / orbital_parameter)) * [(-1 * sin(t_anom)); ...
    (ecc + cos(t_anom)); 0];

    % Define Rotation Matrices
    r3_raan = [cos(-raan), sin(-raan), 0; -1 * sin(-raan), cos(-raan), 0; 0, 0, 1];
    r1_inc = [1, 0, 0; 0, cos(-inc), sin(-inc); 0, -1 * sin(-inc), cos(-inc)];
    r3_arg_perigee = [cos(-arg_perigee), sin(-arg_perigee), 0; ...
    -1 * sin(-arg_perigee), cos(-arg_perigee), 0; 0, 0, 1];

    % Calculate Cartesian State Vector
    r_cart = (r3_raan * r1_inc * r3_arg_perigee) * r_perifocal;
    v_cart = (r3_raan * r1_inc * r3_arg_perigee) * v_perifocal;

    cart_state_vector = [r_cart(1); r_cart(2); r_cart(3); v_cart(1); v_cart(2); v_cart(3)];

end