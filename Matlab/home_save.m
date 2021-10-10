
inputs = epoch_result';
fid = fopen('input_data_result_1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

fid = fopen('input_data_ecg_700.txt','w');
[rows cols] = size(epoch_ecg);
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],epoch_ecg');
fclose(fid);
inputs = epoch_ecg(:,1:2:700)';
fid = fopen('input_data_ecg_350.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ecg(:,1:7:700)';
fid = fopen('input_data_ecg_100.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ecg(:,1:10:700)';
fid = fopen('input_data_ecg_70.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ecg(:,1:70:700)';
fid = fopen('input_data_ecg_10.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

fid = fopen('input_data_ppg_700.txt','w');
[rows cols] = size(epoch_ppg);
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],epoch_ppg');
fclose(fid);
inputs = epoch_ppg(:,1:2:700)';
fid = fopen('input_data_ppg_350.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ppg(:,1:7:700)';
fid = fopen('input_data_ppg_100.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ppg(:,1:10:700)';
fid = fopen('input_data_ppg_70.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
inputs = epoch_ppg(:,1:70:700)';
fid = fopen('input_data_ppg_10.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);
