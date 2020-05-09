function [] = test3_3()
    %% generate
    global Num N Psig Pim Pawgn;
    sig2 = 1;
    Num = N;
	Psig = 1;
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 0;
    
    %% receiver
    global implen;
    n = 2.2*implen;
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
    
    %figure; plot(T,Fy);title('Fy');
    
    static = zeros(5,60,2);
    count = 1;
    for SIR = 0:5:20
        for iter = 1:60
            Psig = 1;
            Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
            global noiseLabel;
            noiseLabel = 3;
            noise0 = [];
            ofdm = normrnd(0,sqrt(sig2),1,N);   % 假设已知ofdm时域分布为高斯分布
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            
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
            
            variance = mean(recie.^2);
            noisepower = max(Num*(variance-sig2),0);
            % plan A
            su = 2*Num*Fs + 2*n*Fy - noisepower;    %figure; plot(T,su);title('总');
            [~,ind] = min(abs(su));
            Teva = T(ind);   % 0,5,10,15,20dB: 系数×2,1,4/5,2/3, 曲线拟合一下系数
            % plan B
            Psig = mean(ofdm.^2);
            global suplabel;
            suplabel = 1;       % 最优的
            global simple;
            simple = 2;
            [~,~,Tcom,~] = suppre(recie);
            % record
            static(count,iter,1) = Teva;
            static(count,iter,2) = Tcom;
            fprintf('SIR=%d,iter=%d\n',SIR,iter);
        end
        count = count + 1;
    end
    display(static);
end

function [] = display(static)
    evaluate = static(:,:,1)';
    optimal = static(:,:,2)';
    % 平均偏差
    aveERROR = zeros(1,size(evaluate,2));
    % 估计算法
    mea_evaluate = zeros(1,size(evaluate,2));
    var_evaluate = mea_evaluate;
    for index = 1:size(evaluate,2)      % 信干比
        all = [];
        count = 0;
        num = 0;
        for item = 1:size(evaluate,1)   % 每一次迭代
            if evaluate(item,index)<10
%                all = all + evaluate(item,index);
                all = [all,evaluate(item,index)];
                num = num + abs(evaluate(item,index) - optimal(item,index));
                count = count + 1;
            end
        end
        aveERROR(index) = num/count;
%        all = all/count;
        mea_evaluate(index) = mean(all);
        var_evaluate(index) = var(all);
    end
    % 最优值
    mea_opt = mean(optimal);
    var_opt = var(optimal);
    % 作图
%     figure; hold on;
%     plot([0:5:20],mea_evaluate,'-s','MarkerSize',10,'MarkerEdgeColor','blue','MarkerFaceColor',[0 .1 .95]);
%     plot([0:5:20],mea_opt,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]);
%     legend('估计值','最优值');
%     xlabel('SIR(dB)');
%     ylabel('value');
%     title('T参数估计值(两段式)');
%     set(gca,'XTick',[0:5:20],'YLim',[1.2,3.6]);
    figure; hold on;
    errorbar([0:5:20],mea_evaluate,var_evaluate,'r-o','MarkerSize',10,'LineWidth',1.3);
    errorbar([0:5:20],mea_opt,var_opt,'b-s','MarkerSize',10,'LineWidth',1.3);
    plot([0:5:20],aveERROR,'--k^','MarkerSize',10,'LineWidth',1.3);
    legend('估计值','最优值','平均估计偏差');
    xlabel('SIR(dB)');
    ylabel('value');
    title('T参数估计值(两段式)');
    set(gca,'XTick',[0:5:20],'YLim',[0,4]);
    hold off;
end
