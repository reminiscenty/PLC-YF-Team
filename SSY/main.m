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
INF = 1e1;
% about transmitter
global Fuc Fus beta Ndf Nhd Ngi Fsc N;		% ITU-G9660: PLC structure
Fus = 25e6; Fuc = 0; Fsc = 24.4140625e3;
N = 2048; Ngi = N/32; Nhd = N/4; Ndf = N/4;
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
l = 3;		fraNum = 1;	

%--------------------------------------------------------------------------
% about channel
global  SNR SIR noiseLabel;
noiseLabel = 1;
SNR = 10;   SIR = 20; % dB
global Pawgn Pim Psig PowerRatio;
PowerRatio = 1;
% global A omega Jm;    % impulse noise
% A = 1.85;   omega = 0.02;   Jm = 7;
% global sigma2 hyb k;
% j = [0:Jm];
% k = 2.9;
% hyb = exp(-A)*power(A,j) ./ factorial(j);
% sigma2 = (j/A+omega)/(1+omega);
global lambda implen;
lambda = 800; implen = 1;%300;%ceil(lambda/3);
global scale;
global sigma mu EX2;
sigma = 0.0001;    mu = 1;
%sigma = 1;    mu = 0;
% deltaT = 0.01;
% t = [-10:deltaT:40];
% f = 1/(sqrt(2*pi)*sigma)*exp(-0.5*(t-mu).^2/sigma^2);
% t2f = t.^2.*f;
EX2 = mu^2 + sigma^2;
global obserWIN;
obserWIN = implen;
%--------------------------------------------------------------------------
% about receiver
global isSuppre isSegme;
isSuppre = false;   isSegme = false;
global suplabel CorrLabel;
suplabel = 1;   CorrLabel = 2;
global segnum;
segnum = 4;
global T Tmin delta stepA stepT itertime;
T = 100;  Tmin = 1e-8;  
delta = 0.99;
stepA = 0.2;    stepT = 0.2;
itertime = 1;
global coefficient;
coefficient = 1/4;


%--------------------------------------------------------------------------
%                               test
%--------------------------------------------------------------------------
% about test1
global iteration;
iteration = 15;
global simple;      % three or two
simple = 3;
global delay;
delay = 18494;

%% the Transmitter
% [Trans] = TransSig();    Trans = Trans';    RejSampling(10*Num);
% %% Through channel
% impulse = ImpulGen(Num);
% recie = ThrouChan(Trans,impulse);
% %% the Receiver
% [Topt,aopt,t1,t2,t3,t4] = estTime(recie);

% the test for Timing performance
%Trans = OFDMgene();
%% the test_1: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�����������룬����������������������к�ʱ�Լ���ʱ���
%test1_1(Trans);
%% the test_2: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�����������룬��������������������������
%test1_2(Trans);
%% the test_3: given SNR; different SIR from 0dB to 20dB with step of 5dB;
% �Ƚ�ģ���˻�������������������������ʽ���������ʽ������
%test1_3(Trans);

% the test for aT table
%test2_1();

% the test for evaluation
% ��ģ��
%test3_1();     % ���β���
%test3_2();     % ƽ��
%test3_3();      % �Ƚϲ�ͬ�Ÿɱ��µĹ������

% ��ģ�� �޸�SINR
%test3_4();     % ���Σ��޸�SINR�����Ժ��ն˵Ĺ����㷨��ƫ����

% ��һ���޸�ģ��Ϊ˫�߸�˹�ֲ����޸�SINR
% %test3_5();     % �Ӵ�����£�aT�������
%test3_6();     % �Ӵ� ��Ԫ�ع飬 ͨ���۲�s[n] ��scale���й���
%test3_7();      % �Ӵ� ��ͬ��scale(SIR)���ı�T����SINR����scale���T

% ����С����
%test4_1();

% ͬ��
%test5_1();  % ITU֡�ṹ��2dB���棩
test5_2();  % ��ITU�ṹ��3.5dB���棩


