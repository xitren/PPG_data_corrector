clear;
load('corrected.mat');

all_size = size(vq2,2);
e_size = 700;
epoch_ecg = zeros(all_size - 700,e_size);
epoch_ppg = zeros(all_size - 700,e_size);
epoch_result = zeros(all_size - 700,1);
for i=(701:all_size)
    rr = ECG( (i - e_size):(i - 1) );
    min_rr = min(rr);
    max_rr = max(rr);
    rr = (rr - min_rr) ./ (max_rr - min_rr);
    rr2 = PPG( (i - e_size):(i - 1) );
    min_rr2 = min(rr2);
    max_rr2 = max(rr2);
    rr2 = (rr2 - min_rr2) ./ (max_rr2 - min_rr2);
    epoch_ecg(i-700,:) = rr;
    epoch_ppg(i-700,:) = rr2;
    if (isnan(vq2(i-700)))
        epoch_result(i-700,1) = 0;
    else
        epoch_result(i-700,1) = vq2(i-700);
    end
end
% save('epochs_all.mat', 'epoch_ecg','epoch_ppg','vq2', '-v7.3');