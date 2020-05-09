function [output] = SINR(realsig,noise,T,a)
    realsig(abs(realsig)>=T & abs(realsig)<=a*T) = T;
    realsig(abs(realsig)>=a*T) = 0;
    noise(abs(noise)>=T & abs(noise)<=a*T) = T;
    noise(abs(noise)>=a*T) = 0;
    PowReal = mean(realsig.^2);
    PowNoise = mean(noise.^2);
    %output = PowReal/PowNoise;
    output = 10*log(PowReal/PowNoise)/log(10);
end
%{
function [output] = SINR(ave)
    global Pim Pawgn Psig INF;
    conve = Psig/(Pim+Pawgn);
    MAX = Psig/Pawgn;
    % Trapdoor function: the core is Psig
    if ave<Psig
        output = MAX * exp(INF*(ave-Psig));
    else
        output = (MAX-conve) * exp((Psig-ave)*INF) + conve;
        %output = MAX * exp((Psig-ave)*INF);
    end
end
%}
