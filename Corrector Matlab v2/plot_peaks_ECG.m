function [ peaks_cg, peaks_g ] = plot_peaks_ECG( ECG, PPG, interval )
    %Calculate ECG points
    [up_ecg, lo_ecg] = interval_detector2(ECG, interval);
    peaks_cg = find(ECG == up_ecg');
    
    %Calculate PPG points
    [grad_ppg] = gradient(PPG);
    [up_ppg, lo_ppg] = interval_detector2(grad_ppg, interval);
    peaks_g = find(grad_ppg == up_ppg');
    
    plot(1:size(ECG), ECG(1:size(ECG)), 'g-', 1:size(PPG), PPG(1:size(PPG)), 'b-',...
         peaks_cg, ECG(peaks_cg), 'bx ', peaks_g, PPG(peaks_g), 'rx ');
    title('ECG/PPG points');
    axis([1000 inf -1000 1000])
end

