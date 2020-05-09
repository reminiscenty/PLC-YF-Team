function [withImpul] = ThrouChan(input)
%TransSig: the generation the Rx
%   
% delay
    global SNR N;
% AWGN
    withAWGN = awgn(input,SNR,'measured');
% impulse noise
    withImpul = withAWGN + ImpulGen(N);
    %displayChal(input,withAWGN,withImpul);
end
%% display
function [output] = displayChal(input,withAWGN,withImpul)
    global Ts;
    t = 0:Ts:(length(input)-1)*Ts;
    figure;
    hold on;
    plot(t,input,t,withAWGN,t,withImpul);
    set(gca,'XLim',[2e-4,2.1e-4]);
    legend('发端信号','附加高斯白噪声','再附加脉冲噪声');
    xlabel('时间');   ylabel('相对幅度');
    title('信道对信号的影响');
    hold off;
end

%% impulse noise by manually
function [impulse] = ImpulGen(num)
%ImpulGen: the generation the Impulse noise
%   
    global Pim Rs N;
    impulNum = randi(floor(num/3)) + num/3;
    impulse = zeros(num,1);
    % impulse 1
    start1 = randi(100);
    %step1 = floor(1e-6*Rs);
    step1 = floor(num/5);
    matr1 = start1:step1:min(start1+step1*(impulNum/2),num);
    impulse(matr1) = impulse(matr1) + rand(length(matr1),1)-0.5;
    % impulse 2
    start2 = randi(100);
    step2 = floor(3e-6*Rs);
    matr2 = start2:step2:min(start2+step2*(impulNum/3),num);
    %impulse(matr2) = impulse(matr2) + rand(length(matr2),1)-0.5;
%% normalization with SIR
    tempLen = length(matr1) + length(matr2);
    impulse = impulse * sqrt(Pim / sum(impulse.^2)*N);
end

%% impulse noise by Huawei
function [impulse] = car(num)
    a = 1;
end
