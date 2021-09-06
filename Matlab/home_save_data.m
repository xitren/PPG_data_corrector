ECG = ECG - min(ECG);
PPG = PPG - min(PPG);

inputs = [ ECG(1:1000,1)' ; PPG(1:1000,1)' ];
inputs = uint32(inputs);
fid = fopen('input_data_test.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [ ECG(1:10000,1)' ; PPG(1:10000,1)' ];
inputs = uint32(inputs);
fid = fopen('input_data_light.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs = [ ECG' ; PPG' ];
inputs = uint32(inputs);
fid = fopen('input_data.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);