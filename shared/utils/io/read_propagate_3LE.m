function [tle_dict_new] = read_propagate_3LE(filename, propagation_datetime)
    % Initialize an empty dictionary (containers.Map)
    tle_dict_new = dictionary();
    
    % Open the file for reading
    fid = fopen(filename, 'r');
    if fid == -1
        error('File cannot be opened.');
    end
    
    % Read lines in chunks of three (name, line1, line2)
    while ~feof(fid)
        % Read the satellite name line
        sat_name = strtrim(fgetl(fid));
        
        % Read the TLE lines
        line1 = fgetl(fid);
        line2 = fgetl(fid);
        
        % Check if all lines were read correctly
        if ischar(sat_name) && ischar(line1) && ischar(line2)
            % Propagate Orbit
            [satrec, ~, ~, ~] ...
            = twoline2rv(721, line1, line2, 'c', 'd');

            % Define Propagation Time
            tokens = regexp(line1, '\s+', 'split');
            epoch_string = tokens{4};      % 4th token is epoch
            epoch_date_time = elset_epoch_2_datetime(epoch_string);
            tsince = minutes(propagation_datetime - epoch_date_time);

            [~,r,~] = sgp4(satrec, tsince);

            tle_dict_new = insert(tle_dict_new, sat_name, r);
        end
    end
    
    % Close the file
    fclose(fid);
end


