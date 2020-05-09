function [] = test3_4()
    %% generate
    global Num N Psig Pim Pawgn;
    QAMseri = QAMgene(N);
    ofdm = sqrt(N) * real(ifft(QAMseri,N));
    ofdm = ofdm';
    Num = length(ofdm);
	Psig = mean(ofdm.^2);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 10;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 3;     % �Լ�������״��������
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global implen;
    % �����źŵķֲ�Ϊ��˹�ֲ�
    deltaT = 0.01;
    range = 5;
    T = [0:deltaT:range];
    ps = 1/(sqrt(2*pi))*exp(-0.5*T.^2);
    y2ps = T.^2.*ps;                                        figure;plot(T,y2ps);title('y2ps');
    Q2s = zeros(1,length(T));      % �ۼƷֲ�����
    for index = 2:length(T)
        Q2s(index) = Q2s(index-1) + y2ps(index-1)*deltaT;
    end
    figure; plot(T,Q2s);title('Q2s');
    % ��������ķֲ�Ϊ��ϸ�˹
    global scale sigma2 hyb;
    %scale = 1;
    py = normpdf((T/scale)',zeros(1,length(sigma2)),sqrt(sigma2));
    coef = (py.*repmat(hyb,length(T),1))';
    py = 1/scale*sum(coef);
    y2py = T.^2.*py;
    figure; plot(T,y2py);title('y2py');
    Q2y = zeros(1,length(T));      % �ۼƷֲ�����
    for index = 2:length(T)
        Q2y(index) = Q2y(index-1) + y2py(index-1)*deltaT;
    end
    figure; plot(T,Q2y);title('Q2y');
    % ��
    su = ps .* Q2y - py .* Q2s;    figure; plot(T,su);title('��');
    result = su(50:150);
    [~,ind] = min(abs(result));
    Teva = T(ind+50+1)   % 0,5,10,15,20dB: ϵ����2,1,4/5,2/3, �������һ��ϵ��
    
    %% best
     global suplabel;
     suplabel = 1;       % ���ŵ�
     global simple;
     simple = 2;
     [~,~,Tcom,~] = suppre(ofdm,recie)
end

