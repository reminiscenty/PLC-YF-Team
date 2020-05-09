function [] = test3_1()
    %% generate
    global Num N Psig Pim Pawgn;
    sig2 = 1;
    ofdm = normrnd(0,sqrt(sig2),1,N);   % ������֪ofdmʱ��ֲ�Ϊ��˹�ֲ�
    Num = length(ofdm);
	Psig = mean(ofdm.^2);
    %% channel
    global SIR SNR;
    SNR = 30;   SIR = 0;
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    global noiseLabel;
    noiseLabel = 3;
    noise0 = [];
    %load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    impulse = ImpulGen(Num,noise0);
    recie = ThrouChan(ofdm,impulse);
    %% receiver
    global implen;
    %variance = var(recie);
    variance = mean(recie.^2);
    noisepower = max(Num*(variance-sig2),0);
    thres = max(sqrt(noisepower/2/implen),3*sqrt(sig2));     hold on;plot(ofdm);hold off;
    n = length(find(thres<recie | -thres>recie));%min(length(find(thres<recie | -thres>recie)),8);
    % �����źŵķֲ�Ϊ��˹�ֲ�
    global sigma2 hyb;
    deltaT = 0.05;
    T = [0:deltaT:25*ceil(thres/deltaT)*deltaT];
    ps = 1/(sqrt(2*pi)*sqrt(sig2))*exp(-0.5*T.^2/sqrt(sig2)^2);
    y2ps = T.^2.*ps;                                        %figure;plot(T,y2ps);title('y2ps');
    Fs = zeros(1,length(T));      % ���� �ۼƷֲ�����
    for index = length(T)-1:-1:1
        Fs(index) = Fs(index+1) + y2ps(index)*deltaT;
    end
    %figure; plot(T,Fs);title('Fs');
    % ��������ķֲ�Ϊ��ϸ�˹
    global scale;
    %scale = 1;
    py = normpdf((T/scale)',zeros(1,length(sigma2)),sqrt(sigma2));
    coef = repmat(hyb,length(T),1);
    y2py = 1/scale*T.^2.*sum((py.*coef)');
    %figure; plot(T,y2py);title('y2py');
    Fy = zeros(1,length(T));      % ���� �ۼƷֲ�����
    for index = length(T)-1:-1:1
        Fy(index) = Fy(index+1) + y2py(index)*deltaT;
    end
    %figure; plot(T,Fy);title('Fy');
    % ��
    n = implen*2;
    su = 2*Num*Fs + 2*n*Fy - noisepower;    %figure; plot(T,su);title('��');
    [~,ind] = min(abs(su));
    Teva = T(ind)   % 0,5,10,15,20dB: ϵ����2,1,4/5,2/3, �������һ��ϵ��
    %% best
     global suplabel;
     suplabel = 1;       % ���ŵ�
     global simple;
     simple = 2;
     [~,~,Tcom,~] = suppre(recie)
end

% function [] = lower()
%     % û���źŽ׶�
%     noise = recie - ofdm;   % awgn + impulseNoise
%     P0 = noise.^2;  r0 = mean(P0);
%     beta0 = 3;  thres0 = beta0 * sqrt(r0);    figure;hold on;plot(recie);legend('�����ź�','����');
%     PI = noise(noise>thres0 | noise<-thres0);
%     %PI = zeros(size(noise));    PI(noise>thres0 | noise<-thres0) = noise(noise>thres0 | noise<-thres0);
%     % ���źŽ׶�
%     recie(noise>thres0 | noise<-thres0) = 0;
%     P1 = recie.^2;  r1 = mean(P1);
%     beta1 = 2.5;  thres1 = beta1 * sqrt(r1);
%     % ����
%     T = thres1; a = sqrt(mean(PI.^2)) / 8 / T;
%     
%     % �ϵ��ӽǱȽ�
%     global suplabel;
%     suplabel = 1;       % ���ŵ�
%     [~,~,Tcom,acom] = suppre(recie);
% end
