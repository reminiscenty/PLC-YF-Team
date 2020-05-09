function [output] = AA_ASA()
    global N;
    load header.mat; 
    pn = output(1:floor(N/2));
    PRE = zeros(1,N);
    PRE(1:2:end) = pn;
    pre = ifft(PRE,N);
    pre = real(pre);
    pre(1:N/2) = -pre(1:N/2);
    output = zeros(1,2*N);
    output(N/2+1:3*N/2) = pre;
    output(1:N/2) = pre(N/2+1:end);
    n = [0:N/2-1];
    output(3*N/2+1:end) = (-1).^n .* pre(N/2+1:end);
end

