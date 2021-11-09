function [ up, lo ] = interval_detector2( data, window )
%interval_detector returning interval of signal 
%   [lower, higher] = interval_detector(data, period_max, decrement)
%   returns the numerical interval of the data
%   period_max means the period after wich we can decrement max value) 
%   if don't encounter any other maximums and increment min value.
%   Decrement the value.

    [peaks_max] = 1;
    [peaks_min] = 1;
    [peaks_max_val] = 0;
    [peaks_min_val] = 0;
    for i=(window + 1):(window/2):(size(data) - window)
        peaks_max_val = [peaks_max_val;max(data((i - window):(i + window)))];
        peaks_max = [peaks_max;i];
        peaks_min_val = [peaks_min_val;min(data((i - window):(i + window)))];
        peaks_min = [peaks_min;i];
    end
    
    up = pchip(peaks_max, peaks_max_val, 1:size(data,1));
    lo = pchip(peaks_min, peaks_min_val, 1:size(data,1));
end

