%{
function [] = test3_6()
    %% generate
    global Num N Psig Pim Pawgn;
    %% channel
    global SIR SNR;
    SNR = 30; Pawgn = Psig*10^(-SNR/10);
    %% receiver
    global iteration obserWIN Ts;
    Num = obserWIN;
    iteration = 20;
    range = 0:1:7;
    global suplabel simple;
    suplabel = 1;       % 最优的
    simple = 3;     % 三段式
    aTbase = cell(length(range)*iteration,8);
    
    global mu sigma implen EX2;
    obserWIN = 2*implen;
    tau = implen*Ts/8;
    omega = 40*pi/tau;
    start = 2;
    t = [0:Ts:(obserWIN-1)*Ts];
    unit_ht = zeros(1,obserWIN);
    unit_ht(1,1:start) = [1,-1];
    temp = exp(-2*t/tau).*cos(omega*t);
    %temp = exp(-2*t/tau).*power(-1,floor(t/Ts));
    unit_ht(1,(start+1):end) =  0.5*temp(1:end-start);   unitPower = sum(unit_ht.^2);
    %plot(t,unit_ht);
    
    % 记录
    count = 1;
    static = zeros(iteration,length(range),3);
    % 产生信号
%     QAMseri = QAMgene(4*N);
%     ofdm = sqrt(4*N) * real(ifft(QAMseri,4*N));
%     ofdm = ofdm';
%     ofdm = ofdm(1:obserWIN);
%     ofdm = ofdm / sqrt(mean(ofdm.^2));
%     save ofdm.mat ofdm;
    load ofdm.mat ofdm;
    ofdm = [ofdm,ofdm];
    Psig = 1;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        
        for index = 1:iteration
            
%             impulse = ImpulGen(Num,noise0);
            % 计算脉冲噪声
%             if randi(2)==1
%                 amplitude = normrnd(mu,sigma,1,1);
%             else
%                 amplitude = normrnd(-mu,sigma,1,1);
%             end
            amplitude = normrnd(mu,sigma,1,1);
            temp = amplitude * unit_ht;
            scale = 0.5 * sqrt(Pim*2048 / unitPower/EX2);
            impulse = temp * scale;
            impulse = awgn(impulse,30,'measured');
            recie = ThrouChan(ofdm,impulse(1,1:obserWIN));
            
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
            [~,~,Tcom,~] = suppre(ofdm,recie);
            acom=1;
            static(index,count,1) = Tcom;    % 最优的
            % 统计量1——s[n]信干比
            static(index,count,2) = sta1(SIR);
            % 统计量2——s[n]观测值
            static(index,count,3) = sta2(recie);
            
            % 计算接收信号的一些特征量
            aTbase{(count-1)*iteration+index,1} = recie;           % 信号
            aTbase{(count-1)*iteration+index,2} = mean(abs(recie));% 信号绝对值 平均值
            aTbase{(count-1)*iteration+index,3} = var(recie);      % 信号方差
            aTbase{(count-1)*iteration+index,4} = max(abs(recie)); % 最大值
            aTbase{(count-1)*iteration+index,5} = sum(recie.^2);   % 总功率
            aTbase{(count-1)*iteration+index,6} = SIR;           % scale
            aTbase{(count-1)*iteration+index,7} = acom;            % acom
            aTbase{(count-1)*iteration+index,8} = Tcom;            % Tcom
%             % 打印
             fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
        count = count + 1;
    end
    save aTbase.mat aTbase;
    
    %% 绘图
    Display(range,static);
    
    %% 多元回归
    anly();
    %% 估计
    data = aTbase(:,obserWIN+1:end);
    x1 = data(:,1);
    x2 = data(:,2);
    x3 = data(:,3);
    x4 = data(:,4);
    numSCALE = 13.3395-5.53064*x1-13.1858*exp(x2/4)+0.204*x3+0.0464*x4;
    numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
    numSIR = 10*log(1./numPim)/log(10);

end

%}
function [] = test3_6()
    global iteration Pim Psig SIR SNR Num;
    SNR = 5;
    range = [-8:2:0];
    coef = [1,1,1,1,1];

    carnoise = load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat');
    carnoise = carnoise.noise0;
    carnoise = coef(1) * carnoise(1:4:end)';
    tvnoise = load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\机顶盒\noise0.mat');
    tvnoise = tvnoise.noise;
    tvnoise = coef(2) * tvnoise(1:4:end)';
    wetnoise = load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\加湿器\noise0.mat');
    wetnoise = wetnoise.noise;
    wetnoise = coef(3) * wetnoise(1:4:end)';
    lednoise = load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\射灯\noise0.mat');
    lednoise = lednoise.noise;
    lednoise = coef(4) * lednoise(1:4:end)';
    foodnoise = load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\苏泊尔电饭煲\noise0.mat');
    foodnoise = foodnoise.noise0;
    foodnoise = coef(5) * foodnoise(1:4:end)';

    % 多径信道
    inter = 4;
    multipath = [1,zeros(1,inter),-0,8,zeros(1,inter),0.6,zeros(1,inter),-0.4];
