% Function: arcsec2sec
% Desc: Convert from arc-second to seconds
%
% Input: arc: arc seconds
%
% output: sec: seconds

function [sec] = arcsec2sec(arc)
    ARC_SEC_CONVERSION = 0.067;         % Arcsec to sec conversion factor [sec]
    sec = arc * ARC_SEC_CONVERSION;
end

