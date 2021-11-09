%Initial
clear;
load('data_quat.mat');
left_hand_ECG = left_hand_ECG(62:size(left_hand_ECG,1),1);
left_hand_PPG = left_hand_PPG(62:size(left_hand_PPG,1),1);
lh_size = 1:size(left_hand_ECG,1);
rh_size = 1:size(right_hand_ECG,1);

subplot(5,2,1);
[left_peaks_ecg, left_peaks_ppg] = ...
    plot_peaks_ECG(left_hand_ECG, left_hand_PPG, 400);
title('Left hand ECG/PPG points');

subplot(5,2,2);
[right_peaks_ecg, right_peaks_ppg] = ...
    plot_peaks_ECG(right_hand_ECG, right_hand_PPG, 400);
title('Right hand ECG/PPG points');

subplot(5,2,3);
[left_PAT2] = plot_peaks_PAT( left_hand_ECG, left_hand_PPG, ...
    left_peaks_ecg, left_peaks_ppg, ...
    left_hand_PAT_time, left_hand_PAT);
title('Left hand PAT calculated data');

subplot(5,2,4);
[right_PAT2] = plot_peaks_PAT( right_hand_ECG, right_hand_PPG, ...
    right_peaks_ecg, right_peaks_ppg, ...
    right_hand_PAT_time, right_hand_PAT);
title('Right hand PAT calculated data');

subplot(5,2,5);
plot_corrected(left_hand_ECG, left_hand_PPG, 400);
title('Corrected data');

subplot(5,2,6);
plot_corrected(right_hand_ECG, right_hand_PPG, 400);
title('Corrected data');

subplot(5,2,7);
rr = ((1:size(left_hand_quaternion,1))') * 35.651;
left_hand_quat_mod(:,1) = pchip(rr, left_hand_quaternion(:,1), lh_size);
left_hand_quat_mod(:,2) = pchip(rr, left_hand_quaternion(:,2), lh_size);
left_hand_quat_mod(:,3) = pchip(rr, left_hand_quaternion(:,3), lh_size);
left_hand_quat_mod(:,4) = pchip(rr, left_hand_quaternion(:,4), lh_size);
plot(...
    lh_size, left_hand_quat_mod(lh_size,1), 'r- ', ...
    lh_size, left_hand_quat_mod(lh_size,2), 'g- ', ...
    lh_size, left_hand_quat_mod(lh_size,3), 'b- ', ...
    lh_size, left_hand_quat_mod(lh_size,4), 'y- ');
axis([1000 inf -inf inf])
title('Quaternion');

subplot(5,2,8);
[grad_quat(:,1)] = gradient(left_hand_quat_mod(lh_size,1));
[grad_quat(:,2)] = gradient(left_hand_quat_mod(lh_size,2));
[grad_quat(:,3)] = gradient(left_hand_quat_mod(lh_size,3));
[grad_quat(:,4)] = gradient(left_hand_quat_mod(lh_size,4));
movement = sqrt( grad_quat(:,1) .* grad_quat(:,1) + ...
                 grad_quat(:,2) .* grad_quat(:,2) + ...
                 grad_quat(:,4) .* grad_quat(:,4) );
movement(movement > 2000000) = 2000000;
plot(lh_size, movement > 500000);
axis([1000 inf -inf inf])
title('Movement');

subplot(5,2,9);
left_hand_PPG_nn = left_hand_PPG;
left_hand_PPG_nn(movement > 500000) = -500;
plot(left_hand_PPG_nn);
axis([1000 inf -500 500])
title('In movement data');

subplot(5,2,10);
right_hand_PPG_nn = right_hand_PPG;
right_hand_PPG_nn(movement > 500000) = -500;
plot(right_hand_PPG_nn);
axis([1000 inf -500 500])
title('In movement data');
