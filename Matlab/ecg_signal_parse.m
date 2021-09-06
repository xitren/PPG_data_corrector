
data_source_ecg = val(2,1000:ss_f)';

%Prapare ECG data to detection
[avg_src_ecg] = tsmovavg(data_source_ecg,'s',1, 1);
avg_src_ecg(1:100) = ones(100, 1);
bfilt_ecg = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', 1.6, ...
    'StopbandFrequency', 2, 'SampleRate', 125);
[grad_ecg] = gradient(data_source_ecg);
[avg_ecg] = permanent(grad_ecg, 1000);
[up_ecg, lo_ecg] = interval_detector2(data_source_ecg, 100);

%Check frequencies
[f_ecg, P1_ecg] = fourier(avg_src_ecg, 250);

coff_ecg = lo_ecg' - up_ecg';
data_source_norm_ecg = (data_source_ecg - (lo_ecg')) ./ coff_ecg;
data_source_norm_ecg = abs(data_source_norm_ecg);

%Find pulses
signs_ecg = data_source_norm_ecg > 0.7;
[peaks_ecg] = [signs_ecg(1:(end-1)) < signs_ecg(2:(end)); 0];
peaks_ecg = find(peaks_ecg);

subplot(5,2,1); 
plot(1:size(data_source_ecg,1), data_source_ecg, 1:size(up_ecg,2), up_ecg, ...
    1:size(lo_ecg,2), lo_ecg);
title('ECG');
axis([0 inf 0 4000])

subplot(5,2,3);
plot(1:size(data_source_norm_ecg,1), data_source_norm_ecg);
title('Normalized data');
axis([0 inf 0 1])

subplot(5,2,5);
plot(1:size(data_source_ecg,1), data_source_ecg, ...
    1:size(data_source_ecg,1), zeros(size(data_source_ecg,1), 1) + 0.7);
title('Pulse points detector');
axis([0 inf 0 4000])

subplot(5,2,7); 
plot(1:size(data_source,1), data_source, 'g-',...
    1:size(data_source_ecg,1), data_source_ecg, 'y-',...
    peaks_g, data_source(peaks_g), 'bx ',...
    peaks_ecg, data_source_ecg(peaks_ecg), 'rx ');
title('Pulse points detector (All)');
axis([0 inf 0 4000])

subplot(5,2,9); 
pair = interval_pair(peaks_g, peaks_ecg);
plot(pair(:,1), abs(pair(:,2) - pair(:,1)), 'bx ');
title('Base for calculation');
axis([0 inf 0 inf])


% subplot(5,2,11); 
% plot(f(1:(size(f,2)/12)), P1(1:(size(f,2)/12)));
% title('Single-Sided Amplitude Spectrum of X(t)');
% xlabel('f (Hz)');