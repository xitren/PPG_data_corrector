%Initial
clear;
load('data_quat.mat');
left_hand_ECG = left_hand_ECG(62:size(left_hand_ECG,1),1);
left_hand_PPG = left_hand_PPG(62:size(left_hand_PPG,1),1);
lh_size = 1:size(left_hand_ECG,1);
rh_size = 1:size(right_hand_ECG,1);

subplot(6,2,1);
[left_peaks_ecg, left_peaks_ppg] = ...
    plot_peaks_ECG(left_hand_ECG, left_hand_PPG, 400);
title('Left hand ECG/PPG points');

subplot(6,2,2);
[right_peaks_ecg, right_peaks_ppg] = ...
    plot_peaks_ECG(right_hand_ECG, right_hand_PPG, 400);
title('Right hand ECG/PPG points');

subplot(6,2,3);
[left_PAT2] = plot_peaks_PAT( left_hand_ECG, left_hand_PPG, ...
    left_peaks_ecg, left_peaks_ppg, ...
    left_hand_PAT_time, left_hand_PAT);
title('Left hand PAT calculated data');

subplot(6,2,4);
[right_PAT2] = plot_peaks_PAT( right_hand_ECG, right_hand_PPG, ...
    right_peaks_ecg, right_peaks_ppg, ...
    right_hand_PAT_time, right_hand_PAT);
title('Right hand PAT calculated data');

subplot(6,2,5);
left_hand_PPG_corrected = plot_corrected(left_hand_ECG, left_hand_PPG, 400);
title('Corrected data');

subplot(6,2,6);
right_hand_PPG_corrected = plot_corrected(right_hand_ECG, right_hand_PPG, 400);
title('Corrected data');

subplot(6,2,8);
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

subplot(6,2,7);
[grad_quat(:,1)] = gradient(left_hand_quat_mod(lh_size,1));
[grad_quat(:,2)] = gradient(left_hand_quat_mod(lh_size,2));
[grad_quat(:,3)] = gradient(left_hand_quat_mod(lh_size,3));
[grad_quat(:,4)] = gradient(left_hand_quat_mod(lh_size,4));
movement = sqrt( grad_quat(:,1) .* grad_quat(:,1) + ...
                 grad_quat(:,2) .* grad_quat(:,2) + ...
                 grad_quat(:,4) .* grad_quat(:,4) );
movement(movement > 3000000) = 0;
window = 5000;
avg_src_q(:,1) = tsmovavg(grad_quat(:,1), 's', window, 1);
avg_src_q(:,2) = tsmovavg(grad_quat(:,2), 's', window, 1);
avg_src_q(:,3) = tsmovavg(grad_quat(:,3), 's', window, 1);
avg_src_q(:,4) = tsmovavg(grad_quat(:,4), 's', window, 1);
avg_src_q(1:window,1) = ones(window, 1);
avg_src_q(1:window,2) = ones(window, 1);
avg_src_q(1:window,3) = ones(window, 1);
avg_src_q(1:window,4) = ones(window, 1);
[avg_src] = tsmovavg(movement, 's', window, 1);
avg_src(1:window) = ones(window, 1);
movement_mode = avg_src > 0;
plot(lh_size, avg_src_q(:,1), 'r- ', ...
    lh_size, avg_src_q(:,2), 'g- ', ...
    lh_size, avg_src_q(:,3), 'y- ', ...
    lh_size, avg_src_q(:,4), 'b- ' );
% plot(lh_size, avg_src);
axis([1000 inf -inf inf])
title('Movement');

% subplot(6,2,9);
% left_PAT2_l = left_PAT2(movement_mode(left_PAT2(1:end,1)),:);
% left_peaks_ppg_l = left_peaks_ppg(movement_mode(left_peaks_ppg(:,1)),:);
% left_hand_PPG_nn = left_hand_PPG_corrected;
% left_hand_PPG_nn(~movement_mode) = 0;
% % plot(1:size(left_hand_PPG_nn, 1), left_hand_PPG_nn, 'b- ', ...
% %      left_PAT2_l(:,1), zeros(size(left_PAT2_l,1)) + 0.5, 'rx ');
% plot(1:size(left_hand_PPG_nn), left_hand_PPG_nn(1:size(left_hand_PPG_nn)), 'g-',...
%     left_peaks_ppg_l, left_hand_PPG_nn(left_peaks_ppg_l), 'bx ');
% axis([1000 inf 0 1])
% title('Left hand In movement data');
% 
% subplot(6,2,10);
% right_PAT2_l = right_PAT2(movement_mode(right_PAT2(1:end,1)),:);
% right_peaks_ppg_l = right_peaks_ppg(movement_mode(right_peaks_ppg(:,1)),:);
% right_hand_PPG_nn = right_hand_PPG_corrected;
% right_hand_PPG_nn(~movement_mode) = 0;
% % plot(1:size(right_hand_PPG_nn, 1), right_hand_PPG_nn, 'b- ', ...
% %      right_PAT2_l(:,1), zeros(size(right_PAT2_l,1)) + 0.5, 'rx ');
% plot(1:size(right_hand_PPG_nn), right_hand_PPG_nn(1:size(right_hand_PPG_nn)), 'g-',...
%     right_peaks_ppg_l, right_hand_PPG_nn(right_peaks_ppg_l), 'bx ');
% axis([1000 inf 0 1])
% title('Right hand In movement data');
% 
% subplot(6,2,11);
% left_ppg_epochs = zeros(700, size(left_peaks_ppg_l, 1));
% for i = 1:size(left_peaks_ppg_l, 1)
%     left_ppg_epochs(:,i) = left_hand_PPG_nn((left_peaks_ppg_l(i)-350):(left_peaks_ppg_l(i)+349));
% end
% left_ppg_epoch_mid = mean(left_ppg_epochs, 2);
% plot(left_ppg_epoch_mid);
% axis([0 inf 0 1])
% title('Left hand mean epoch PPG');
% 
% subplot(6,2,12);
% right_ppg_epochs = zeros(700, size(right_peaks_ppg_l, 1));
% for i = 1:size(right_peaks_ppg_l, 1)
%     right_ppg_epochs(:,i) = right_hand_PPG_nn((right_peaks_ppg_l(i)-350):(right_peaks_ppg_l(i)+349));
% end
% right_ppg_epoch_mid = mean(right_ppg_epochs, 2);
% plot(1:700, right_ppg_epoch_mid, 'b- ', 1:700, left_ppg_epoch_mid, 'g- ');
% axis([0 inf 0 1])
% title('Right hand mean epoch PPG');
