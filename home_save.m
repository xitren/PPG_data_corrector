fid = fopen('input_datap.txt','w');
[rows cols] = size(inputs');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],inputs);
fclose(fid);

fid = fopen('target_datap.txt','w');
[rows cols] = size(pts');
x = repmat('%d\t',1,(cols-1));
fprintf(fid,[x,'%d\n'],pts);
fclose(fid);