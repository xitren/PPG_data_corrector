%Parameters
clear;
load('long_test.mat');
gy = 1:size(ECG,1);

subplot(4,1,1); 
plot(gy, ECG(gy));
title('ECG');
axis([1000 inf -inf inf])

subplot(4,1,2); 
[grad_ecg] = gradient(ECG);
[up_ecg, lo_ecg] = interval_detector2(grad_ecg, 600);
plot(1:size(grad_ecg), grad_ecg, 1:size(up_ecg,2), up_ecg, ...
    1:size(lo_ecg,2), lo_ecg);
axis([1000 inf -inf inf])
title('PPG');

subplot(4,1,1);
ppgy = find(grad_ecg == up_ecg');
[peaks_g, ex_g ] = interval_corrector(ppgy, 1000, 5);
delta_peak = [0;(peaks_g(2:end) - peaks_g(1:end-1))];
delta_ex = [0;(ex_g(2:end) - ex_g(1:end-1))];
delta_peak = delta_peak - mean(delta_peak);
delta_ex = delta_ex - mean(delta_ex);
peaks_g = int32(peaks_g);
ex_g = int32(ex_g);
plot(gy, ECG(gy), 'g-',...
    peaks_g, ECG(peaks_g), 'bx ',...
    ex_g, ECG(ex_g), 'rx ');
title('RANSAC on data');
axis([0 inf -inf inf])

subplot(4,1,3);
plot(peaks_g, delta_peak, 'bx ',...
    ex_g, delta_ex, 'rx ');
title('RANSAC');
