% Function: tclm2ah
% Desc: From topocentric local meridian X,Y,Z coordinates, calculate
% azimuth and elevation
function [az, elevation] = tclm2ah(tclm_coords, sample_size)

elevation = zeros(sample_size, 1);
az = zeros(sample_size, 1);
for sample_index = 1:sample_size
    X = tclm_coords{sample_index}(1);
    Y = tclm_coords{sample_index}(2);
    Z = tclm_coords{sample_index}(3);
    elevation(sample_index) = rad2deg(asin(Z));
    az(sample_index) = atan2d(Y, X);
end


end