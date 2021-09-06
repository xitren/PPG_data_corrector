function [ points_val, excluded ] = interval_corrector( points, delta, window )
%interval_detector returning interval of signal 
%   [points_val] = interval_corrector(points, window)
%   @ @ @ @ @ @
%     - - - - -
%       H H H H H
    
    intervals = [(points(2:end) - points(1:end-1));0];
    mean_val = zeros(size(intervals,1), 1);
    sigma_val = zeros(size(intervals,1), 1);
    for i = (window+1):(size(intervals,1) - window)
        rr = intervals((i-window):(i+window));
        mean_val(i,1) = mean(rr);
        ss = abs(rr - mean_val(i,1));
        sigma_val(i,1) = sum(ss)/size(ss,1);
    end
    delta_int = [(intervals(2:end) - mean_val(1:end-1));0];
    selector = delta_int > delta;
    filt_sel = ones(size(selector,1), 1);
    for i = (2):(size(selector,1) - 1)
        filt_sel(i) = sum(selector(i-1:i+1));
    end
    selector = logical(filt_sel);
    excluded = points(selector);
    points_val = points(not(selector));
end

