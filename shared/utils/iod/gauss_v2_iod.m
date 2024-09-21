% Function: gauss_v2_iod
% Desc: Given right ascension and declination of the satellite in J2000 for
% 3 angular observations at t1, t2, t3, calculate the velocity component at t2
%
% Inputs:
%   [o1, o2 o3]: RA, Dec in degrees for each observation
%   [t1, t2, t3]: Times of the observations (UTC)
%   station: Station Struct of Geodedic Information (Lat, Long, Alt)
%
% Outputs:
%   v2: Velocity vector accompanying r2
%

function [v2] = gauss_v2_iod(o1, o2, o3, t1, t2, t3, STATION_ECEF)
    
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
    b
    c

    % Calculate Roots for R2

    % Calculate Slant Range

    % Calculate Langrange Coefficients

end

