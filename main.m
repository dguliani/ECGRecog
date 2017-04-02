clear all 
close all 
[tm,sig]=rdsamp('rec_1',1);
[tm2,sig_denoise_paper]=rdsamp('rec_1',2);

full_process(tm,sig,tm2,sig_denoise_paper);