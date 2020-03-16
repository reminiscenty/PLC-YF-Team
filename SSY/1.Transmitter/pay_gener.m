function [payload] = pay_gener()
%pay_gener: To generator the payload of the certain frame
%              for power lines
%   Reference: ITU-T G.9960 p89
%   mapping: 4QAM
	global winLabel;
	if winLabel==false
		payload = pay_gener_noWIN();
	else
		payload = pay_gener_WIN();
    end
    payload = payload ./ sqrt(mean(payload.^2));
end
function [payload] = pay_gener_WIN()
	%input: 
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global l;
%% cut off the payload into blocks and do ifft respectively
    PAY = QAMgene(N*(l-1));
    PAY = reshape(PAY,N,l-1);
    pay = ifft(PAY,N);  pay(1,:) = zeros(1,l-1);    % time-domain payload
    %pay = reshape(pay,1,N*(l-1));
%% adding the CP to OFDM block
    % the first two symbols of the payload------p89
    firPay = pay(:,[1:2]);
    Ncp_1 = Ndf + beta;
    cp1 = firPay(N-Ncp_1+1:end,:);
    CP_firPay = [cp1;firPay];
    % the rest of the payload symbols------p89
    secPay = pay(:,[3:end]);
    Ncp_2 = Ngi + beta;
    cp2 = secPay(N-Ncp_2+1:end,:);
    CP_secPay = [cp2;secPay];
%% Windowing
    % the first two payload
    len1 = N+Ncp_1;
    win_1 = ones(len1,1);
    win_1(1:beta) = 1.0 / (beta+1) * [1:beta];
    win_1(len1-beta+1:end) = 1 - 1.0 / (beta+1) * [1:beta];
    winOFDM_1 = win_1 .* CP_firPay;
    % the rest fo the payload
    len2 = N+Ncp_2;
    win_2 = ones(len2,1);
    win_2(1:beta) = 1.0 / (beta+1) * [1:beta];
    win_2(len2-beta+1:end) = 1 - 1.0 / (beta+1) * [1:beta];
    winOFDM_2 = win_2 .* CP_secPay;
    % display first payload symbol
    %{
    figure;    hold on;
    plot(abs(winOFDM_1(:,1)));
    set(gca,'xlim',[1,2850],'ylim',[0,0.05]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('first payload structure in time domain');
    legend('payload');
%}
%% overlap and add
    len = (2 * len1 - beta) + (l-3) * (len2 - beta);
    payload = zeros(len,1);
    % add
    payload(1:len1) = winOFDM_1(:,1);
    payload(len1-beta+1:2*len1-beta) = payload(len1-beta+1:2*len1-beta) + winOFDM_1(:,2);
    for index = 1:l-3
        start = 2*len1-2*beta+1+(index-1)*(len2-beta);
        payload(start:start-1+len2) = payload(start:start-1+len2) + winOFDM_2(:,index);
    end
    % return value
    %payload;
%% dispaly payload structure in time domain
    %{
    figure;    hold on;
    subplot(1,2,1);
    plot(abs(payload));
    set(gca,'xlim',[1,6000],'ylim',[0,0.04]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('payload structure in time domain');
    legend('payload');
    subplot(1,2,2);
    wp = 0.05;
    plot(lowpass(abs(payload),wp));
    set(gca,'xlim',[1,6000],'ylim',[0,0.025]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('payload with lowpass filter');
    legend('filtered payload');
%}
end

function [payload] = pay_gener_noWIN()
	%input: 
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global l;
%% cut off the payload into blocks and do ifft respectively
    PAY = [];
	for index = 1:l-1
		PAY = [PAY,QAMgene(N)'];
	end
    pay = ifft(PAY,N);  pay(1,:) = zeros(1,l-1);    % time-domain payload
    %pay = reshape(pay,1,N*(l-1));
%% adding the CP to OFDM block
    % the first two symbols of the payload------p89
    firPay = pay(:,[1:2]);
    Ncp_1 = Ndf + beta;
	len1 = N+Ncp_1;
    cp1 = firPay(N-Ncp_1+1:end,:);
    CP_firPay = [cp1;firPay];
    % the rest of the payload symbols------p89
    secPay = pay(:,[3:end]);
    Ncp_2 = Ngi + beta;
	len2 = N+Ncp_2;
    cp2 = secPay(N-Ncp_2+1:end,:);
    CP_secPay = [cp2;secPay];
%% overlap and add
    payload = reshape(CP_firPay,1,[]);
	payload = [payload,reshape(CP_secPay,1,[])];
end