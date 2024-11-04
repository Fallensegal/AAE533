% read in a TLE object, retrive osculating state 
%
%
%
% Author: C. Frueh
% creation date  9/5/2017
% last modified: 8/25/2019
% 
% inputs: TLE file
% dependencies: vallado subroutines as uploaded on BB
% - twoline2rv and its dependencies
% - sgp4 and its dependencies
% 
% error corrections:
%   - adhere more closely to pep8, 09/01/2022
%
%

clear all;
cc=0; % set line counter

    fid = fopen('tle_justfortesting.txt'); % load the TLE
    
    tline2='gg';
    while ischar(tline2)
        cc = cc+1; % counter
        name = fgets(fid);% for the ones with three lines
        tline1 = fgets(fid); % collect first line of two line elements
        tline2 = fgets(fid); % collect second line of two line elements

        if tline2>0 % stop at the end of the file
            % initialize the propagation
            [satrec, startmfe, stopmfe, deltamin] ...
            = twoline2rv(721, tline1, tline2, 'c', 'd');
        
            % how far shall the TLE be propagated [minutes]
            tsince = 0.0; 
            % extract position and velocity
            [satrec, r, v] = sgp4(satrec, tsince); 
        end
    end
    