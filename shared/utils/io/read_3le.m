% Function: read_3le
% Description: Read and output initial state and epoch time from 3LE file,
% separate from read_propagate_3le
function [RV_array, epoch_date_array] = read_3le(filename)
    
    % Check File Descriptor
    fid = fopen(filename, 'r');
    if fid == -1
        error('File cannot be opened');
    end
    
    RV_array = {};      % Cell for holding struct
    epoch_date_array = {};
    while ~feof(fid)

        % Readlines
        sat_name = strtrim(fgetl(fid));
        line1 = fgetl(fid);
        line2 = fgetl(fid);

        if ischar(sat_name) && ischar(line1) && ischar(line2)
            
            % Acquire TLE State
            [satrec, ~, ~] = twoline2rv(721, line1, line2, 'c', 'd');
            
            % Define TLE Epoch Time
            tokens = regexp(line1, '\s+', 'split');
            epoch_string = tokens{4};      % 4th token is epoch
            epoch_date_time = elset_epoch_2_datetime(epoch_string);

        end
        RV_array{end + 1} = satrec;
        epoch_date_array{end + 1} = epoch_date_time;
    end
end

