function [preamble] = pream_gener()
    global winLabel PowerRatio;
	if winLabel==false
		preamble = pream_gener_noWIN();
	else
		preamble = pream_gener_WIN();
    end
     preamble = preamble ./ sqrt(mean(preamble.^2)/PowerRatio);
end

% with window
function [preamble] = pream_gener_WIN()
%pream_gener: To generator the preamble of the certain frame
%              for power lines
%   Reference: ITU-T G.9960 p89
%input: 
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global N1 k1 N2 k2 N3 k3;   % for generatoring preamble
    load pn.mat; pn = ans(1:N/k1);
%% do ifft
    PRE1 = zeros(1,N);
    PRE1(1:k1:end) = pn;
    pre1 = ifft(PRE1,N);   pre1 = pre1(1:N/k1);     pre1(1) = 0;    % time-domain payload
    pre2 = - pre1;
    pre3 = [];
%% generate of the look-up table
    TEMP = repmat(pre1,[1,4]).';  save 'TEMP.mat' 'TEMP';
    looup_table = zeros(4*N/k1,N/k1);   looup_table(:,1) = fft(TEMP,4*N/k1);
    for index = 2:N/k1
         col = fft([TEMP(index:end);TEMP(1:index-1)],4*N/k1);
         looup_table(:,index) = col;
    end
    %save '.\4.Receiver\looup_table.mat' 'looup_table';
%% adding cyclical extension to each preamble section
    sec1 = [pre1(end-beta/2+1:end),repmat(pre1,1,N1),pre1(1:beta/2)];
    sec2 = [pre2(end-beta/2+1:end),repmat(pre2,1,N2),pre2(1:beta/2)];
    sec3 = [];
%% Windowing
    % the first section
    len1 = 1.0*N/k1*N1 + beta;
    win = ones(len1,1);
    win(1:beta) = 1.0 / (beta+1) * [1:beta];
    win(len1-beta+1:end) = 1 - 1.0 / (beta+1) * [1:beta];
    winSEC1 = win .* sec1.';
    % the second section
    len2 = 1.0*N/k2*N2 + beta;
    win = ones(len2,1);
    win(1:beta) = 1.0 / (beta+1) * [1:beta];
    win(len2-beta+1:end) = 1 - 1.0 / (beta+1) * [1:beta];
    winSEC2 = win .* sec2.';
    % the third section
    len3 = 0;
    win = ones(len3,1);
    winSEC3 = win.*sec3.';
%% obtain total preamble structure
    preamble = zeros(len1-beta+len2,1);
    preamble(1:len1) = winSEC1;
    preamble(len1-beta+1:len1-beta+len2) = preamble(len1-beta+1:len1-beta+len2) + winSEC2;
% section three of preamble dosen't exist in power lines synchronization
    %preamble(len1-2*beta+len2+1:end) = preamble(len1-2*beta+len2+1:end) + winSEC3;
    % return value
    %preamble
%% display preamble structure in time domain
    %{
    figure;    hold on;
    plot(abs(preamble));
    set(gca,'xlim',[1,2800],'ylim',[0,0.02]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('preamble structure in time domain');
    legend('preamble');
%}
end

% without window
function [preamble] = pream_gener_noWIN()
%pream_gener: To generator the preamble of the certain frame
%              for power lines
%   Reference: ITU-T G.9960 p89
%input: 
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global N1 k1 N2 k2 N3 k3;   % for generatoring preamble
    load pn.mat; pn = output(1:N/k1);
%% do ifft
    PRE1 = zeros(1,N);
    PRE1(1:k1:end) = pn;
    pre1 = ifft(PRE1,N);   pre1 = pre1(1:N/k1);     pre1(1) = 0;    % time-domain payload
    pre2 = - pre1;
    pre3 = [];
%% generate of the look-up table
    TEMP = repmat(pre1,[1,4]).';  save 'TEMP.mat' 'TEMP';
    looup_table = zeros(4*N/k1,N/k1);   looup_table(:,1) = fft(TEMP,4*N/k1);
    for index = 2:N/k1
         looup_table(:,index) = fft([TEMP(index:end);TEMP(1:index-1)],4*N/k1);
    end
    save '.\looup_table.mat' 'looup_table';
%% adding cyclical extension to each preamble section
    sec1 = [repmat(pre1,1,N1)];
    sec2 = [repmat(pre2,1,N2)];
    sec3 = [];
%% obtain total preamble structure
    preamble = [sec1,sec2,sec3];
% section three of preamble dosen't exist in power lines synchronization
    %preamble(len1-2*beta+len2+1:end) = preamble(len1-2*beta+len2+1:end) + winSEC3;
    % return value
    %preamble
%% display preamble structure in time domain
    %{
    figure;    hold on;
    plot(abs(preamble));
    set(gca,'xlim',[1,2800],'ylim',[0,0.02]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('preamble structure in time domain');
    legend('preamble');
%}
end
