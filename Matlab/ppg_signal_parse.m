data_source = val(5,1000:ss_f)';
%data_source = -(data_source);

%Filter data
[f, P1] = fourier(data_source, 250);
bfilt = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', 2, ...
    'StopbandFrequency', 2.5, 'SampleRate', 250);
data_source = filter(bfilt, data_source);

%Intervals
[grad] = gradient(data_source);
[up, lo] = interval_detector2(data_source, 70);
[grad] = tsmovavg(grad, 's', 250, 1);
[upd, lod] = interval_detector2(grad, 60);

%Normalize data
coff = lo' - up';
data_source_norm = (data_source - (lo')) ./ coff;
data_source_norm = abs(data_source_norm);

%Find pulses
signs = data_source_norm < 0.3;
[peaks] = [signs(1:(end-1)) > signs(2:(end)); 0];
peaks = find(peaks);

subplot(5,2,2); 
plot(1:size(data_source,1), data_source, 1:size(grad,1), up, 1:size(grad,1), lo);
title('PPG');
xlabel('X');
axis([0 inf 0 4000])

subplot(6,1,4); 
plot(1:size(data_source_norm,1), data_source_norm, ...
    1:size(data_source_norm,1), zeros(size(data_source_norm,1), 1) + 0.7);
title('Normalized data');
axis([0 inf 0 1])

subplot(5,2,6);
plot(1:size(data_source,1), data_source, 'b-',...
    peaks, data_source(peaks), 'rx ');%, ...
    %peakso, data_source(peakso), 'bx ');
title('Pulse points detector');
axis([0 inf 0 4000])

subplot(5,2,8);
peaks = peaks * 0.008;
[peaks_g, ex_g ] = interval_corrector(peaks, 0.12, 5);
delta_peak = [0;(peaks_g(2:end) - peaks_g(1:end-1))];
delta_ex = [0;(ex_g(2:end) - ex_g(1:end-1))];
delta_peak = delta_peak - mean(delta_peak);
delta_ex = delta_ex - mean(delta_ex);
peaks_g = int32(peaks_g / 0.008);
ex_g = int32(ex_g / 0.008);
plot(1:size(data_source,1), data_source, 'g-',...
    peaks_g, data_source(peaks_g), 'bx ',...
    ex_g, data_source(ex_g), 'rx ');
title('RANSAC on data');
axis([0 inf 0 4000])

subplot(5,2,4);
plot(peaks_g, delta_peak, 'bx ',...
    ex_g, delta_ex, 'rx ');
title('RANSAC');
%axis([0 inf 0 4000])

a = -10;
b = 90;
df_valid = zeros(0, b - a + 1); 
for i = 1:(size(peaks_g,1)-1)
    df_one = data_source((peaks_g(i) + a):(peaks_g(i) + b), 1);
    df_one = df_one - min(df_one);
    df_one = df_one ./ max(df_one);
    df_valid = [df_valid , df_one];
end
%subplot(6,1,6);
%plot(df_valid);
%title('RANSAC');