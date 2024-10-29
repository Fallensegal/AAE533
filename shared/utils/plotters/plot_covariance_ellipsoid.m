function plot_covariance_ellipsoid(mu, P, n_std)
    % mu: mean vector [6x1]
    % P: covariance matrix [6x6]
    % n_std: number of standard deviations
    
    % For position covariance
    pos_mu = mu(1:3);
    pos_P = P(1:3, 1:3);
    
    [V, D] = eig(pos_P);
    radii = n_std * sqrt(diag(D));
    
    [x, y, z] = ellipsoid(0, 0, 0, radii(1), radii(2), radii(3), 50);
    ellipsoid_points = V * [x(:)'; y(:)'; z(:)'];
    
    figure;
    plot3(ellipsoid_points(1,:) + pos_mu(1), ...
          ellipsoid_points(2,:) + pos_mu(2), ...
          ellipsoid_points(3,:) + pos_mu(3), 'r');
    hold on;
    scatter3(pos_mu(1), pos_mu(2), pos_mu(3), 100, 'b*');
    xlabel('X [km]');
    ylabel('Y [km]');
    zlabel('Z [km]');
    title(sprintf('%d-Std Covariance Ellipsoid', n_std));
    grid on;
    axis equal;
end
