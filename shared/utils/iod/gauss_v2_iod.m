% Function: gauss_v2_iod
% Desc: Given right ascension and declination of the satellite in J2000 for
% 3 angular observations at t1, t2, t3, calculate the velocity component at t2
%
% Inputs:
%   [o1, o2 o3]: RA, Dec in degrees for each observation
%   [t1, t2, t3]: Times of the observations (UTC)
%   STATION_ECEF: ECEF vector of observation station
%   mu: Planet graviational constant
%
% Outputs:
%   v2: Velocity vector accompanying r2
%

function [r2, v2] = gauss_v2_iod(o1, o2, o3, t1, t2, t3, STATION_ECEF, mu)
    
    % Calculate Station in J2000
    R1 = ecef2eci(t1, STATION_ECEF);
    R2 = ecef2eci(t2, STATION_ECEF);
    R3 = ecef2eci(t3, STATION_ECEF);
    
    % Convert RA, DEC to Rad
    o1.DEC = deg2rad(o1.DEC); 
    o1.RA = deg2rad(o1.RA);

    o2.DEC = deg2rad(o2.DEC); 
    o2.RA = deg2rad(o2.RA);

    o3.DEC = deg2rad(o3.DEC); 
    o3.RA = deg2rad(o3.RA);

    % Time Components
    tau1 = seconds(t1 - t2);
    tau3 = seconds(t3 - t2);
    tau13 = seconds(t3 - t1);

    % LH Vector
    LH1 = [cos(o1.RA) * cos(o1.DEC);...
           sin(o1.RA) * cos(o1.DEC);...
           sin(o1.DEC)];

    LH2 = [cos(o2.RA) * cos(o2.DEC);...
           sin(o2.RA) * cos(o2.DEC);...
           sin(o2.DEC)];

    LH3 = [cos(o3.RA) * cos(o3.DEC);...
           sin(o3.RA) * cos(o3.DEC);...
           sin(o3.DEC)];


    % Intermediate D components
    d0 = dot(LH1, cross(LH2, LH3));

    d11 = dot(R1, cross(LH2, LH3));
    d12 = dot(R1, cross(LH1, LH3));
    d13 = dot(R1, cross(LH1, LH2));

    d21 = dot(R2, cross(LH2, LH3));
    d22 = dot(R2, cross(LH1, LH3));
    d23 = dot(R2, cross(LH1, LH2));

    d31 = dot(R3, cross(LH2, LH3));
    d32 = dot(R3, cross(LH1, LH3));
    d33 = dot(R3, cross(LH1, LH2));

    % Additional Intermediate Components
    A = (1 / d0) * ((-tau3 / tau13) * d12 + d22 + (tau1 / tau13) * d32);
    B = (1 / (6*d0)) * (-(tau13^2 - tau3^2) * (tau3/tau13) * d12 + (tau13^2 - tau1^2) ...
                                                            * (tau1 / tau13) * d32);

    % Calculate Polynomial Coefficients
    a = -A^2 - 2*A*(dot(LH2, R2)) - norm(R2)^2;
    b = -2 * mu * B * (A + dot(LH2, R2));
    c = -mu^2 * B^2;

    % Calculate Roots for R2
    roots_eq = [1, 0, a, 0, 0, b, 0, 0, c];
    roots_sol = roots(roots_eq);
    
    r2_norm = 0;    % Pre-allocate r2 norm
    for solution = 1:length(roots_sol)
        sol = roots_sol(solution);

        % Check for Real Positive Roots
        if isreal(sol) && (sol > 0)

            % Check for Size
            if (sol > norm(R1))
                r2_norm = sol;
            end
        end
    end

    % Return with bad v2 to signal impossible orbit
    if ~r2_norm
        v2 = -1;
        return;
    end

    % Calculate Slant Range
    p1 = (1 / d0) * (((6 * (d31 * (tau1/tau3) + d21 * (tau13/tau3)) * r2_norm^3 ...
        + mu * d31 * (tau13^2 - tau1^2) * (tau1/tau3)) / (6 * r2_norm^3 ...
        + mu * (tau13^2 - tau3^2))) - d11);

    p2 = A + (mu * B * (r2_norm^-3));

    p3 = (1 / d0) * (((6 * (d13 * (tau3/tau1) - d23 * (tau13/tau1)) * r2_norm^3 ...
        + mu * d13 * (tau13^2 - tau3^2) * (tau3/tau1)) / (6 * r2_norm^3 ...
        + mu * (tau13^2 - tau1^2))) - d33);

    % Calculate Satellite ECI Vector
    r1 = R1 + (p1 * LH1);
    r2 = R2 + (p2 * LH2);
    r3 = R3 + (p3 * LH3);

    % Calculate v2 Using Gibbs
    v2 = gibbs_v2_iod(r1, r2, r3, mu);

end

