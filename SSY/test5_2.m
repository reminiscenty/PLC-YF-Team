function [] = test5_2()
    %% 发送信号
    

    global iteration Pim Psig SIR SNR Num;
    iteration = 200;
    SNR = 5;
    range = [-10:1:5];
    coef = [1,1,1,1,1];

    carnoise =  load('D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\电瓶车\noise0.mat');
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
    inter = 3;
    multipath = [1,zeros(1,inter),-0.3,zeros(1,inter),0.2];
%     multipath =1;
    
    % 频偏
%     CFO = exp(1i*2*pi);
    
    % 正确定时结果
    rigTime = 18494;
    
    % 定时结果:1-估算 2-上帝视角降噪 3-不降噪
    static = zeros(iteration,length(range),3);
    global fraNum;
    count = 1;
    for SIR = range
        Pim = Psig*10^(-SIR/10);
        fprintf('信干比为：%d\n',SIR);
        for index = 1:iteration
            % 产生信号
            header = hea_gener();       % header of a certain frame
            payload = pay_gener();      % payload of a certain frame
            pream = AA_ASA();
            frame = frame_gener(pream,header,payload);
            load prefix.mat prefix;		prefix = prefix / sqrt(mean(prefix.^2));
            input0 = [prefix,repmat(frame,1,fraNum)];
            Num = length(input0);
            Psig = mean(input0.^2);
            Pim = Psig*10^(-SIR/10);
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
            t = [1:Num];
            figure;plot(t,input,t,co*tvnoise(1,start2:start2+Num-1),...
                t,co*wetnoise(1,start3:start3+Num-1),t,co*lednoise(1,start4:start4+Num-1),...
                t,co*foodnoise(1,start5:start5+Num-1));%t,input,t,co*carnoise(1,start:start+Num-1),
            legend('ofdm帧','机顶盒','加湿器','射灯','电饭煲');%'ofdm帧','电瓶车',
            xlabel('采样点');
            ylabel('幅度');
            title('脉冲干扰时域响应');
            % 对接收信号进行降噪
%             for t = 1:length(recie)
%                 if((recie(t)>3.05 || recie(t)<-3.05) && mean(recie(t:t+1).^2)>=7)    % 大于3sigma，说明出现脉冲干扰
%                     a = 1;
%                 end
%             end
            % 估计算法降噪
            x1 = mean(abs(recie));
            x4 = sum(recie.^2);
            output = -3.2 * x1 + 6.7e-6 * x4+5.58;
            estRecie = f(recie,output,1);
            % 降噪上帝视角
            [~,~,Tcom,acom] = suppre(input,recie);
            bestRecie = f(recie,Tcom,acom);
            % 不降噪
            global CorrLabel;
            CorrLabel = 3;
            [corr1,toa2,corr2,toa3] = CorrCurv(bestRecie,recie');    % 分别计算降噪和不降噪信号的定时结果
            [corr1,toa1,~,~] = CorrCurv(estRecie,estRecie); 
            %figure; hold on;plot(corr1);plot(corr2);legend('上帝视角降噪','无降噪');set(gca,'XLim',[18000,21500]);
            %figure; plot(bestRecie);figure;plot(recie');
            static(index,count,1) = toa1;
            static(index,count,2) = toa2;
            static(index,count,3) = toa3;
        end
        count = count + 1;
    end
    
    %% 绘图
    % 估计
    thres = 1000;
    optim1 = static(:,:,1);
    optim1 = optim1 - rigTime;
    optim1(abs(optim1)>=thres) = sign(optim1(abs(optim1)>=thres)) * thres;
%     mea_opt1 = mean(optim1);
    var_opt1 = mean(optim1.^2);
    % 上帝视角
    optim2 = static(:,:,2);
    optim2 = optim2 - rigTime;
    optim2(abs(optim2)>=thres) = sign(optim2(abs(optim2)>=thres)) * thres;
%     mea_opt2 = mean(optim2);
    var_opt2 = mean(optim2.^2);
    % 不降噪
    optim3 = static(:,:,3);
    optim3 = optim3 - rigTime;
    optim3(abs(optim3)>=thres) = sign(optim3(abs(optim3)>=thres)) * thres;
%     mea_opt3 = mean(optim3);
    var_opt3 = mean(optim3.^2);
    
    % 作图：图1表示估计结果errorbar
    figure; hold on;
%     errorbar(range,mea_opt1,var_opt1,'b-s','MarkerSize',10,'LineWidth',1.3);
%     errorbar(range,mea_opt2,var_opt2,'r-o','MarkerSize',10,'LineWidth',1.3);
%     errorbar(range,mea_opt3,var_opt3,'k-^','MarkerSize',10,'LineWidth',1.3);
    plot(range+4,sqrt(var_opt1)/10,'r-o','MarkerSize',10,'LineWidth',1.3);plot(range+4,sqrt(var_opt2)/10,'b-s','MarkerSize',10,'LineWidth',1.3);plot(range+4,sqrt(var_opt3)/10,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('提出方法','最优方法','无降噪');   %
    xlabel('SIR（dB）');
    ylabel('定时误差');
    title('ITU结构帧同步误差曲线');
    set(gca,'XTick',range+4,'YTick',[0:20:100]); % ,'YLim',[0.8,2.5]
    hold off;

end