function verify_az_elev(az, el, phi, tau, delta)
    % Convert degrees to radians
    az_rad = deg2rad(az);
    el_rad = deg2rad(el);
    
    % Adjust azimuth for right-handed system (measured eastward from north)
    az_rad = mod(2*pi - az_rad, 2*pi);
    
    % Verify equations from Image 1, adapted for right-handed system
    eq1_lhs = cos(el_rad) .* sin(az_rad);  % Note: cos(a) becomes sin(a) due to 90° shift
    eq1_rhs = sin(phi) .* cos(delta) .* cos(tau) - cos(phi) .* sin(delta);
    eq1_diff = abs(eq1_lhs - eq1_rhs);
    
    eq2_lhs = cos(el_rad) .* cos(az_rad);  % Note: sin(a) becomes cos(a) due to 90° shift
    eq2_rhs = cos(delta) .* sin(tau);
    eq2_diff = abs(eq2_lhs - eq2_rhs);
    
    eq3_lhs = sin(el_rad);
    eq3_rhs = sin(phi) .* sin(delta) + cos(phi) .* cos(delta) .* cos(tau);
    eq3_diff = abs(eq3_lhs - eq3_rhs);
    
    % Display results
    disp('Verification Results (Right-handed System):');
    disp(['Equation 1 max difference: ', num2str(max(eq1_diff))]);
    disp(['Equation 2 max difference: ', num2str(max(eq2_diff))]);
    disp(['Equation 3 max difference: ', num2str(max(eq3_diff))]);
    
    % Set a tolerance for floating-point comparisons
    tol = 1e-6;
    
    if all(eq1_diff < tol) && all(eq2_diff < tol) && all(eq3_diff < tol)
        disp('Verification PASSED: Azimuth and Elevation are correct within tolerance.');
    else
        disp('Verification FAILED: Azimuth and Elevation do not satisfy the equations.');
        % Optionally, you can add more detailed error reporting here
    end
end