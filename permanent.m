function [ output ] = permanent( input, window )

    output = tsmovavg(input,'s',window, 1);

end