%     multipath =1;
    
    % 频偏
%     CFO = exp(1i*2*pi);
    
    % 正确定时结果
    rigTime = 18494;
    
    % 定时结果:1-估算 2-上帝视角降噪 3-不降噪
    static = zeros(iteration,length(range),3);
    
    count = 1;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        
        for index = 1:iteration
            [input0] = TransSig();
            % 噪声
            impul = zeros(1,Num);
%             start1 = randi(1000)+200000;
%             impul = impul + carnoise(1,start1:start1+Num-1);
            start2 = randi(10)+450000;
            impul = impul + tvnoise(1,start2:start2+Num-1);
            start3 = randi(10)+450000;
            impul = impul + wetnoise(1,start3:start3+Num-1);
            start4 = randi(10)+450000;
            impul = impul + lednoise(1,start4:start4+Num-1);
            start5 = randi(10)+450000;
            impul = impul + foodnoise(1,start5:start5+Num-1);
            % 归一化噪声
            co = sqrt(Pim/mean(impul.^2));
            impul = impul * co;
            % 过信道
            recie0 = ThrouChan(input0,impul);
            recie = conv2(recie0,multipath);
            recie = recie(1:length(recie0));
            recie = recie * sqrt(mean(recie0.^2) / mean(recie.^2));
            % 真实信号
            input = conv2(input0,multipath);
            input = input(1:length(recie0));
            input = input * sqrt(mean(input0.^2) / mean(input.^2));
            
            [~,~,Tcom,acom] = suppre(input,recie);

%             static(index,count,1) = Tcom;    % 最优的
%             % 统计量1——s[n]信干比
%             static(index,count,2) = sta1(SIR);
%             % 统计量2——s[n]观测值
%             static(index,count,3) = sta2(recie);
            
            % 计算接收信号的一些特征量
            aTbase{(count-1)*iteration+index,1} = recie;           % 信号
            aTbase{(count-1)*iteration+index,2} = mean(abs(recie));% 信号绝对值 平均值
            aTbase{(count-1)*iteration+index,3} = var(recie);      % 信号方差
            aTbase{(count-1)*iteration+index,4} = max(abs(recie)); % 最大值
            aTbase{(count-1)*iteration+index,5} = sum(recie.^2);   % 总功率
            aTbase{(count-1)*iteration+index,6} = SIR;           % scale
            aTbase{(count-1)*iteration+index,7} = acom;            % acom
            aTbase{(count-1)*iteration+index,8} = Tcom;            % Tcom
%             % 打印
             fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
        count = count + 1;
    end
    save aTbase.mat aTbase;
    
    %% 绘图
%     Display(range,static);
    
    %% 多元回归
    anly();
    %% 估计
