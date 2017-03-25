clear all 
close all 

addpath('ecgiddb')
N = 9; 
Fs = 500; 

[tm,sig]=rdsamp('ecgiddb/Person_03/rec_3',1);
[tm2,sig_denoise_paper]=rdsamp('ecgiddb/Person_03/rec_3',2);

%% Baseline Removal through High Pass Filter
% Below are the different filters attempted: (FOR REPORT DON'T DELETE)
% sig2 = cmddenoise(sig, 'db8', 9); 
% [c,l] = wavedec(sig,9,'db8');
% a0 = waverec(c,l,'db8');
% opol = 12;
% [p,s,mu] = polyfit(tm,sig,opol);
% f_y = polyval(p,tm,[],mu);
% sig2 = sig - f_y;

% This one performed the best!
fc_hp = 0.4;
[b_hp,a_hp] = butter(6,fc_hp/(Fs/2),'high');
sig2 = filter(b_hp,a_hp,sig);

%% Adaptive Bandstop Filter as per Paper
f0 = 50;                %#notch frequency
fn = Fs/2;              %#Nyquist frequency
freqRatio = f0/fn;      %#ratio of notch freq. to Nyquist freq.

notchWidth = 0.1;       %#width of the notch

%Compute zeros
notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];

%Compute poles
notchPoles = (1-notchWidth) * notchZeros;

b_bs = poly( notchZeros ); %# Get moving average filter coefficients
a_bs = poly( notchPoles ); %# Get autoregressive filter coefficients

sig3 = filter(b_bs,a_bs,sig2);

%% Lowpass Filter sa per paper
Wp = 40*2*pi; Ws = 60*2*pi; Rp = 0.1; Rs = 30; 
[n,Wn] = buttord(Wp,Ws,Rp,Rs,'s');
Wn = Wn/(Fs*2*pi/2);
[b,a] = butter(n,Wn);
sig4 = filter(b,a, sig3); 

%% Smoothing Filter as per Paper
sig5 = smooth(sig4,5); 

figure;
subplot(2,1,1); 
plot(tm, sig); hold on; grid on;
subplot(2,1,2)
plot(tm, sig5); hold on; grid on; 
plot(tm2, sig_denoise_paper); 
legend('Our De-Noised',' Paper De-Noised'); 

