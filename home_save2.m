inputs = [good_data , bad_data];
fid = fopen('input_data_1400-1400.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

inputs2 = inputs(1:2:2800,:);
fid = fopen('input_data_700-700.txt','w');
[rows cols] = size(inputs2');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs2);
fclose(fid);

inputs2 = inputs(1:7:2800,:);
fid = fopen('input_data_200-200.txt','w');
[rows cols] = size(inputs2');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs2);
fclose(fid);

inputs2 = inputs(1:10:2800,:);
fid = fopen('input_data_140-140.txt','w');
[rows cols] = size(inputs2');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs2);
fclose(fid);

inputs2 = inputs(1:70:2800,:);
fid = fopen('input_data_20-20.txt','w');
[rows cols] = size(inputs2');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs2);
fclose(fid);