%Parameters
clear;
load('long_test.mat');
gf = 1:size(ECG,1);
gy = 1:size(PPG,1);

subplot(4,1,1); 
[up_ecg, lo_ecg] = interval_detector2(ECG, 600);
peaks_ecg = find(ECG == up_ecg');
[peaks_cg, ex_cg ] = interval_corrector(peaks_ecg, 1000, 7);
plot(gf, ECG(gf), 'g-',...
    peaks_cg, ECG(peaks_cg), 'bx ', ex_cg, ECG(ex_cg), 'rx ');
title('ECG');
axis([1000 inf -1000 1000])

subplot(4,1,3); 
[grad_ppg] = gradient(PPG);
[up_ppg, lo_ppg] = interval_detector2(grad_ppg, 600);
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
peaks_g = int32(peaks_g);
ex_g = int32(ex_g);
plot(gy, PPG(gy), 'g-',...
    peaks_g, PPG(peaks_g), 'bx ', ex_g, PPG(ex_g), 'rx ');
title('RANSAC on data');
axis([0 inf -1000 1000])

subplot(4,1,3);
plot(peaks_g, delta_peak, 'b- ', ex_g, delta_ex, 'r- ');
title('Epoch');

coff_ecg = lo_ecg' - up_ecg';
data_source_norm_ecg = (ECG - (lo_ecg')) ./ coff_ecg;
data_source_norm_ecg = abs(data_source_norm_ecg);

coff_ppg = lo_ppg' - up_ppg';
data_source_norm_ppg = (PPG - (lo_ppg')) ./ coff_ppg;
data_source_norm_ppg = abs(data_source_norm_ppg);

e_var = -100;
e_size = 700;
epochs_ecg = zeros(e_size, 0);
epochs_ppg = zeros(e_size, 0);
pts = zeros(3, 0);
lines = zeros(0, 2);
for i = 1:size(peaks_g)
    x1 = peaks_g(i) - 1;
    y1 = PPG(x1);
    x2 = peaks_g(i);
    y2 = PPG(x2);
    [m, b] = line_from_points(x1, y1, x2, y2);
    lines = [lines ; [m, b]];
end
for i = 3:size(peaks_cg)-2
    for k = -300:20:300
        z1 = peaks_cg(i) + k;
        z2 = peaks_cg(i) + k + e_size - 1;
        fff = find((z1 < peaks_g) & (peaks_g < z2));
        if size(fff,1) > 0
            pts = [pts , [peaks_cg(i) - z1 ; peaks_g(fff(1)) - z1 ; 1.]];
            ep = ECG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ecg = [epochs_ecg , ep];
            ep = PPG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ppg = [epochs_ppg , ep];
        else
            pts = [pts , [peaks_cg(i) - z1 ; 0. ; 0.]];
            ep = ECG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ecg = [epochs_ecg , ep];
            ep = PPG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ppg = [epochs_ppg , ep];
        end
    end
end
for i = 3:size(ex_cg)-2
    for k = -300:20:300
        z1 = ex_cg(i) + k;
        z2 = ex_cg(i) + k + e_size - 1;
        fff = find((z1 < peaks_g) & (peaks_g < z2));
        if size(fff,1) > 0
            pts = [pts , [0. ; 0. ; 1.]];
            ep = ECG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ecg = [epochs_ecg , ep];
            ep = PPG(z1 : z2);
            min_ep = min(ep);
            ep = ep - min_ep;
            max_ep = max(ep);
            ep = ep / max_ep;
            epochs_ppg = [epochs_ppg , ep];
        end
    end
end
sel = 2;
norm = 700;
pts = pts ./ norm;
plot(1:e_size, epochs_ecg(:,sel), 'r- ', 1:e_size, epochs_ppg(:,sel), 'r- ', ...
    pts(1,sel)*norm, epochs_ecg(pts(1,sel)*norm,sel), 'bx ', ...
    pts(2,sel)*norm, epochs_ppg(pts(2,sel)*norm,sel), 'bx ' );
axis([0 inf -0.5 1.5])
title('Epoch');
save('epochs.mat', pts, epochs_ecg, epochs_ppg);