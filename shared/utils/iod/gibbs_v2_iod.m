% Function: gibbs_v2_iod
% Desc: Calculate velocity component of the satellite at (t2) given 3
% position vectors (r1, r2, r3) as (r(t1), r(t2), r(t3))
%
% Inputs:
%   [r1, r2, r3] = Range position vector between topocenter and satellite
%   where r1, r2, r3 is (3,1) vector of positions (X, Y, Z) in ECEF
%
% Outputs:
%   v2: Velocity vector accompanying r2

function [v2] = gibbs_v2_iod(r1, r2, r3, mu)
    
    % Verify componenets Cross-Product
    hat_r1 = r1 ./ norm(r1);
    
    % Vector Norms
    nr1 = norm(r1);
    nr2 = norm(r2);
    nr3 = norm(r3);

    hat_r2_r3 = cross(r2, r3) ./ norm(cross(r2, r3));

    verify_comp = dot(hat_r1, hat_r2_r3);
    if verify_comp > 1e-3
        v2 = -1;
        fprintf("Failed tolerance test: Co-Planar assumption does not hold");
    else
        % Calculate Intermediate Values
        n = nr1 .* cross(r2, r3) + nr2 .* cross(r3, r1) + nr3 .* cross(r1, r2);
        d = cross(r1, r2) + cross(r2, r3) + cross(r3, r1);
        s = r1 .* (nr2 - nr3) + r2 .* (nr3 - nr1) + r3 .* (nr1 - nr2);

        % Calculate Final Value
        v2 = sqrt(mu/(norm(n) * norm(d))) * (cross(d, r2) ./ nr2 + s);
    end

end

