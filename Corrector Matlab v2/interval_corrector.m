function [ PAT_corr ] = interval_corrector( PAT, corrector )
    PAT_corr = PAT;
    if (size(PAT, 1) > 0)
        l_corr = 2;
        counter = 1;
        last = PAT(1,2);
        for i = 2:size(PAT, 1)
            next = PAT(i,2);
            if (abs(next - last) > (corrector * counter))
                counter = counter + 1;
            else
                counter = 1;
                PAT_corr(l_corr,:) = PAT(i,:);
                l_corr = l_corr + 1;
            end
        end
        PAT_corr = PAT_corr(1:(l_corr - 1),:);
    end
end

