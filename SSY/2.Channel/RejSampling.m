function [] = RejSampling(argu)
    global Num;
    global sigma2 hyb k;
    len = length(sigma2);
    sig = sqrt(sigma2(5));
    z = normrnd(0,sig,1,argu);
    qz = 1/(sqrt(2*pi)*sig)*exp(-0.5*z.^2/sig^2);
    u = unifrnd(zeros(1,argu),k*qz);
    pz = normpdf(z',zeros(1,length(sigma2)),sqrt(sigma2));
    coef = repmat(hyb,length(z),1);
    PZ = sum((pz.*coef)');
    sample = z(PZ>=u);
    count = length(sample);
    
    %display_k(z,k*qz,PZ);
    %displayOUT(output);
    %displayVerify(z,PZ,output(1:count));
    global lambda implen;
    loc = exprnd(lambda,1,ceil(Num/lambda));
    loc = ceil(loc);
    output = zeros(1,Num);
    now = 1;
    for index = 1:length(loc)
        orde = randperm(count);
        temp = sample(orde(1:implen));
        output(1,now:now+implen-1) = output(1,now:now+implen-1) + temp;
        now = now + loc(index);
        if now + implen> Num
            break;
        end
    end
    output = awgn(output,30,'measured');
    plot(output);
    set(gca,'XLim',[0,4.5e4]);
    title('脉冲噪声');
    xlabel('离散时间');
    ylabel('幅度');
end

function [] = display_k(z,s,PZ)
    figure; hold on;
    plot(z,s,'c.');
    plot(z,PZ,'r.');
    legend('2.9×已知分布密度函数','目标分布密度函数');
    xlabel('采样点');
    ylabel('幅值');
    title('概率密度函数');
    hold off;
end

function [] = displayOUT(output)
    figure;     plot(output);
    xlabel('离散时间');
    ylabel('幅值');
    title('脉冲噪声');
    set(gca,'XLim',[2e3,2.4e3]);
end

function [] = displayVerify(z,PZ,output)
    figure; hold on;
    plot(z,PZ,'r.');
    % 计算分布
    delta = 0.01;
    slice = [-8:delta:8];
    len = length(slice);
    counting = zeros(1,len);
    for index = 1:length(output)
        temp = floor((output(index) + 8)/delta)+1;
        counting(temp) = counting(temp)+1;
    end
    plot(slice,counting/length(output)/delta);
    % 绘图
    legend('目标分布','采样分布');
    xlabel('采样点');
    ylabel('幅值');
    title('概率密度函数');
    hold off;
end
