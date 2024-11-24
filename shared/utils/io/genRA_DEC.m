% Function: genRA_DEC
% Calculate Jacobian terms and associated measurements in Right Ascension
% and Declination
%
% Author: Nathan Houtz, Purdue University (2019)
% Mod: Jeffrey Pekosh, Purdue University (2024)
%
% Inputs:
%   x -> J2000 Satellite Position
%   Rtopo -> J2000 Station Position
%
% Outputs:
%   

function [h, H_tilde] = genRA_DEC(x, Rtopo)
    rhoVec = x (1:3 ,:) - Rtopo ;
    xx = rhoVec (1 ,:);
    yy = rhoVec (2 ,:);
    zz = rhoVec (3 ,:);
    wsq = xx .* xx + yy .* yy;
    w = sqrt (wsq);
    rhosq = wsq + zz .* zz;
    
    h = [atan2d(yy ,xx); atand(zz ./w)];
    
    lidx_neg = h(1 ,:) <0;
    h(1, lidx_neg ) = (h(1, lidx_neg ) +360) ;
    
    % Compute H_tilde
    zero_vec = zeros ( size (xx));
    rad2deg = 180/ pi;
    H_tilde =...
     [ rad2deg *(-yy ./ wsq); 
     rad2deg *(-xx .* zz ./(w.* rhosq )); 
     rad2deg *( xx ./ wsq); 
     rad2deg *(-yy .* zz ./(w.* rhosq )); 
     zero_vec ; 
     rad2deg *(w./ rhosq ); 
     zero_vec ; 
     zero_vec ; 
     zero_vec ; 
     zero_vec ; 
     zero_vec ; 
     zero_vec ];
    
    if size (H_tilde ,2) ==1
        H_tilde = reshape ( H_tilde ,[2 ,6]) ;
    end

end

