function epoch_datetime = elset_epoch_2_datetime(epoch_str)
%TLE_EPOCH_TO_DATETIME Converts TLE epoch string to MATLAB datetime.
%
%   epoch_datetime = TLE_EPOCH_TO_DATETIME(epoch_str)
%
%   Inputs:
%       epoch_str - A string representing the TLE epoch (e.g., '04236.56031392')
%
%   Outputs:
%       epoch_datetime - A MATLAB datetime object corresponding to the epoch.
%
%   Example:
%       epoch_str = '04236.56031392';
%       dt = tle_epoch_to_datetime(epoch_str);
%       disp(dt);  % Output: 24-Aug-2004 13:26:43

    % Ensure the input is a string
    if isnumeric(epoch_str)
        epoch_str = num2str(epoch_str, '%.10f');
    elseif ~ischar(epoch_str) && ~isstring(epoch_str)
        error('Input must be a string or numeric value representing the TLE epoch.');
    end

    % Remove any leading/trailing whitespace
    epoch_str = strtrim(epoch_str);
    
    % Validate the length of the epoch string
    if length(epoch_str) < 3
        error('Epoch string is too short. It must contain at least 3 characters.');
    end

    % Extract year part (first two characters)
    year_str = epoch_str(1:2);
    year_num = str2double(year_str);

    if isnan(year_num)
        error('Invalid year format in epoch string.');
    end

    % Determine the full year based on the two-digit year
    if year_num >= 57
        year = 1900 + year_num;
    else
        year = 2000 + year_num;
    end

    % Extract day of year part (from 3rd character onward)
    day_of_year_str = epoch_str(3:end);
    day_of_year = str2double(day_of_year_str);

    if isnan(day_of_year)
        error('Invalid day of year format in epoch string.');
    end

    % Split into integer day and fractional day
    day_int = floor(day_of_year);
    fractional_day = day_of_year - day_int;

    % Create datetime for January 1 of the determined year
    dt = datetime(year, 1, 1, 'TimeZone', 'UTC');

    % Add the integer days (subtract 1 since Jan 1 is day 1)
    dt = dt + days(day_int - 1);

    % Add the fractional day as hours, minutes, seconds, and milliseconds
    % Fractional day multiplied by 24 gives hours
    fractional_seconds = fractional_day * 24 * 3600;
    dt = dt + seconds(fractional_seconds);

    % Assign the output
    epoch_datetime = dt;
end
