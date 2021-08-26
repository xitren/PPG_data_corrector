
rr = 1:78399;
subplot(2,1,1); 
plot(rr, ECG(rr), rr, PPG(rr));
axis([1000 5000 -100 100])

subplot(2,1,2);
plot(rr, nan1(rr), rr, nan2(rr), rr, nan3(rr));
axis([1000 5000 -inf inf])