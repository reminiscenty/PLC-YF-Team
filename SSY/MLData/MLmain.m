%--------------------------------------------------------------------------
% Project: Impulse noise suppression and arrival time estimation
% Author: ssy
% Date: 2020/2/21
%--------------------------------------------------------------------------
clear all; close all; clc;
%% Initialization of global parameters

%--------------------------------------------------------------------------
%                               simulation of PLC
%--------------------------------------------------------------------------
global Num INF;
Num = 2048;
INF = 1e1;
% about transmitter
global Fuc Fus beta Ndf Nhd Ngi Fsc N;		% ITU-G9660: PLC structure
Fus = 25e6; Fuc = 0; Fsc = 24.4140625e3;
N = Num; Ngi = N/32; Nhd = N/4; Ndf = N/4;
beta = N/8;
global Ts Rs;
Ts = 1.0/Fsc/N;
Rs = Fsc * N;
% preamble structure for power lines------p103
global N1 k1 N2 k2 N3 k3;
N1 = 7; k1 = 8;
N2 = 2; k2 = 8;
N3 = 0; k3 = INF;
global ZeroFre HighFre winLabel;
ZeroFre = 0;	HighFre = 0;	winLabel = false;
% frame structure
global l fraNum;
l = 1;		fraNum = 1;	

%--------------------------------------------------------------------------
% about channel
global  SNR SIR;
SNR = 20;   SIR = 0; % dB
global Pawgn Pim Psig PowerRatio;
PowerRatio = 2;
global lambda;
lambda = 1;
%--------------------------------------------------------------------------
% about receiver
global isSuppre isSegme;
isSuppre = false;   isSegme = false;
global suplabel CorrLabel;
suplabel = 1;   CorrLabel = 2;
global segnum;
segnum = 4;
global T Tmin k delta stepA stepT itertime;
T = 100;  Tmin = 1e-8;  
k = 100;  delta = 0.97;
stepA = 0.1;    stepT = 0.05;
itertime = 1;
global coefficient;
coefficient = 1/10;


%--------------------------------------------------------------------------
%                               test
%--------------------------------------------------------------------------
% about test1
global iteration;
iteration = 25;
global simple;      % three or two
simple = 3;
global delay;
delay = 0;

n = 1000;
p = zeros(n, N);
rsig = zeros(n,N);
rsig1 = zeros(n,N);
a = zeros(n,1);
t = zeros(n,1);
% sinr = zeros(151,151);
pn = zeros(151*151, 1000);
%% the Transmitter
tic;
for i = 1:1000
%     Trans = QAMgene(N);
%     Trans = Trans/sqrt(mean(Trans.^2));
    Trans = TransSig();
    p(i,:) = Trans;
    recie = ThrouChan(Trans');
    rsig(i,:) = recie;
end
toc;
%% 
tic;
i = 0; j = 0;
for a = 1:0.02:4
    for t = 0.5:0.02:3.5
        j = j + 1;
        rsig1(abs(rsig) < t) = rsig(abs(rsig) < t);
        rsig1(rsig > t) = t;
        rsig1(rsig < -t) = -t;
        rsig1(abs(rsig)> a*t) = 0;
        n0 = abs(p' - rsig1');
        pn(j,:) = sum(n0 .* n0);
    end
end
toc;
[pn_0,indexs] = min(pn);
a = floor((indexs-1)/151)*0.02+1;
t = (indexs - floor((indexs-1)/151)*151 -1)*0.02+0.5;
y = [a' t'];
sinr = 10*log10(N./pn_0);
sinr_0 = 10*log10(N./(sum((p'-rsig').^2)));
tr_sinr = mean(sinr(1:700));
tr_sinr0 = mean(sinr_0(1:700));
te_sinr = mean(sinr(701:1000));
te_sinr0 = mean(sinr_0(701:1000));
figure();
subplot(1,2,1);
histogram(a);
subplot(1,2,2);
histogram(t);


%% 
rsig2 = zeros(n,256);
p2 = zeros(n,256);
for i = 1:n
    [B0, I0] = sort(abs(rsig(i,:)),'descend');
    [B, I] = sort(I0(1:256), 'ascend');
    rsig2(i,:) = rsig(i,B);
    p2(i,:) = p(i,B);
end

%% the Receiver
%[Topt,aopt,t1,t2,t3,t4] = estTime(recie);

% the test
%% the test_1: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�����������룬����������������������к�ʱ�Լ���ʱ���
%test1(Trans');
%% the test_2: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�����������룬��������������������������
%test2(Trans');
%% the test_3: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�������������������������ʽ���������ʽ������
%test3(Trans');



