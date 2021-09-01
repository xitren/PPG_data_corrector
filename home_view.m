
rr = 1:5878399;
subplot(2,1,1); 
plot(rr, ECG(rr), rr, PPG(rr));
axis([2000 10000 -100 100])

subplot(2,1,2);
plot(rr, nan1(rr), rr, nan2(rr), rr, nan3(rr));
axis([2000 10000 -inf inf])