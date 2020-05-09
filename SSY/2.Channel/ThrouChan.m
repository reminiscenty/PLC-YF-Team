function [withImpul] = ThrouChan(input,impulse)
%TransSig: the generation the Rx
%   
% delay
    global SNR Num;
% AWGN
    withAWGN = awgn(input,SNR,'measured');
% impulse noise
    withImpul = withAWGN + [impulse,zeros(1,length(withAWGN)-length(impulse))];
    %withImpul = withAWGN + RejSampling(2*Num);
% display
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




