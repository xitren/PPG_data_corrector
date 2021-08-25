clear;
load('data.mat');

[up_ecg, lo_ecg] = interval_detector2(ECG, 600);
[up_ppg, lo_ppg] = interval_detector2(PPG, 600);

coff_ecg = lo_ecg' - up_ecg';
data_source_norm_ecg = (ECG - (lo_ecg')) ./ coff_ecg;
data_source_norm_ecg = abs(data_source_norm_ecg);

coff_ppg = lo_ppg' - up_ppg';
data_source_norm_ppg = (PPG - (lo_ppg')) ./ coff_ppg;
data_source_norm_ppg = abs(data_source_norm_ppg);

data = [data_source_norm_ecg, data_source_norm_ppg];

fid = fopen('prep_data.txt','w');
[rows cols] = size(data);
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],data');
fclose(fid);