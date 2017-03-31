% call process.m to get the wave forms
process

% find the squared absolute value to find only peaks
% https://www.mathworks.com/examples/wavelet/mw/wavelet-ex77408607-r-wave-detection-in-the-ecg

% get the peak value and the peak location
[pk,lk] = findpeaks(sig_denoise_paper, tm2, 'MinPeakHeight',0.35);
%plot the peaks
figure;
plot(tm2, sig_denoise_paper, lk, pk, 'ro');

% chop the signal into samples
sample = zeros(250,length(lk));

% get just the peak indices
[pk,lk] = findpeaks(sig_denoise_paper, 'MinPeakHeight',0.35);
for i = 1:length(lk)
    % check if the sample we're taking exceeds the length of the signal
    if lk(i) + 199 > length(sig_denoise_paper)
        sample(1:(length(sig_denoise_paper) - lk(i) + 51),i) = sig_denoise_paper((lk(i) - 50):length(sig_denoise_paper));
    else
        sample(:,i) = sig_denoise_paper((lk(i) - 50):(lk(i) + 199));
    end
end