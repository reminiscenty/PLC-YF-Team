function [frame] = frame_gener(preamble,header,payload)
%frame_gener: To generator a frame using given preamble, header and payload
%             under power line circumstance.
	global winLabel Psig;
	if winLabel==false
		frame = frame_gener_noWIN(preamble,header,payload);
	else
		frame = frame_gener_WIN(preamble,header,payload);
    end
end

function [frame] = frame_gener_WIN(preamble,header,payload)
	%   
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
%% normalization for preamble
    save 'preamble.mat' 'preamble';
    preamble = preamble * sqrt(2 * mean((abs(header)).^2) / mean((abs(preamble)).^2));
%% overlap and add
    sample1 = length(preamble);
    sample2 = length(header);
    sample3 = length(payload);
    frame = zeros(sample1+sample2+sample3-2*beta,1);
    frame(1:sample1) = preamble;
    frame(sample1-beta+1:sample1-beta+sample2) = frame(sample1-beta+1:sample1-beta+sample2) + header;
    frame(sample1-2*beta+sample2+1:end) = frame(sample1-2*beta+sample2+1:end) + payload;
%% normalization of the frame power
    P_avg = mean((abs(frame)).^2); %计算符号平均功率
    frame = frame/sqrt(P_avg);
    save 'frame.mat' 'frame';
    factor = sqrt(2 * mean((abs(header)).^2) / mean((abs(preamble)).^2)) / sqrt(P_avg);
    save 'factor.mat' 'factor'
%% display the frame
    %{
    figure;    hold on;
    plot(abs(frame));
    set(gca,'xlim',[1,2.5e4]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('frame structure in time domain');
    legend('frame');
%}
end

function [frame] = frame_gener_noWIN(preamble,header,payload)
	%   
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
%% normalization for preamble
    save 'preamble.mat' 'preamble';
    preamble = preamble * sqrt(mean((abs(header)).^2) / mean((abs(preamble)).^2));
    payload = payload * sqrt(mean((abs(header)).^2) / mean((abs(payload)).^2));
%% overlap and add
    frame = [preamble,header,payload];
    save 'frame.mat' 'frame';
    %factor = sqrt(2 * mean((abs(header)).^2) / mean((abs(preamble)).^2)) / sqrt(P_avg);
    %save 'factor.mat' 'factor'
%% display the frame
    %{
    figure;    hold on;
    plot(abs(frame));
    set(gca,'xlim',[1,2.5e4]);
    xlabel('discrete time');
    ylabel('amplitude');
    title('frame structure in time domain');
    legend('frame');
%}
end
