function [rho_out,rho_dot, dr_obj, r_obj] = admissible_region(ra, dec, ra_dot, dec_dot, R, R_dot, rho, mu, E0)
    % Compute Unit Vectors
    u_rho = [cos(ra) * cos(dec);
             sin(ra) * cos(dec);
             sin(dec)];

    u_alpha = [-sin(ra) * cos(dec);
                cos(ra) * cos(dec);
                0];

    u_delta = [-cos(ra) * sin(dec);
               -sin(ra) * sin(dec);
               cos(dec)];

    % Compute Coefficients
    w0 = sum(R .* R, 1)';
    w1 = 2 * (R_dot' * u_rho);
    w2 = ra_dot^2 * cos(dec)^2 + dec_dot^2;
    w3 = 2 * ra_dot * (R_dot' * u_alpha) + 2 * dec_dot * (R_dot' * u_delta);
    w4 = sum(R_dot .* R_dot, 1)';
    w5 = 2 * (R' * u_rho);

    % Compute the F Function
    F = w2 * rho.^2 + w3 * rho + w4 - 2 * mu ./ sqrt(rho.^2 + w5 * rho + w0);

    % Solve for Derivative of Rho
    rad = sqrt((w1 / 2)^2 - F + 2 * E0);
    valid_rho = real(rad) > 0;

    rho = rho(valid_rho);
    rho = [rho, fliplr(rho)];
    rad = rad(valid_rho);

    % Calculate Derivative
    rho_dot = [-w1/2+rad, fliplr(-w1/2-rad)];
    rho_out = rho;

    % Calculate Positions
    drho_vecs = u_rho * rho_dot + u_alpha * ra_dot * rho + u_delta ...
                        * dec_dot * rho;
    dr_obj = repmat(R_dot, 1, numel(rho)) + drho_vecs;
    r_obj = repmat(R, 1, numel(rho)) + u_rho * rho;

    vx = dr_obj(1, :)';
    vy = dr_obj(2, :)';
    vz = dr_obj(3, :)';

    dr_obj = [vx, vy, vz];

    x = r_obj(1, :)';
    y = r_obj(2, :)';
    z = r_obj(3, :)';

    r_obj = [x, y, z];

end

