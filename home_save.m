inputs = [epochs_ecg ; epochs_ppg ; pts(2,:)];
fid = fopen('input_data_1400-1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [epochs_ecg(1:2:700,:) ; epochs_ppg(1:2:700,:) ; pts(2,:)];
fid = fopen('input_data_700-1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [epochs_ecg(1:7:700,:) ; epochs_ppg(1:7:700,:) ; pts(2,:)];
fid = fopen('input_data_200-1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [epochs_ecg(1:10:700,:) ; epochs_ppg(1:10:700,:) ; pts(2,:)];
fid = fopen('input_data_140-1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [epochs_ecg(1:70:700,:) ; epochs_ppg(1:70:700,:) ; pts(2,:)];
fid = fopen('input_data_20-1.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);