%     data = aTbase(:,obserWIN+1:end);
%     x1 = data(:,1);
%     x2 = data(:,2);
%     x3 = data(:,3);
%     x4 = data(:,4);
%     numSCALE = 13.3395-5.53064*x1-13.1858*exp(x2/4)+0.204*x3+0.0464*x4;
%     numPim = unitPower * EX2 * (2*numSCALE).^2/2048;
%     numSIR = 10*log(1./numPim)/log(10);

end

function [output] = sta1(sir)
    output = 1.1161+0.1085*sir;
end
function [output] = sta2(signal)
    x3 = max(abs(signal));
    x4 = sum(signal.^2);
    sir = -2.578 * x3+0.0296 * x4+14.3653;
    output = 1.1161+0.1085*sir;
end

function [] = Display(range,static)
    % 最优
    optim1 = static(:,:,1);
    mea_opt1 = mean(optim1);
    var_opt1 = var(optim1);
    % 知道信干比
    optim2 = static(:,:,2);
    mea_opt2 = mean(optim2);
    var_opt2 = var(optim2);
    % 只知道观测量
    optim3 = static(:,:,3);
    mea_opt3 = mean(optim3);
    var_opt3 = var(optim3);
    
    % 作图：图1表示估计结果errorbar
    figure; hold on;
    errorbar(range,mea_opt1,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    errorbar(range,mea_opt2,var_opt2,'r-o','MarkerSize',10,'LineWidth',1.3);
    errorbar(range,mea_opt3,var_opt3,'k-^','MarkerSize',10,'LineWidth',1.3);
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('最优值','通过SIR估计','通过s[n]估计');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T参数估计值(两段式)');
    set(gca,'XTick',range,'YLim',[0.8,2.5]);
    hold off;
    
    % 作图：图2表示方差性能曲线
    var2 = sum(abs(optim2-optim1)) + var_opt1;
    figure; hold on;
    plot(range,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
    plot(range,var2,'r-o','MarkerSize',10,'LineWidth',1.3);
    %plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('最优值','线性组合估计值');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T参数估计值(两段式)');
    set(gca,'XTick',range,'YLim',[0,4]);
    hold off;
end

function [] = anly()
    global obserWIN;
    %信号绝对值 平均值 + 信号方差 + 最大值 + T
    load aTbase.mat aTbase;
    data = cell2mat(aTbase);     
    data = data(:,obserWIN+1:end);   %
    y = data(:,7);        % scale
    x1 = data(:,1);       % 信号绝对值 平均值
    x2 = data(:,2);       % 信号方差
    x3 = data(:,3);       % 最大值  
    x4 = data(:,4);       % 平均a功率
    %% 两个
    % 两个：信号绝对值 平均值 + 信号方差
    X1 = [ones(size(y)) x1 x2];
    [b1,bint1,r1,rint1,stats1] = regress(y,X1);
    % 两个：信号绝对值 平均值 + 最大值  
    X2 = [ones(size(y)) x1 x3];
    [b2,bint2,r2,rint2,stats2] = regress(y,X2);
    % 两个：信号绝对值 平均值 + T
    X3 = [ones(size(y)) x1 x4];     % 1./log(x4)
    [b3,bint3,r3,rint3,stats3] = regress(y,X3);
    % 两个：信号方差 + 最大值
    X4 = [ones(size(y)) x2 x3];
    [b4,bint4,r4,rint4,stats4] = regress(y,X4);
    % 两个：信号方差 + T
    X5 = [ones(size(y)) x2 x4];
    [b5,bint5,r5,rint5,stats5] = regress(y,X5);
    % 两个：最大值 + T
    X6 = [ones(size(y)) x3 x4];
    [b6,bint6,r6,rint6,stats6] = regress(y,X6);
    
    %% 四个
    X = [ones(size(y)) x1 1./log(x2) 1./log(x3) 1./log(x4)];
    [b,bint,r,rint,stats] = regress(y,X);
    
    %% 三个
    % 信号绝对值 平均值 + 信号方差 + T
    X_ = [ones(size(y)) x1 x2 x4];
    [b,bint,r,rint,stats] = regress(y,X_);
end