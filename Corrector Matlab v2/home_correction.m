%Initial
clear;
load('data_quat.mat');
left_hand_ECG = left_hand_ECG(62:size(left_hand_ECG,1),1);
left_hand_PPG = left_hand_PPG(62:size(left_hand_PPG,1),1);
lh_size = 1:size(left_hand_ECG,1);
rh_size = 1:size(right_hand_ECG,1);

subplot(3,2,1);
[left_peaks_ecg, left_peaks_ppg] = ...
    plot_peaks_ECG(left_hand_ECG, left_hand_PPG, 400);
title('Left hand ECG/PPG points');

subplot(3,2,2);
[right_peaks_ecg, right_peaks_ppg] = ...
    plot_peaks_ECG(right_hand_ECG, right_hand_PPG, 400);
title('Right hand ECG/PPG points');

subplot(3,2,3);
[left_PAT2] = plot_peaks_PAT( left_hand_ECG, left_hand_PPG, ...
    left_peaks_ecg, left_peaks_ppg, ...
    left_hand_PAT_time, left_hand_PAT);
title('Left hand PAT calculated data');

subplot(3,2,4);
[right_PAT2] = plot_peaks_PAT( right_hand_ECG, right_hand_PPG, ...
    right_peaks_ecg, right_peaks_ppg, ...
    right_hand_PAT_time, right_hand_PAT);
title('Right hand PAT calculated data');

subplot(3,2,5);
plot_corrected(left_hand_ECG, left_hand_PPG, 400);
title('Corrected data');

