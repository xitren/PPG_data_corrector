%Parameters
merely = 29;
gy = 1000:70000;

subplot(3,1,1); 
plot(gy, inert_ECG(gy), gy + merely, noinert_ECG(gy) );
title('ECG');
axis([1000 inf -100 100])

subplot(3,1,2); 
plot(gy, inert_PPG(gy), gy + merely, noinert_PPG(gy) );
title('PPG');
axis([1000 inf -1000 1000])

subplot(3,1,3); 
plot(1:size(inert_PAT), inert_PAT, 'bx ',...
    1:size(noinert_PAT), noinert_PAT, 'rx ');
title('PAT');