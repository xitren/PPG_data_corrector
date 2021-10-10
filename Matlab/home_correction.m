%Parameters
clear;
%load('long_test.mat');
load('data.mat');
gf = 1:size(ECG,1);
gy = 1:size(PPG,1);

subplot(4,1,1); 
[up_ecg, lo_ecg] = interval_detector2(ECG, 400);
peaks_ecg = find(ECG == up_ecg');
[peaks_cg, ex_cg ] = interval_corrector(peaks_ecg, 1000, 7);
plot(gf, ECG(gf), 'g-', gf, PPG(gf), 'b-',...
     peaks_cg, ECG(peaks_cg), 'rx ');
title('ECG');
axis([1000 inf -1000 1000])

subplot(4,1,3); 
[grad_ppg] = gradient(PPG);
[up_ppg, lo_ppg] = interval_detector2(grad_ppg, 400);
plot(1:size(grad_ppg), grad_ppg, 1:size(up_ppg,2), up_ppg, ...
    1:size(lo_ppg,2), lo_ppg);
axis([1000 inf -200 200])
title('PPG');

subplot(4,1,2);
ppgy = find(grad_ppg == up_ppg');
[peaks_g, ex_g ] = interval_corrector(ppgy, 1000, 7);
delta_peak = [0;(peaks_g(2:end) - peaks_g(1:end-1))];
delta_ex = [0;(ex_g(2:end) - ex_g(1:end-1))];
delta_peak = delta_peak - mean(delta_peak);
delta_ex = delta_ex - mean(delta_ex);
% peaks_g = int32(peaks_g);
% ex_g = int32(ex_g);
plot(gf, PPG(gf), 'g-', gf, ECG(gf), 'b-',...
     peaks_g, PPG(peaks_g), 'rx ');
% plot(gy, PPG(gy), 'g-',...
%     peaks_g, PPG(peaks_g), 'bx ', ex_g, PPG(ex_g), 'rx ');
title('RANSAC on data');
axis([0 inf -1000 1000])

peaks_tg = zeros(0,1);
for i = 1:(size(peaks_g,1))
    x1 = peaks_g(i) - 5;
    x2 = peaks_g(i) + 5;
    y1 = PPG(x1);
    y2 = PPG(x2);
    y = min(PPG( (peaks_g(i)-200):(peaks_g(i)+200) ));
    x = ((y - y1) * (x2 - x1) / (y2 - y1)) + x1;
    peaks_tg = [peaks_tg ; x];
end

subplot(4,1,3);
PAT2 = zeros(0,1);
for i = 1:size(peaks_cg,1)
    ind = find( (peaks_cg(i) < peaks_tg) & (peaks_tg < (peaks_cg(i) + 600)) );
    if (size(ind) > 0)
        PAT2 = [PAT2 ; [peaks_cg(i), peaks_tg(ind(1)) - peaks_cg(i)]];
    end
end
plot(PAT2(:,1), PAT2(:,2), 'b- ');
% plot(PAT2(:,1), PAT2(:,2), 'b- ', timePat, PAT-50, 'b- ');
% axis([0 inf 100 200]);
title('PAT');

coff_ecg = lo_ecg' - up_ecg';
data_source_norm_ecg = (ECG - (lo_ecg')) ./ coff_ecg;
data_source_norm_ecg = abs(data_source_norm_ecg);

coff_ppg = lo_ppg' - up_ppg';
data_source_norm_ppg = (PPG - (lo_ppg')) ./ coff_ppg;
data_source_norm_ppg = abs(data_source_norm_ppg);

subplot(4,1,4);
vq1 = interp1(PAT2(:,1), PAT2(:,2), gf);
vq2 = tsmovavg(vq1,'s',100000);
vq2 = (vq2 - 150) / 150;
plot(gf, vq2, 'b- ');
axis([0 inf 0 1]);
save('corrected.mat', 'ECG','PPG','vq2');
