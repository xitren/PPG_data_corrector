function [ PAT2 ] = plot_peaks_PAT( ECG, PPG, peaks_ecg, peaks_ppg, ...
                PAT_time, PAT)

    peaks_tg = zeros(0,1);
    for i = 2:(size(peaks_ppg,1))
        x1 = peaks_ppg(i) - 5;
        x2 = peaks_ppg(i) + 5;
        y1 = PPG(x1);
        y2 = PPG(x2);
        y = min(PPG( (peaks_ppg(i)-200):(peaks_ppg(i)+200) ));
        x = ((y - y1) * (x2 - x1) / (y2 - y1)) + x1;
        peaks_tg = [peaks_tg ; x];
    end
    
    PAT2 = zeros(0,1);
    for i = 1:size(peaks_ecg,1)
        ind = find( (peaks_ecg(i) < peaks_tg) & (peaks_tg < (peaks_ecg(i) + 600)) );
        if (size(ind) > 0)
            PAT2 = [PAT2 ; [peaks_ecg(i), peaks_tg(ind(1)) - peaks_ecg(i)]];
        end
    end
%     PAT2 = interval_corrector(PAT2, 20);
    
    plot(PAT2(:,1), PAT2(:,2), 'b- ', PAT_time, PAT, 'r- ');
    title('PAT calculated data');
    axis([0 inf min(PAT) max(PAT)]);
    
end

