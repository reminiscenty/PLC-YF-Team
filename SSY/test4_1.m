function [] = test4_1()
    global Psig Pim Pawgn;
    global SIR SNR;
    SNR = 30;
    SIR = 20;
    global noiseLabel;
    noiseLabel = 1;
    
    %% �����ź�
    load probe_68.txt;
    len = length(probe_68);
    probe_68 = probe_68';
    Psig = mean(probe_68.^2);
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
    
    %% ������������
    load 'D:\Lab\HUWEIplc\3.pulseNoise\code\HUAWEInoise\��ƿ��\noise0.mat'
    noise = noise0';
    noise = ImpulGen(len,noise);  
    
    recie = ThrouChan(probe_68,noise);
    
%     range = [1:500000];
%     recie = recie(range);
%     probe_68 = probe_68(range);
%     noise = noise(range);
    plot(probe_68);hold on;plot(noise);     % ���ƽ��ն��ź�
    
    %% �洢�źŵ��ı�
    fid = fopen('probe.txt','wt');
    fprintf(fid,'%g\n',recie);
    fclose(fid);
    
    %% �Ÿ�������۷���
    global suplabel;
    global simple;
    suplabel = 1;
    simple = 3;
    %[~,~,Tcom,acom] = suppre(probe_68,recie);   % ����
    
    %% ���������۷���
    global stepA stepT;
    scaleA = 2:stepA:4;
    scaleT = 0.8:stepT:2;
    %MAX = max(abs(signal));
    BITRATE = zeros(length(scaleA),length(scaleT));
    for a_index = length(scaleA):-1:1
        for T_index = 1:length(scaleT)
            cmd = ['NoiseMitigation.exe probe 0 1 0 0 0 ',num2str(scaleA(a_index)),' ',num2str(scaleT(T_index))];
            dos(cmd);
            fid = fopen('probe_rate.txt');
            for i=1:2
                line=fgetl(fid);
            end
            fclose(fid);
            results = strsplit(line,',');
            for i=1:length(results)
                [~,rem] = strtok(results{i},'=');
                results{i} = rem(3:end);
            end
            BITRATE(a_index,T_index) = str2num(results{6});
            fprintf('----a=%d,T=%d\n',scaleA(a_index),scaleT(T_index));
        end
    end
    
    % 
    XVarNames = mat2cell(scaleT,[1,],ones(1,11));YVarNames = mat2cell(scaleA,[1,],ones(1,11));
    %matrixplot(BITRATE,'FillStyle','nofill','YVarNames',YVarNames,'XVarNames',XVarNames,'YVarNames',XVarNames,'TextColor','Auto','ColorBar','on');
    matrixplot(BITRATE,'XVarNames',XVarNames,'YVarNames',YVarNames,'TextColor',[0.6,0.6,0.6],'ColorBar','on');
    %% ��ͼ
    %[x] = Display(T,static);
end

function [xt] = Display(T,static)
    % ����������SINR��ͼ��
    figure;
    static = static(:,3:end);
    hold on;
    xt = zeros(1,size(static,1)); yt = xt;
    for index = 1:size(static,1)
    [~,loc] = max(static(index,:));
    value = static(index,loc);
    xt(index) = T(loc);
    yt(index) = value/max(static(index,:))*index;
    plot(T(3:end),static(index,:)/max(static(index,:))*index);
    end
    %str = '�ֲ���ֵ��';
    %text(xt,yt,str);
    plot(xt,yt,'*');
    xlabel('T');    ylabel('SINR');
    title('��ͬ�Ÿɱ��������������Ž������T');
    %     legend('SIR=0dB','SIR=1dB','SIR=2dB','SIR=3dB','SIR=4dB' ...
    %         ,'SIR=5dB','SIR=6dB','SIR=7dB','SIR=8dB','SIR=9dB' ...
    %         ,'SIR=10dB','SIR=11dB','SIR=12dB','SIR=13dB','SIR=14dB'...
    %         ,'Location','northeast','NumColumns',1);
    %     legend('SIR=14dB','SIR=13dB','SIR=12dB','SIR=11dB','SIR=10dB' ...
    %         ,'SIR=9dB','SIR=8dB','SIR=7dB','SIR=6dB','SIR=5dB' ...
    %         ,'SIR=4dB','SIR=3dB','SIR=2dB','SIR=1dB','SIR=0dB'...
    %         ,'Location','northeast','NumColumns',1);
    legend('14dB����','13dB����','12dB����','11dB����','10dB����' ...
    ,'  9dB����','  8dB����','  7dB����','  6dB����','  5dB����' ...
    ,'  4dB����','  3dB����','  2dB����','  1dB����','  0dB����'...
    ,'Location','northeast','NumColumns',1);
    set(gca,'XLim',[0,12]);
    hold off;
    
    % ����SINRͼ��
    figure;
    static = 10*log(static)/log(10);
    hold on;
    xt = zeros(1,size(static,1)); yt = xt;
    for index = 1:size(static,1)
        [~,loc] = max(static(index,:));
        value = static(index,loc);
        xt(index) = T(loc);
        yt(index) = value;
        plot(T(3:end),static(index,:));
    end
    %str = '�ֲ���ֵ��';
    %text(xt,yt,str);
    plot(xt,yt,'*');
    xlabel('T');    ylabel('SINR(dB)');
    title('��ͬ�Ÿɱ��������������Ž������T');
    %legend('����ֵ','����ֵ');
    legend('14dB����','13dB����','12dB����','11dB����','10dB����' ...
        ,'  9dB����','  8dB����','  7dB����','  6dB����','  5dB����' ...
        ,'  4dB����','  3dB����','  2dB����','  1dB����','  0dB����'...
        ,'Location','northeast','NumColumns',1);
    set(gca,'XLim',[0,12]);
    hold off;
end

