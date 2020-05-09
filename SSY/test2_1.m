function [] = test2_1()
    %% generate
    global Num N Psig Pim Pawgn;
    sig2 = 1;
    Num = N;
	Psig = 1;
    ofdm = normrnd(0,sqrt(sig2),1,N);   % 假设已知ofdm时域分布为高斯分布
    %% channel
    global SIR SNR;
    SNR = 30;
    global noiseLabel;
    noiseLabel = 3;
    noise0 = [];
    %% aT lib
    global iteration;
    iteration = 50;
    global suplabel simple;
    suplabel = 1;       % 最优的
    simple = 3;     % 三段式
    c = cell(5*iteration,6);
    for SIR = 0:5:20
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            % 计算接收信号的一些特征量
            c{SIR/5*iteration+index,1} = recie;           % 信号
            c{SIR/5*iteration+index,2} = mean(abs(recie));     % 信号绝对值 平均值
            c{SIR/5*iteration+index,3} = var(recie);      % 信号方差
            c{SIR/5*iteration+index,4} = max(abs(recie)); % 最大值
            c{SIR/5*iteration+index,5} = Tcom;           %            
            c{SIR/5*iteration+index,6} = acom;           % a
            % 打印
            fprintf('----轮数：%d,T=%d,a=%d\n',index,Tcom,acom);
        end
    end
    save c.mat c;
    anly(c);
end

function [] = anly(data)
    %信号绝对值 平均值 + 信号方差 + 最大值 + T
    load c.mat c;
    data = cell2mat(c);     data = data(1:50,2049:end);
    y = data(:,5);        % a
    x1 = data(:,1);       % 信号绝对值 平均值
    x2 = data(:,2);       % 信号方差
    x3 = data(:,3);       % 最大值  
    x4 = data(:,4);       % T
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