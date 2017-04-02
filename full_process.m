function full_process(tm,sig,tm2,sig_denoise_paper)
    
    N = 9; 
    Fs = 500; 
    %% Baseline Removal through Polyfit
    % Below are the different filters attempted: (FOR REPORT DON'T DELETE)
    % sig2 = cmddenoise(sig, 'db8', 9); 
    % [c,l] = wavedec(sig,9,'db8');
    % cd9 = waverec(c,l,'db8'); 
    % a0 = waverec(c,l,'db8');
    % fc_hp = 0.35;
    % [b_hp,a_hp] = butter(6,fc_hp/(Fs/2),'high');
    % sig2 = filtfilt(b_hp,a_hp,sig); 
    % This one performed the best!
    opol = 12;
    [p,s,mu] = polyfit(tm,sig,opol);
    f_y = polyval(p,tm,[],mu);
    sig2 = sig - f_y;

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

    % figure;
    % ax1 = subplot(2,1,1); 
    % plot(tm, sig); hold on; grid on;
    % plot(tm, sig5); 
    % ax2 = subplot(2,1,2);
    % plot(tm, sig5, 'r'); hold on; grid on; 
    % plot(tm2, sig_denoise_paper); 
    % 
    % linkaxes([ax1, ax2], 'x'); 
    % legend('Our De-Noised',' Paper De-Noised'); 

    %% Feature Space
    % get the peak value and the peak location of R
    [pk,in] = findpeaks(sig_denoise_paper, 'MinPeakHeight',0.35);
    %Matlab 2014 has an error with findpeaks
    lk = tm2(in);

    %plot the R peaks
    % figure;
    % plot(tm2, sig_denoise_paper, lk, pk, 'ro');

    %Find Q point, this isn't a very good way to do it, I just used the R peak
    %as a refernce then I just went 30 samples back. The original signal was
    %too noises so matlabs findpeaks function was not reliable
    lk2 = tm2(in-30);
    pk2 = sig_denoise_paper(in-30);

    % [pk2,min_locs] = findpeaks(-sig_denoise_paper,'MinPeakDistance',90);
    % min_locs = tm2(min_locs);
    % for i = 1:length(pk2)
    %     if pk2(i)>0.09 || pk2(i)< 0.05 
    %         pk2(i) = 0;
    %         min_locs(i) = 0;
    %     end
    % end

    %plot the Q peaks
    % figure;
    % plot(tm2, sig_denoise_paper, lk2, pk2, 'ro');

    % chop the signal into samples
    sample = zeros(250,length(lk));

    % get just the peak indices
    [pk,lk] = findpeaks(sig_denoise_paper, 'MinPeakHeight',0.35);
    for i = 1:length(lk)
        % check if the sample we're taking exceeds the length of the signal
        if lk(i) + 169 > length(sig_denoise_paper)
            sample(1:(length(sig_denoise_paper) - lk(i) + 81),i) = sig_denoise_paper((lk(i) - 80):length(sig_denoise_paper));
        else
            sample(:,i) = sig_denoise_paper((lk(i) - 80):(lk(i) + 169));
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
    col_to_delete = 4; %number of columns to delete
    
    %delete last PQRST segment
    %sample(:,24) = [];
    sample(:,size(sample,2)-1) = [];
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
    figure;
    plot(x,sample);

end