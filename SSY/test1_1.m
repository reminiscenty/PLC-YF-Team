function [T,a,corr1,toa1,corr2,toa2] = test1_1(signal)
%estTime: to estimate the arrival time
%   
    col = 0:5:20;
    row = 1:2;
    global SIR iteration suplabel Pim Psig Num;
    % T and a
    T_mean = zeros(iteration,length(col),length(row));     a_mean = T_mean;
    % evaluation of the Timing
    tim1 = T_mean;  tim2 = T_mean;
    % run time
    run = zeros(iteration,length(col),length(row));   
    
    noise0 = [];
    load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    
    for suplabel = row
        for SIR = col
            Pim = Psig*10^(-SIR/10);
            for index = 1:iteration
                impulse = ImpulGen(Num,noise0);
                Temprecie = ThrouChan(signal,impulse);
                [temp1,runtime,TempT,Tempa] = suppre(Temprecie);    temp2 = Temprecie;
                [corr1,toa1,corr2,toa2] = CorrCurv(temp1,temp2);
                % record
                T_mean(index,SIR/5+1,suplabel) = TempT;
                a_mean(index,SIR/5+1,suplabel) = Tempa;
                tim1(index,SIR/5+1,suplabel) = toa1;
                tim2(index,SIR/5+1,suplabel) = toa2;
                run(index,SIR/5+1,suplabel) = runtime;
            end
        end
    end
    %dispTa(T_mean,a_mean);
    dispTime(tim1,tim2);
    dispRuntime(run);
end

function [] = dispTa(T_mean,a_mean)
    global iteration
    %% relative error
    T_opt = mean(T_mean(:,:,1));
    a_opt = mean(a_mean(:,:,1));
    Tcurve1 = abs(mean(T_mean(:,:,2))-T_opt) ./ T_opt;
    acurve1 = abs(mean(a_mean(:,:,2))-a_opt) ./ a_opt;
    % plot
    figure;
    plot([0:5:20],Tcurve1,[0:5:20],acurve1);
    legend('������T��������','������a��������');
    title('10dB�������¸Ľ��㷨����������');
    set(gca,'YLim',[0,1],'XTick',[0:5:20]);
    xlabel('�Ÿɱ�(dB)');
    ylabel('���ֵ');
    %% MSE
    T_opt = mean(T_mean(:,:,1));
    a_opt = mean(a_mean(:,:,1));
    Tcurve = sum((T_mean(:,:,2)-repmat(T_opt,iteration,1)).^2) / iteration;
    %Tcurve = sqrt(Tcurve);
    acurve = sum((a_mean(:,:,2)-repmat(a_opt,iteration,1)).^2) / iteration;
    %acurve = sqrt(acurve);
    % plot
    figure;
    plot([0:5:20],Tcurve,[0:5:20],acurve);
    legend('������T�ľ�����','������a�ľ�����');
    title('10dB�������¸Ľ��㷨����������');
    set(gca,'YLim',[0,1],'XTick',[0:5:20]);
    xlabel('�Ÿɱ�(dB)');
    ylabel('���ֵ');
end

function [] = dispTime(tim1,tim2)
    global delay;
    tim2 = sum(tim2,3)/size(tim2,3);
    Tcurve1 = sqrt(mean((tim1(:,:,1)-delay).^2))*0.02;    %  ������
    Tcurve2 = sqrt(mean((tim1(:,:,2)-delay).^2))*0.02;    %  ģ���˻�
    Tcurve3 = sqrt(mean((tim2(:,:,1)-delay).^2))*0.02;    %  û����������
    %acurve = sqrt(acurve);
    % plot
    figure; hold on;
    plot([0:5:20],Tcurve1,'-s','MarkerSize',10,'MarkerEdgeColor','blue','MarkerFaceColor',[0 .1 .95]);
    plot([0:5:20],Tcurve2,'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]);
    plot([0:5:20],Tcurve3,'-s','MarkerSize',10,'MarkerEdgeColor','black','MarkerFaceColor',[0 .05 .05]);
    %plot([0:5:20],18494*ones(1,5),'--k');
    legend('������','ģ���˻�','����������','��ȷ��ʱ���');
    title('10dB������-��ʱͬ���������������');
    set(gca,'XTick',[0:5:20]);
    xlabel('�Ÿɱ�(dB)');
    ylabel('ʱ��(us)');
    hold off;
end

function [] = dispRuntime(runtime)
    figure;
    graphData = zeros(size(runtime,2),size(runtime,3));
    for index = 1:size(runtime,3)
        graphData(:,index) = mean(runtime(:,:,index))';
    end
    bar([0:5:20],graphData);
    legend('������','ģ���˻�');
    title('����ʱ��Ա�');
    xlabel('�Ÿɱ�(dB)');
    ylabel('��ɢʱ��');
    
end
