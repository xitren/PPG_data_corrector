function [f, P1] = fourier(data, Fs)

    Y = fft(data);
                  
    T = 1/Fs;             % Sampling period    
    L = size(data, 1);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;

end