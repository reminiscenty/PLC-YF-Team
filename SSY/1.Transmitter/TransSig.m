function [output] = TransSig()
%TransSig: the generation the Tx
%   
    global Pawgn Pim Psig Num fraNum;
    global SIR SNR;
	
	header = hea_gener();       % header of a certain frame
	payload = pay_gener();      % payload of a certain frame
	%% generate preamble for power lines with 50MHz
	pream = pream_gener();      % preamble of a certain frame
	frame = frame_gener(pream,header,payload);
	
	load prefix.mat prefix;		prefix = prefix / sqrt(mean(prefix.^2));
	output = [prefix,repmat(frame,1,fraNum)];
    Num = length(output);
	Psig = mean(output.^2);
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
end

