
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
pts = double(pts);
mm = max(pts,[],2);
pts(1,:) = pts(1,:) / mm(1);
pts(2,:) = pts(2,:) / mm(2);

% plot(1:e_size, epochs_ecg(:,sel), 'r- ', 1:e_size, epochs_ppg(:,sel), 'r- ', ...
%     pts(1,sel)*norm, epochs_ecg(pts(1,sel)*norm,sel), 'bx ', ...
%     pts(2,sel)*norm, epochs_ppg(pts(2,sel)*norm,sel), 'bx ' );
% axis([0 inf -0.5 1.5])
% title('Epoch');
save('epochs.mat', pts, epochs_ecg, epochs_ppg);