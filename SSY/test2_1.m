function [] = test2_1()
    %% generate
    global Num N Psig Pim Pawgn;
    sig2 = 1;
    Num = N;
	Psig = 1;
    ofdm = normrnd(0,sqrt(sig2),1,N);   % ������֪ofdmʱ��ֲ�Ϊ��˹�ֲ�
    %% channel
    global SIR SNR;
    SNR = 30;
    global noiseLabel;
    noiseLabel = 3;
    noise0 = [];
    %% aT lib
    global iteration;
    iteration = 50;
    global suplabel simple;
    suplabel = 1;       % ���ŵ�
    simple = 3;     % ����ʽ
    c = cell(5*iteration,6);
    for SIR = 0:5:20
        Pim = Psig*10^(-SIR/10);
        fprintf('�Ÿɱ�Ϊ��%d\n',SIR);
        for index = 1:iteration
            impulse = ImpulGen(Num,noise0);
            recie = ThrouChan(ofdm,impulse);
            [~,~,Tcom,acom] = suppre(ofdm,recie);
            % ��������źŵ�һЩ������
            c{SIR/5*iteration+index,1} = recie;           % �ź�
            c{SIR/5*iteration+index,2} = mean(abs(recie));     % �źž���ֵ ƽ��ֵ
            c{SIR/5*iteration+index,3} = var(recie);      % �źŷ���
            c{SIR/5*iteration+index,4} = max(abs(recie)); % ���ֵ
            c{SIR/5*iteration+index,5} = Tcom;           %            
            c{SIR/5*iteration+index,6} = acom;           % a
            % ��ӡ
            fprintf('----������%d,T=%d,a=%d\n',index,Tcom,acom);
        end
    end
    save c.mat c;
    anly(c);
end

function [] = anly(data)
    %�źž���ֵ ƽ��ֵ + �źŷ��� + ���ֵ + T
    load c.mat c;
    data = cell2mat(c);     data = data(1:50,2049:end);
    y = data(:,5);        % a
    x1 = data(:,1);       % �źž���ֵ ƽ��ֵ
    x2 = data(:,2);       % �źŷ���
    x3 = data(:,3);       % ���ֵ  
    x4 = data(:,4);       % T
    %% ����
    % �������źž���ֵ ƽ��ֵ + �źŷ���
    X1 = [ones(size(y)) x1 x2];
    [b1,bint1,r1,rint1,stats1] = regress(y,X1);
    % �������źž���ֵ ƽ��ֵ + ���ֵ  
    X2 = [ones(size(y)) x1 x3];
    [b2,bint2,r2,rint2,stats2] = regress(y,X2);
    % �������źž���ֵ ƽ��ֵ + T
    X3 = [ones(size(y)) x1 x4];     % 1./log(x4)
    [b3,bint3,r3,rint3,stats3] = regress(y,X3);
    % �������źŷ��� + ���ֵ
    X4 = [ones(size(y)) x2 x3];
    [b4,bint4,r4,rint4,stats4] = regress(y,X4);
    % �������źŷ��� + T
    X5 = [ones(size(y)) x2 x4];
    [b5,bint5,r5,rint5,stats5] = regress(y,X5);
    % ���������ֵ + T
    X6 = [ones(size(y)) x3 x4];
    [b6,bint6,r6,rint6,stats6] = regress(y,X6);
    
    %% �ĸ�
    X = [ones(size(y)) x1 1./log(x2) 1./log(x3) 1./log(x4)];
    [b,bint,r,rint,stats] = regress(y,X);
    
    %% ����
    % �źž���ֵ ƽ��ֵ + �źŷ��� + T
    X_ = [ones(size(y)) x1 x2 x4];
    [b,bint,r,rint,stats] = regress(y,X_);
end