function [ofdm] = OFDMgene()
    global N Num Psig Pim Pawgn SIR SNR;
	load header.mat; OFDM = output;
	ofdm = ifft(OFDM,N);  %head(1) = 0;  % time-domain payload
    ofdm ./ sqrt(mean(ofdm.^2));
    % normalization
    Num = length(output);
    Psig = mean(output.^2);
    Pim = Psig*10^(-SIR/10);   Pawgn = Psig*10^(-SNR/10);
end

