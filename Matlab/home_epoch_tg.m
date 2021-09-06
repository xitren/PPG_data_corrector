home_correction;

e_var = -100;
e_size = 700;
epochs_ecg = zeros(e_size, 0);
epochs_ppg = zeros(e_size, 0);
pts = zeros(3, 0);
k = e_var;
for i = 3:size(peaks_cg)-2
%     for k = -300:20:300
        z1 = peaks_cg(i) + k;
        z2 = peaks_cg(i) + k + e_size - 1;
        fff = find((z1 < peaks_g) & (peaks_g < z2));
        if size(fff,1) > 0
            pts = [pts , [peaks_cg(i)-z1 ; peaks_g(fff(1))-z1 ; 0]];
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
%     end
end

for i = 1:size(epochs_ppg,2)
    x1 = pts(2,i) - 5;
    x2 = pts(2,i) + 5;
    y1 = epochs_ppg(x1,i);
    y2 = epochs_ppg(x2,i);
    y = min(epochs_ppg(:,i));
    x = ((y - y1) * (x2 - x1) / (y2 - y1)) + x1;
    pts(3,i) = x;
end