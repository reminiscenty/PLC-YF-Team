function [T,a,corr1,toa1,corr2,toa2] = test1_3(signal)
%estTime: to estimate the arrival time
%   
    col = 0:5:20;
    global SIR iteration suplabel Pim Psig simple;
    % 
    T_brute = zeros(iteration,length(col),2);
    T_simul = T_brute;
    
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    
    for SIR = col
        Pim = Psig*10^(-SIR/10);
        for index = 1:iteration
            Temprecie = ThrouChan(signal);
            %%  ����
            suplabel = 1;
            simple = 2;     % ����ʽ
            [temp1,~,~,~] = suppre(Temprecie);
            [~,toa,~,~] = CorrCurv(temp1,temp1);
            T_brute(index,SIR/5+1,simple-1) = toa;
            simple = 3;     % ����ʽ
            [temp1,~,~,~] = suppre(Temprecie);
            [~,toa,~,~] = CorrCurv(temp1,temp1);
            T_brute(index,SIR/5+1,simple-1) = toa;
            %% ģ���˻�
            suplabel = 2;
            simple = 2;     % ����ʽ
            [temp1,~,~,~] = suppre(Temprecie);
            [~,toa,~,~] = CorrCurv(temp1,temp1);
            T_simul(index,SIR/5+1,simple-1) = toa;
            simple = 3;     % ����ʽ
            [temp1,~,~,~] = suppre(Temprecie);
            [~,toa,~,~] = CorrCurv(temp1,temp1);
            T_simul(index,SIR/5+1,simple-1) = toa;
        end
    end

    %display
    global delay;
    figure;     hold on;
    % ������
    Tcurve1 = sqrt(mean((T_brute(:,:,1)-delay).^2))*0.02;
    Tcurve2 = sqrt(mean((T_brute(:,:,2)-delay).^2))*0.02;
    plot([0:5:20],Tcurve1,'--rs','MarkerSize',10,'LineWidth',1.6);
    plot([0:5:20],Tcurve2,'-rs','MarkerSize',10,'LineWidth',1.6);
    % ģ���˻�
    Tcurve3 = sqrt(mean((T_simul(:,:,1)-delay).^2))*0.02;
    Tcurve4 = sqrt(mean((T_simul(:,:,2)-delay).^2))*0.02;
    plot([0:5:20],Tcurve3,'--bs','MarkerSize',10,'LineWidth',1.6);
    plot([0:5:20],Tcurve4,'-bs','MarkerSize',10,'LineWidth',1.6);
    % others
    legend('�������� ����ʽ','�������� ����ʽ','ģ���˻� ����ʽ','ģ���˻� ����ʽ');
    title('����ʽ������ʽ����Ч���Ա�');
    set(gca,'XTick',[0:5:20]);
    xlabel('�Ÿɱ�(dB)');
    ylabel('ƽ�����ʱ��(us)');
ngdiend