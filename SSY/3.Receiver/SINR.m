function [output] = SINR(ave)
    global Psig;
    output = abs(Psig/(ave-Psig));
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
