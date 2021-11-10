function [ ECG_PPG ] = plot_corrected( ECG, PPG, interval )

    [up_ecg, lo_ecg] = interval_detector2(ECG, interval);
    coff_ecg = lo_ecg' - up_ecg';
    ECG = (ECG - (lo_ecg')) ./ coff_ecg;
    
    [up_ppg, lo_ppg] = interval_detector2(PPG, interval);
    coff_ppg = lo_ppg' - up_ppg';
    PPG = (PPG - (lo_ppg')) ./ coff_ppg;
    
    ECG_PPG = abs(PPG);
    plot(ECG_PPG, 'b- ');
    title('Corrected data');
    axis([0 inf 0 1]);
    
end

