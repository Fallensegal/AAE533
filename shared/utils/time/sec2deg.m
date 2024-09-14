% Function: sec2deg
% Desc: Convert from seconds to degrees (with respect to rotation)
%
% Input:
%   sec: rotation in seconds
%
% Output:
%   deg: rotation in degrees

function [deg] = sec2deg(sec)

    SECONDS2DEGREE_FACTOR = 4 * 60;     % Seconds per degree of rotation
    deg = sec ./ SECONDS2DEGREE_FACTOR;
    
end

