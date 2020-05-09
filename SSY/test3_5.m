function [] = test3_5()
    %% generate
    global Num N Psig Pim Pawgn;
    QAMseri = QAMgene(2*N);     % 4096
    ofdm = sqrt(2*N) * real(ifft(QAMseri,2*N));
    ofdm = ofdm';
    Num = length(ofdm);
	Psig = mean(1);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 20;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 4;     % 自己产生簇状脉冲噪声
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global iteration obserWIN Ts;
    obserWIN = 200;
    ofdm = ofdm(1:obserWIN);    Num = obserWIN;
    iteration = 30;
    range = 0:1:20;
    global suplabel simple;
    suplabel = 1;       % 最优的
    simple = 3;     % 三段式
    aTbase = cell(length(range)*iteration,8);
    
    global mu sigma implen EX2;
    tau = implen*Ts/4;
    omega = 20*pi/tau;
    start = 6;
    t = [0:Ts:(implen-1)*Ts];
    unit_ht = zeros(1,implen);
    unit_ht(1,1:start) = [1,-1,0.75,0.6,-0.7,0.5];
    temp = exp(-2*t/tau).*cos(omega*t);
    unit_ht(1,(start+1):end) =  0.3*temp(1:end-start);   unitPower = sum(unit_ht.^2);
    %plot(t,unit_ht);
    
    unit_ht = unit_ht(1,1:obserWIN);
    
    % 记录
    count = 1;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        
        for index = 1:iteration
            % 产生信号
            QAMseri = QAMgene(2*N);
            ofdm = sqrt(2*N) * real(ifft(QAMseri,2*N));
            ofdm = ofdm';
    %             obserWIN = 2048;
            ofdm = ofdm(1:obserWIN);
%             impulse = ImpulGen(Num,noise0);
            % 计算脉冲噪声
            if randi(2)==1
                amplitude = normrnd(mu,sigma,1,1);
            else
                amplitude = normrnd(-mu,sigma,1,1);
            end
            temp = amplitude * unit_ht;
            scale = 0.5 * sqrt(Pim*2048 / unitPower/EX2);
            impulse = temp * scale;
            impulse = awgn(impulse,30,'measured');
            recie = ThrouChan(ofdm,impulse);
            
            % 检测
%             for t = 1:length(recie)
%                 if((recie(t)>3.05 || recie(t)<-3.05) && mean(recie(t:t+1).^2)>=7)    % 大于3sigma，说明出现脉冲干扰
%                     break;
%                 end
%             end
%             if t+obserWIN-1<length(ofdm)
%                 OFDM = ofdm(1,t:t+obserWIN-1);
%                 recie = recie(1,t:t+obserWIN-1);
%                 [~,~,Tcom,acom] = suppre(OFDM,recie);
%             else
%                 OFDM = ofdm(1,t-obserWIN+1:t);
%                 recie = recie(1,t-obserWIN+1:t);
%                 Tcom = 3*1;
%                 acom = 1;
%             end
            %plot(ofdm); hold on; plot(impulse);hold off;
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            
            % 计算接收信号的一些特征量
            aTbase{(count-1)*iteration+index,1} = recie;           % 信号
            aTbase{(count-1)*iteration+index,2} = mean(abs(recie));% 信号绝对值 平均值
            aTbase{(count-1)*iteration+index,3} = var(recie);      % 信号方差
            aTbase{(count-1)*iteration+index,4} = max(abs(recie)); % 最大值
            aTbase{(count-1)*iteration+index,5} = sum(recie.^2);   % 总功率
            aTbase{(count-1)*iteration+index,6} = scale;           % scale
            aTbase{(count-1)*iteration+index,7} = acom;            % acom
            aTbase{(count-1)*iteration+index,8} = Tcom;            % Tcom
%           % 打印
            fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
        count = count + 1;
    end
    save aTbase.mat aTbase;
    % 对比一下？
    data = cell2mat(aTbase);     
    data = data(:,obserWIN+1:end);
    x1 = data(:,1);
    x2 = data(:,2);
    x3 = data(:,3);
    x4 = data(:,4);
    numSCALE = 13.3395-5.53064*x1-13.1858*exp(x2/4)+0.204*x3+0.0464*x4;
    numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
    numSIR = 10*log(1./numPim)/log(10);
%     numSCALE = -5.6193+4.9403*x1+0.0157*x4;
%     numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
%     numSIR = 10*log(1./numPim)/log(10);
end