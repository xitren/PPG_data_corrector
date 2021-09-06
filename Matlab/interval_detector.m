function [ up, lo ] = filter_detector( data, correction, avg_window )
%interval_detector returning interval of signal 
%   [lower, higher] = interval_detector(data, period_max, decrement)
%   returns the numerical interval of the data
%   period_max means the period after wich we can decrement max value) 
%   if don't encounter any other maximums and increment min value.
%   Decrement the value.

    [grad] = gradient(data);
    [avg_src] = tsmovavg(grad,'s',avg_window, 1);
    avg_src(1:avg_window) = ones(avg_window, 1);
    [signs] = sign(avg_src);
    [peaks_max] = [signs(1:(end-1)) < signs(2:(end)); 0];
    [peaks_min] = [signs(1:(end-1)) > signs(2:(end)); 0];
    peaks_p_max = find(peaks_max);
    peaks_p_min = find(peaks_min);
    up_d = pchip(peaks_p_max, data(peaks_p_max), 1:size(grad,1));
    lo_d = pchip(peaks_p_min, data(peaks_p_min), 1:size(grad,1));
    up = up_d + (up_d - lo_d) * correction;
    lo = lo_d - (up_d - lo_d) * correction;
end

