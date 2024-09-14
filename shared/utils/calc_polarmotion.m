% Function: calc_polarmotion
% Desc: From polar motion measurements, calculate polar motion matrix
%
% Inputs:
%   MJD: Modified Julian Date in UTC
%
% Output:
%   PM_MATRIX: Polar Motion Matrix

function [PM_MATRIX] = calc_polarmotion(MJD)
    
    % Calculate Polar Motion
    polar_motion = polarMotion(MJD);
    xp = polar_motion(1);
    yp = polar_motion(2);

    PM_MATRIX = [1, 0, xp; 0, 1, -yp; -xp, yp, 1];
end

