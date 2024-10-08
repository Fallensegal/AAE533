% Function: orbital_period
% Desc: Given elliptical orbit, use the graviational constant of the central
%   body and the orb.
% Inputs:
%   MU (type: single/double) [DIM: m^3/s^2]: Gravitational constant of the 
%   body the satellite is orbiting.
%
%   orbit_semimajor_axis (type: single/double) [DIM: m]: Semi-major axis of
%   the orbit of the satellite.
%
% Outputs:
%   period (type: single/double) [DIM: s] 

function [period] = orbital_period(MU, orbit_semimajor_axis)
    period = (2 * pi()) * sqrt((orbit_semimajor_axis ^ 3) / MU);
end