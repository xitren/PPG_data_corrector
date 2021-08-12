function [ pairs ] = interval_corrector( PPG, ECG )
    
    pairs = zeros(0,2);
    j = 1;
    for i = 1:size(PPG,1)
        while (ECG(j) < PPG(i))
            j = j + 1;
        end
        pairs = [pairs ; [ECG(j), PPG(i)]];
        j = j + 1;
    end
    
end

