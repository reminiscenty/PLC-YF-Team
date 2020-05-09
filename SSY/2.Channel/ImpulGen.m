function [output] = ImpulGen(num,ori)
    global noiseLabel;
    if noiseLabel == 1      % 手动生成
        output = manual(num);
    elseif noiseLabel==2    % 华为数据
        output = car(num,ori);
    elseif noiseLabel==3    % 拒绝采样，混合高斯
        output = RejSampling(3*num);
    elseif noiseLabel==4    % 双边高斯，滤波器
        output = BYht(num);
    end
end

%% impulse noise by manually
function [impulse] = manual(num)
%ImpulGen: the generation the Impulse noise
%   
    global Pim Rs;
    impulNum = randi(floor(num/3)) + num/3;
    impulse = zeros(num,1);
    % impulse 1
    start1 = randi(100);
    step1 = floor(1e-6*Rs);
    matr1 = start1:step1:min(start1+step1*(impulNum/2),num);
    impulse(matr1) = impulse(matr1) + rand(length(matr1),1)-0.5;
    % impulse 2
    start2 = randi(100);
    step2 = floor(3e-6*Rs);
    matr2 = start2:step2:min(start2+step2*(impulNum/3),num);
    impulse(matr2) = impulse(matr2) + rand(length(matr2),1)-0.5;
%% normalization with SIR
    impulse = impulse * sqrt(Pim / sum(impulse.^2)*num);
    impulse = impulse';
end

%% impulse noise by Huawei
function [impulse] = car(num,ori)
    global Pim;
    start = randi(1000);    %1000;%
    temp = 1;
    impulse = ori(start:temp:start+temp*(num-1));
    impulse = impulse * sqrt(Pim / mean(impulse.^2));
end

%% impulse noise by possion process
function [output] = RejSampling(argu)
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
    %loc = exprnd(lambda,1,ceil(Num/lambda));
    loc = 900*ones(1,ceil(Num/lambda));
    loc = ceil(loc);
    output = zeros(1,Num);
    now = 1;
    for index = 1:length(loc)
        now = now + loc(index);
        if now + implen> Num
            break;
        end
        orde = randperm(count);
        temp = sample(orde(1:implen));
        output(1,now:now+implen-1) = output(1,now:now+implen-1) + temp;
    end
    global Pim scale SIR;
    %Pim*Num = 2*implen*scale^2;
%     if SIR == 0
%         pow = 20;
%     end
    scale = sqrt(Pim*Num / 2/implen);
    %scale = sqrt(Pim / mean(output.^2));
    output = output * scale;
    output = awgn(output,30,'measured');
    
%     figure;
%     plot(output);
%     %set(gca,'XLim',[0,4.5e4]);
%     title('脉冲噪声');
%     xlabel('离散时间');
%     ylabel('幅度');
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

%% impulse noise by filter h(t)
function [output] = BYht(argu)
    global sigma mu;
    global Num Ts;
    global implen;
    %loc = exprnd(lambda,1,ceil(Num/lambda));
%     start = randi(50)+150;
%     loc = [start,230,770,230];
    loc = repmat([230*4,770*4],1,ceil(argu/4000));
    Num = argu;
    output = zeros(1,Num);
    now = 1;
    Ts = Ts / 4;
    tau = 0.6*implen*Ts;
    omega = 120*pi/tau;
    t = [0:Ts:(implen-1)*Ts];
    start = 4;
    unit_ht = zeros(1,implen);
    unit_ht(1,1:start) = [1,-1,0.65,-0.5];
    temp = exp(-2*t/tau).*cos(omega*t);
    unit_ht(1,(start+1):end) = 0.7*temp(1:end-start);
    unitPower = sum(unit_ht.^2);
    for index = 1:length(loc)
        now = now + loc(index);
        if now + implen> Num
            break;
        end
        amplitude = normrnd(mu,sigma,1,1);
        temp = amplitude * unit_ht;
        output(1,now:now+implen-1) = output(1,now:now+implen-1) + temp;
    end

    global Pim scale EX2;
%     scale = 0.5*sqrt(Pim*Num / unitPower/EX2);

    scale = sqrt(Pim / mean(output.^2));
    output = output * scale;
    output = awgn(output,30,'measured');
    
%     figure;
%     plot(output);
%     %set(gca,'XLim',[0,4.5e4]);
%     title('脉冲噪声');
%     xlabel('离散时间');
%     ylabel('幅度');
end
