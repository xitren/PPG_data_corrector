%data_source = inert_ECG(1:78000);
clear all;
%load('matlab.mat');
load('3372782_0073m.mat');

ss_f = 40000;

ppg_signal_parse;
ecg_signal_parse;