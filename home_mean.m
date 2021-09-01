m_ecg = mean(epochs_ecg,2);
m_ppg = mean(epochs_ppg,2);

targ = zeros(1,5505);
sigma_ecg_val = zeros(size(m_ecg,1), 1);
for i = 1:size(m_ecg,1)
    ss_ecg = abs(epochs_ecg(i,1) - m_ecg);
    sigma_ecg_val(i,1) = sum(ss_ecg)/size(ss_ecg,1);
end
sigma_ppg_val = zeros(size(m_ppg,1), 1);
for i = 1:size(m_ppg,1)
    ss_ppg = abs(epochs_ppg(i,1) - m_ppg);
    sigma_ppg_val(i,1) = sum(ss_ppg)/size(ss_ppg,1);
end

subplot(2,1,1);
plot(1:700, m_ecg, 'b- ', ...
    1:700, m_ecg - sigma_ecg_val, 'y- ', ...
    1:700, m_ecg + sigma_ecg_val, 'g- ');
subplot(2,1,2);
plot(1:700, m_ppg, 'b- ', ...
    1:700, m_ppg - sigma_ppg_val, 'y- ', ...
    1:700, m_ppg + sigma_ppg_val, 'g- ', ...
    1:700, epochs_ppg(:,2), 'r- ');

sel_ecg = zeros(1,size(epochs_ecg,2));
sel_ppg = zeros(1,size(epochs_ppg,2));
for i = 1:size(epochs_ppg,2)
    sel_ecg(i) = min(((m_ecg - sigma_ecg_val) < epochs_ecg(:,i)) & ...
        (epochs_ecg(:,i) < (m_ecg + sigma_ecg_val)));
end
for i = 1:size(epochs_ppg,2)
    sel_ppg(i) = min(((m_ppg - sigma_ppg_val) < epochs_ppg(:,i)) & ...
        (epochs_ppg(:,i) < (m_ppg + sigma_ppg_val)));
end

good_data = zeros(2800, 0);
% good_data_targ = zeros(1400, 0);
bad_data = zeros(2800, 0);
% bad_data_targ = zeros(1400, 0);

for i = 1:size(epochs_ppg,2)
    if (logical(sel_ecg(1, i)) && logical(sel_ppg(1, i)))
        good_data = [good_data,[epochs_ecg(:,i);epochs_ppg(:,i);epochs_ecg(:,i);epochs_ppg(:,i)]];
    else
        bad_data = [bad_data,[epochs_ecg(:,i);epochs_ppg(:,i);m_ecg;m_ppg]];
    end
end
