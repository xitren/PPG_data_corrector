
data_source = val(2,1000:9000)';

%Prapare ECG data to detection
[avg_src] = tsmovavg(data_source,'s',1, 1);
avg_src(1:100) = ones(100, 1);
bfilt = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', 1.6, ...
    'StopbandFrequency', 2, 'SampleRate', 125);
data_source_filt = filter(bfilt, avg_src);
[grad] = gradient(data_source);
[avg] = permanent(grad, 1000);
[up, lo] = interval_detector(data_source_filt, 0.4, 20);

%Check frequencies
[f, P1] = fourier(avg_src, 250);

%Find pulses
signs = data_source_filt < ((up - lo) / 2 + lo)';
[peaks] = [signs(1:(end-1)) > signs(2:(end)); 0];
peaks = find(peaks);

subplot(6,2,1); 
plot(1:size(data_source,1), data_source);
title('ECG');
xlabel('X');

subplot(6,2,3); 
plot(1:size(avg_src,1), avg_src);
title('Moving average');

subplot(6,2,5); 
plot(1:size(data_source_filt,1), data_source_filt, 1:size(up,2), up, ...
    1:size(lo,2), lo);
title('Filtered data');

subplot(6,2,7); 
plot(1:size(data_source,1), data_source, 'b-', peaks, data_source(peaks), 'rx ');
title('Pulse points detector');

subplot(6,2,9); 
%plot(1:size(avg,1), abs(aac - avg));
title('abs data');

subplot(6,2,11); 
plot(f(1:(size(f,2)/12)), P1(1:(size(f,2)/12)));
title('Single-Sided Amplitude Spectrum of X(t)');
xlabel('f (Hz)');