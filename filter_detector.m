function [ parsed ] = filter_detector( data, filt )

    parsed = zeros(size(data, 1), 1);
    
    for i = 1:(size(data, 1) - size(filt, 1))
        parsed(i:(i + size(filt, 1) - 1), 1) = ...
            data(i:(i + size(filt, 1) - 1), 1) .* filt;
    end

end

