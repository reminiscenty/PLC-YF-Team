function [T,a,corr1,toa1,corr2,toa2] = estTime(signal)
%estTime: to estimate the arrival time
%   
    [temp1,T,a] = suppre(signal);
    temp2 = signal;

    [corr1,toa1,corr2,toa2] = CorrCurv(temp1,temp2);
    
    %display
    display(corr1,corr2);
end

function [] = dispsupp(temp1,temp2)
    global Ts;
    t = 0:Ts:(length(temp1)-1)*Ts;
    figure;
    hold on;
    plot(t,temp1,t,temp2);
    set(gca,'XLim',[2e-4,2.02e-4]);
    legend('抑制','无抑制');
    xlabel('时间');   ylabel('相对幅度');
    title('抑制脉冲噪声');
    hold off;
end

function [] = display(corr1,corr2)
    global Ts;
    t = 0:Ts:(length(corr1)-1)*Ts;
    figure;
    hold on;
    title('相关峰');
    yyaxis left;
    plot(t,abs(corr1));     xlabel('时间');
    %set(gca,'XLim',[3.6e-4,3.85e-4]);
    ylabel('相对幅度1');
    yyaxis right;
    plot(t,abs(corr2));
    ylabel('相对幅度2');
    legend('消噪','无消噪');
    hold off;
end
