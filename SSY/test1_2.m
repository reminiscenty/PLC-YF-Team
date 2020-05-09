function [T,a,corr1,toa1,corr2,toa2] = test1_2(signal)
%estTime: to estimate the arrival time
%   
    col = 0:5:20;
    row = 1:2;
    global SIR iteration suplabel Pim Psig Ts;    
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    
    index = 1;
    figure;
    for SIR = col
        subplot(2,3,index); index = index + 1;
        Pim = Psig*10^(-SIR/10);
        Temprecie = ThrouChan(signal);
        % directly go without suppression
        temp0 = Temprecie;
        % bruteforce
        suplabel = 1;
        [temp1,~,~,~] = suppre(Temprecie);
        [corr1,toa1,corr0,toa0] = CorrCurv(temp1,temp0);
        % simulational
        suplabel = 2;
        [temp2,~,~,~] = suppre(Temprecie);
        [corr2,toa2,~,~] = CorrCurv(temp2,temp0);
        % plot
        t = [0:Ts:(length(corr1)-1)*Ts];
        xlabel('ʱ��(us)');
        str = ['�Ÿɱ� ',num2str(SIR),'dB'];title(str);
        set(gca,'XLim',[3.5e-4,4.2e-4]);
        yyaxis left;
        plot(t,corr1,t,corr2,'k');
        ylabel('��Է���(����)');
        yyaxis right;
        plot(t,corr0);
        ylabel('��Է���(������)');
        legend('��������','ģ���˻�','������');
    end
end


