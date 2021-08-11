ss_f = 200000;
data_source = val(5,1000:end)';
%data_source = -(data_source);

%Filter data
[f, P1] = fourier(data_source, 250);
bfilt = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', 2, ...
    'StopbandFrequency', 2.5, 'SampleRate', 250);
data_source = filter(bfilt, data_source);

%Intervals
[grad] = gradient(data_source);
[up, lo] = interval_detector(data_source, 0.4, 30);
[grad] = tsmovavg(grad, 's', 250, 1);
[upd, lod] = interval_detector2(grad, 60);

%Normalize data
coff = lo' - up';
data_source_norm = (data_source - (lo')) ./ coff;
data_source_norm = abs(data_source_norm);

%Find pulses
signs = data_source_norm > 0.7;
[peaks] = [signs(1:(end-1)) > signs(2:(end)); 0];
peaks = find(peaks);

subplot(5,1,1); 
plot(1:size(data_source,1), data_source, 1:size(grad,1), up, 1:size(grad,1), lo);
title('PPG');
xlabel('X');
axis([0 inf 0 4000])

subplot(5,1,2); 
plot(1:size(data_source_norm,1), data_source_norm, ...
    1:size(data_source_norm,1), zeros(size(data_source_norm,1), 1) + 0.7);
title('Normalized data');
axis([0 inf 0 1])

subplot(5,1,3);
plot(1:size(data_source,1), data_source, 'b-',...
    peaks, data_source(peaks), 'rx ');%, ...
    %peakso, data_source(peakso), 'bx ');
title('Pulse points detector');
axis([0 inf 0 4000])

subplot(5,1,5);
peaks = peaks * 0.008;
[peaks_g, ex_g ] = interval_corrector(peaks, 0.12, 5);
delta_peak = [0;(peaks(2:end) - peaks(1:end-1))];
delta_ex = [0;(ex_g(2:end) - ex_g(1:end-1))];
delta_peak = delta_peak - mean(delta_peak);
delta_ex = delta_ex - mean(delta_ex);
peaks = int32(peaks / 0.008);
ex_g = int32(ex_g / 0.008);
plot(1:size(data_source,1), data_source, 'g-',...
    peaks, data_source(peaks), 'bx ',...
    ex_g, data_source(ex_g), 'rx ');
title('RANSAC on data');
axis([0 inf 0 4000])

subplot(5,1,4);
plot(peaks, delta_peak, 'bx ',...
    ex_g, delta_ex, 'rx ');
title('RANSAC');
%axis([0 inf 0 4000])

% subplot(6,1,5); 
% plot(f(1:(size(f,2)/12)), P1(1:(size(f,2)/12)));
% title('Single-Sided Amplitude Spectrum of X(t)');
% xlabel('f (Hz)');