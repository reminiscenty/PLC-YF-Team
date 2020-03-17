function [output] = f(signal,T,a)
%f: the filter function
    output = zeros(length(signal),1);
    output(abs(signal)<=T) = signal((abs(signal)<=T));
    output(signal>T & signal<=a^2*T) = T;
    output(signal<-T & signal>=-a^2*T) = -T;
end