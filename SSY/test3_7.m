function [] = test3_7()
    %% generate
    global Num N Psig Pim Pawgn;
	Psig = mean(1);
    %% channel
    global SIR SNR;
    SNR = 30;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    %% receiver
    global obserWIN Ts;
    range = 0:1:14;
    
    global mu sigma implen EX2;
    obserWIN = 2*implen;
    tau = implen*Ts/1.4;
    omega = 40*pi/tau;
    start = 8;
    t = [0:Ts:(obserWIN-1)*Ts];
    unit_ht = zeros(1,obserWIN);
    %unit_ht(1,1:start) = [1,-1,0.45];
    unit_ht(1,1:start) = [1,-1,1,-0.7,0.75,-0.8,1,-0.7];
    temp = exp(-2*t/tau).*cos(omega*t);
    %temp = exp(-2*t/tau).*power(-1,floor(t/Ts));
    unit_ht(1,(start+1):end) =  0.6*temp(1:end-start);   unitPower = sum(unit_ht.^2);
    
    unit_ht = unit_ht(1:obserWIN);
    %plot(t,unit_ht);
    
    % 记录
    deltaT = 0.01;
    T = [0:deltaT:20];  
    static = zeros(length(range),length(T));
    NUMBER = 1;
    for SIR = range
        fprintf('信干比为：%d\n',SIR);
        Pim = Psig*10^(-SIR/10);
        scale = 0.5 * sqrt(Pim*2048 / unitPower/EX2);
       %% 计算信干噪比SINR
        % 有效信号
        px = 1/(sqrt(2*pi)*sqrt(Psig))*exp(-0.5*T.^2/sqrt(Psig)^2);
        x2px = T.^2 .* px;
        Fx = zeros(1,length(T));
        for index = 2:length(T)
            Fx(index) = Fx(index-1) + x2px(index-1)*deltaT;
        end
        realsig = 2*obserWIN*Fx;
        % 脉冲信号
        xrange = [0:deltaT:15];
        pr = 1/(sqrt(2*pi)*sigma*scale)*exp(-0.5*(xrange-mu*scale).^2/(sigma*scale)^2);
        noise = zeros(1,length(T));
        for index = 1:length(T)
            weight = zeros(size(pr));
            count = 1;
            for t = xrange
                temp = unit_ht(abs(unit_ht * t) <= T(index)) * t;
                weight(count) = sum(temp.^2);
                count = count + 1;
            end
            noise(index) = sum(weight.*pr) * deltaT;
        end
        % SINR
        result = realsig ./ noise;
        static(NUMBER,:) = result;
        NUMBER = NUMBER + 1;
    end
    
    %% 绘图
    [x] = Display(T,static);
    %% 拟合
    %approxim(x,y);
end

function [xt] = Display(T,static)
    % 均匀纵坐标SINR的图像
    figure;
    static = static(:,3:end);
    hold on;
    xt = zeros(1,size(static,1)); yt = xt;
    for index = 1:size(static,1)
    [~,loc] = max(static(index,:));
    value = static(index,loc);
    xt(index) = T(loc);
    yt(index) = value/max(static(index,:))*index;
    plot(T(3:end),static(index,:)/max(static(index,:))*index);
    end
    %str = '局部极值点';
    %text(xt,yt,str);
    plot(xt,yt,'*');
    xlabel('T');    ylabel('SINR');
    title('不同信干比脉冲噪声的最优降噪参数T');
    %     legend('SIR=0dB','SIR=1dB','SIR=2dB','SIR=3dB','SIR=4dB' ...
    %         ,'SIR=5dB','SIR=6dB','SIR=7dB','SIR=8dB','SIR=9dB' ...
    %         ,'SIR=10dB','SIR=11dB','SIR=12dB','SIR=13dB','SIR=14dB'...
    %         ,'Location','northeast','NumColumns',1);
    %     legend('SIR=14dB','SIR=13dB','SIR=12dB','SIR=11dB','SIR=10dB' ...
    %         ,'SIR=9dB','SIR=8dB','SIR=7dB','SIR=6dB','SIR=5dB' ...
    %         ,'SIR=4dB','SIR=3dB','SIR=2dB','SIR=1dB','SIR=0dB'...
    %         ,'Location','northeast','NumColumns',1);
    legend('14dB脉冲','13dB脉冲','12dB脉冲','11dB脉冲','10dB脉冲' ...
    ,'  9dB脉冲','  8dB脉冲','  7dB脉冲','  6dB脉冲','  5dB脉冲' ...
    ,'  4dB脉冲','  3dB脉冲','  2dB脉冲','  1dB脉冲','  0dB脉冲'...
    ,'Location','northeast','NumColumns',1);
    set(gca,'XLim',[0,12]);
    hold off;
    
    % 对数SINR图像
    figure;
    static = 10*log(static)/log(10);
    hold on;
    xt = zeros(1,size(static,1)); yt = xt;
    for index = 1:size(static,1)
        [~,loc] = max(static(index,:));
        value = static(index,loc);
        xt(index) = T(loc);
        yt(index) = value;
        plot(T(3:end),static(index,:));
    end
    %str = '局部极值点';
    %text(xt,yt,str);
    plot(xt,yt,'*');
    xlabel('T');    ylabel('SINR(dB)');
    title('不同信干比脉冲噪声的最优降噪参数T');
    %legend('估计值','最优值');
    legend('14dB脉冲','13dB脉冲','12dB脉冲','11dB脉冲','10dB脉冲' ...
        ,'  9dB脉冲','  8dB脉冲','  7dB脉冲','  6dB脉冲','  5dB脉冲' ...
        ,'  4dB脉冲','  3dB脉冲','  2dB脉冲','  1dB脉冲','  0dB脉冲'...
        ,'Location','northeast','NumColumns',1);
    set(gca,'XLim',[0,12]);
    hold off;
end

function [] = approxim(x,y)
    a = 1;
end
