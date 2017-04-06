function [x, sample] = full_process(tm,sig,tm2,sig_denoise_paper)
    N = 9; 
    Fs = 500; 
    %% Baseline Removal through Polyfit
%     [p,s,mu] = polyfit(tm,sig,12);
%     f_y = polyval(p,tm,[],mu);
%     sig2 = sig - f_y;
    [Lo_D,Hi_D,Lo_R,Hi_R] = wfilters('db8'); 
    [c,l] = wavedec(sig(:,1),9,Lo_D,Hi_D);
    X = wrcoef('a',c,l,Lo_R,Hi_R,9);
    sig2 = (sig(:,1)-X);
    
    %% Adaptive Bandstop Filter as per Paper
    f0 = 50;                %#notch frequency
    fn = Fs/2;              %#Nyquist frequency
    freqRatio = f0/fn;      %#ratio of notch freq. to Nyquist freq.

    notchWidth = 0.08;       %#width of the notch
    %Compute zeros
    notchZeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];
    %Compute poles
    notchPoles = (1-notchWidth) * notchZeros;

    b_bs = poly( notchZeros ); %# Get moving average filter coefficients
    a_bs = poly( notchPoles ); %# Get autoregressive filter coefficients

    sig3 = filtfilt(b_bs,a_bs,sig2);

    %% Lowpass Filter as per paper
    Wp = 40*2*pi; Ws = 60*2*pi; Rp = 0.1; Rs = 30; 
    [n,Wn] = buttord(Wp,Ws,Rp,Rs,'s');
    Wn = Wn/(Fs*2*pi/2);
    [b,a] = butter(n,Wn);
    sig4 = filtfilt(b,a, sig3); % Filtfilt does zero phase filtering 

    %% Smoothing Filter as per Paper
    sig5 = smooth(sig4,5); 
    
    sig_denoised = sig5; 
%     figure;
%     ax1 = subplot(2,2,1); 
%     plot(tm, sig); hold on; grid on;
%     plot(tm, sig2); 
%     legend('Raw Signal','Baseline Removed'); 
%     title('Wavelet Baseline Removal', 'FontSize', 16); 
%     
%     ax2 = subplot(2,2,2); 
%     plot(tm, sig2); hold on; grid on;
%     plot(tm, sig3); 
%     legend('Signal','Line Noise Removed'); 
%     title('Line Noise Removed Removal by Bandstop', 'FontSize', 16); 
%     
%     ax3 = subplot(2,2,3); 
%     plot(tm, sig3); hold on; grid on;
%     plot(tm, sig4); 
%     legend('Signal','Lowpass Filter'); 
%     title('High Frequency Noise Removal by Lowpass', 'FontSize', 16); 
%     
%     ax4 = subplot(2,2,4); 
%     plot(tm, sig4); hold on; grid on;
%     plot(tm, sig5); 
%     legend('Signal','Smoothed'); 
%     title('Smoothing', 'FontSize', 16); 
%     
%     linkaxes([ax1, ax2, ax3, ax4], 'x'); 
   
    clear sig2 sig3 sig4 sig5
    %% Feature Space
    peak_threshold = max(sig_denoised)*0.65; 
    % get the peak value and the peak location of R
    [pk,in] = findpeaks(sig_denoised, 'MinPeakHeight',peak_threshold);
    %Matlab 2014 has an error with findpeaks
    lk = tm(in);

    %plot the R peaks
%     figure;
%     plot(tm, sig_denoised, lk, pk, 'ro');

    % chop the signal into samples
    sample = zeros(250,length(lk));

    % get just the peak indices
    [pk,lk] = findpeaks(sig_denoised, 'MinPeakHeight',peak_threshold);
    for i = 2:length(lk) % Skip first
        % check if the sample we're taking exceeds the length of the signal
        if lk(i) + 169 > length(sig_denoised)
            sample(1:(length(sig_denoised) - lk(i) + 81),i) = sig_denoised((lk(i) - 80):length(sig_denoised));
        else
            sample(:,i) = sig_denoised((lk(i) - 80):(lk(i) + 169));
        end
    end

    %% Framingham formula
    %Put this before like Ning suggested

    %Find RR interval
    RR_interval = zeros(length(lk)-1,1);
    for i = 1: length(lk)-1
        RR_interval(i) = (lk(i+1) - lk(i))/500;
    end

    %Find QT interval
    QT_interval = 200/500; %Constant 30 before R peak and 170 after R peak
    QT_interval_cor = zeros(length(lk)-1,1);
    %Use Framingham Formula
    for i = 1: length(lk)-1
        QT_interval_cor(i) = QT_interval + 0.154*(1-RR_interval(i));
    end

    %Scale the length of the QT interval according to Framingham Formula
    x1 = zeros(length(QT_interval_cor),50);
    x2 = zeros(length(QT_interval_cor),200);
    for i = 1:length(QT_interval_cor)
        x1(i,:) = linspace(0,0.1,50);
        x2(i,:) = linspace(0.1,0.1+QT_interval_cor(i),200);
    end

    %Concatinate x matrices and plot with scaled QT intervals
    x = horzcat(x1,x2)';

    %% Removing the verticle shift
    %Find average of the columns and subract 
    sample_mean_col = mean(sample);
    for i = 1:length(lk)
        sample(:,i) = sample(:,i) - sample_mean_col(i);
    end

    %% Removing columns that are outliers (she removed 4)
    col_to_delete = int16(length(sample(1,:))*0.4); %number of columns to delete

    %delete last PQRST segment
    sample(:,length(sample(1,:))) = [];
    sample_mean_row = mean(sample,2); %taking mean of each row

    for k = 1:col_to_delete
        %finding the PQRST fragments that are the most wrong by adding the error
        error = zeros(length(lk)-k,1);
        for i = 1:(length(lk)-k)
            for j = 1:length(sample)
                error(i) = abs(sample(j,i) - sample_mean_row(j)) + error(i);
            end
        end
        %find indicies with the greatest error and deleting it
        [~,indices]=sort(error,'descend');
        sample(:,indices(1)) = [];
        x(:,indices(1)) = [];

    end
%     figure;
%     plot(x,sample);

end