function [] = test3_2()
    %% generate
    global Num N Psig Pim Pawgn;
    sig2 = 1;
    Num = N;
	Psig = 1;
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 0;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 3;
    noise0 = [];
    impulse = ImpulGen(Num,noise0);
    %% receiver
    global implen;
    %variance = var(recie);
    
    %thres = max(sqrt(noisepower/implen),3*sqrt(sig2));     hold on;plot(ofdm);hold off;
    %n = length(find(thres<recie | -thres>recie));%min(length(find(thres<recie | -thres>recie)),8);
    % 假设信号的分布为高斯分布
    global sigma2 hyb;
    deltaT = 0.05;
    T = [0:deltaT:200*deltaT];
    ps = 1/(sqrt(2*pi)*sqrt(sig2))*exp(-0.5*T.^2/sqrt(sig2)^2);
    y2ps = T.^2.*ps;                                        %figure;plot(T,y2ps);title('y2ps');
    Fs = zeros(1,length(T));      % 反向 累计分布函数
    for index = length(T)-1:-1:1
        Fs(index) = Fs(index+1) + y2ps(index)*deltaT;
    end
    %figure; plot(T,Fs);title('Fs');
    % 假设脉冲的分布为混合高斯
    global scale;
    %scale = 1;
    py = normpdf((T/scale)',zeros(1,length(sigma2)),sqrt(sigma2));
    coef = repmat(hyb,length(T),1);
    y2py = 1/scale*T.^2.*sum((py.*coef)');
    %figure; plot(T,y2py);title('y2py');
    Fy = zeros(1,length(T));      % 反向 累计分布函数
    for index = length(T)-1:-1:1
        Fy(index) = Fy(index+1) + y2py(index)*deltaT;
    end
    %figure; plot(T,Fy);title('Fy');
    
    static = zeros(20,2);
    for iter = 1:200
        ofdm = normrnd(0,sqrt(sig2),1,N);   % 假设已知ofdm时域分布为高斯分布
        impulse = ImpulGen(Num,noise0);
        recie = ThrouChan(ofdm,impulse);

        variance = mean(recie.^2);
        noisepower = max(Num*(variance-sig2),0);
        % plan A
        n = 2*implen;
        su = 2*Num*Fs + 2*n*Fy - noisepower;    %figure; plot(T,su);title('总');
        [~,ind] = min(abs(su));
        Teva = T(ind);   % 0,5,10,15,20dB: 系数×2,1,4/5,2/3, 曲线拟合一下系数
        % plan B
        global suplabel;
        suplabel = 1;       % 最优的
        global simple;
        simple = 2;
        [~,~,Tcom,~] = suppre(recie);
        % record
        static(iter,1) = Teva;
        static(iter,2) = Tcom;
        %fprintf('n=%d,iter=%d\n',n,iter);
    end
end
