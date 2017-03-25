%Reading filtered and unfiltered data in
[tm, signal]=rdsamp('rec_1',[],1000);
figure(1)
plot(tm,signal);
hold on

% Wavelet Drift Correction
[Lo_D,Hi_D,Lo_R,Hi_R] = wfilters('db8'); 
[c,l] = wavedec(signal(:,1),9,Lo_D,Hi_D);
X = wrcoef('a',c,l,Lo_R,Hi_R,9);
plot(tm, X,'m');

drift_correction = (signal(:,1)-X); 
plot(tm, drift_correction,'r');

%Adaptive Bandstop Filter
lower = (50*2*pi/250)/pi;
higher = (60*2*pi/250)/pi; %This value is probably wrong

[b,a] = butter(5,[lower higher],'stop'); %Not sure about the 5
bandstop = filter(b,a,drift_correction);
%plot(tm, bandstop,'k');


%Low Pass Filter
Wp = 40/250; %normalized nyquist frequency assuming samping of 500Hz
Ws = 60/250;
Rp = 0.1; %db
Rs = 30; %db

[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[low_b,low_a] = butter(n,Wn,'low');

lowpass = filter(low_b,low_a,bandstop);
%plot(tm, lowpass,'c');

%Smoothing
filtered = smooth(lowpass,'sgolay');
%plot(tm, filtered,'g');

hold off
legend('unfiltered','filtered','drift','bandstop','lowpass','mine');
