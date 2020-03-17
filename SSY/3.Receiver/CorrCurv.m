function [corr1,toa1,corr2,toa2] = CorrCurv(temp1,temp2)
%UNTITLED 此处显示有关此函数的摘要
% corr1: suppression
% corr3: nosuppression
    global CorrLabel;
    if CorrLabel == 1
        [corr1,toa1,corr2,toa2] = CorrCurv_A(temp1,temp2);
    elseif CorrLabel == 2
        [corr1,toa1,corr2,toa2] = CorrCurv_B(temp1,temp2);
    elseif CorrLabel == 3
        [corr1,toa1,corr2,toa2] = CorrCurv_C(temp1,temp2);
    elseif CorrLabel == 4
        [corr1,toa1,corr2,toa2] = CorrCurv_D(temp1,temp2);
    elseif CorrLabel == 5
        [corr1,toa1,corr2,toa2] = CorrCurv_E(temp1,temp2);
    end
end
%% Method A
function [corr1,toa1,corr2,toa2] = CorrCurv_A(input1,input2)
% window length: seven 'short' symbols and two 'long' symbols
    global N Num;
    global N1 k1 N2 k2 N3 k3;
    % auto-correlation of the received signal
    corr1 = ones(Num-(N1+N2)*N/k1+1,1);
    %au index = 1:Num-(N1+N2)*N/k1+1
    for index = 1:Num-(N1+N2)*N/k1+1
        %auCorr(index) = auCorr(index-1) + recFrame(index-1+N/k1).*conj(recFrame(index-1+2*N/k1))...
        %    - recFrame(index-1).*conj(recFrame(index-1+N/k1));
        % Section one of the preamble
        temp = input1(index:index+(N1+N2)*N/k1-1);
        for k = 1:N1-1
            temp1 = temp(1+(k-1)*N/k1:k*N/k1);    temp2 = temp(1+k*N/k1:(k+1)*N/k1);
            corr1(index) = corr1(index) * abs(sum(temp1.*temp2));
        end
        % Section two of the preamble
        for k = 1:N2-1
            temp1 = temp(1+N1*N/k1+(k-1)*N/k2:k*N/k2+N1*N/k1);    temp2 = temp(1+N1*N/k1+k*N/k2:(k+1)*N/k2+N1*N/k1);
            corr1(index) = corr1(index) * abs(sum(temp1.*temp2));
        end
    end
    [~,toa1] = max(corr1);
%--------------------------------------------------------------------------------------------    
    % auto-correlation of the received signal
    corr2 = ones(Num-(N1+N2)*N/k1+1,1);
    %auCorr(1) = sum(recFrame(1:N/k1).*conj(recFrame(N/k1+1:2*N/k1)));
    for index = 1:Num-(N1+N2)*N/k1+1
        %auCorr(index) = auCorr(index-1) + recFrame(index-1+N/k1).*conj(recFrame(index-1+2*N/k1))...
        %    - recFrame(index-1).*conj(recFrame(index-1+N/k1));
        % Section one of the preamble
        temp = input2(index:index+(N1+N2)*N/k1-1);
        for k = 1:N1-1
            temp1 = temp(1+(k-1)*N/k1:k*N/k1);    temp2 = temp(1+k*N/k1:(k+1)*N/k1);
            corr2(index) = corr2(index) * abs(sum(temp1.*temp2));
        end
        % Section two of the preamble
        for k = 1:N2-1
            temp1 = temp(1+N1*N/k1+(k-1)*N/k2:k*N/k2+N1*N/k1);    temp2 = temp(1+N1*N/k1+k*N/k2:(k+1)*N/k2+N1*N/k1);
            corr2(index) = corr2(index) * abs(sum(temp1.*temp2));
        end
    end
    [~,toa2] = max(corr2);
end
%% Method B
function [corr1,toa1,corr2,toa2] = CorrCurv_B(temp1,temp2)
% Acquisition: corr1    
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global N1 k1 N2 k2 N3 k3;
    global coefficient;
    load '.\looup_table.mat' 'looup_table';
    len = length(temp1);
    corr1 = zeros(len-2.0*N/k1+1,1);      % auto-correlation of the received signal
    corr1(1) = sum(temp1(1:N/k1).*conj(temp1(N/k1+1:2*N/k1)));
    for index = 2:len-2.0*N/k1+1
        corr1(index) = corr1(index-1) + temp1(index-1+N/k1).*conj(temp1(index-1+2*N/k1))...
            - temp1(index-1).*conj(temp1(index-1+N/k1));
    end
%pick the location within first 'short' symbol using threshold
    corr1 = abs(corr1);
    maxval = max(corr1);   minval = min(corr1);
    threshold = maxval - coefficient * (maxval - minval);
    f = find(corr1>=threshold);
    pickone = f(1);
% Time tracking
    start = pickone + N/k1;     % within the second 'short' symbol
    candi = fft(temp1(start:start+N/k1*4-1));
    temp = repmat(candi,[1,N/k1]);
    % normalization of the lookup-table using energy
    aveT = sum(abs(looup_table(:,1)).^2);    aveP = sum(abs(candi).^2);   
    temp = temp / sqrt(aveP / aveT);
    % calculating and comparing
    MSE = sum(abs((temp-looup_table)).^2)/(4*N1/k1);
    [~,shift] = min(MSE);       % shift index in second 'short' symol
    toa1 = start - (shift)+1;
%----------------------------------------------------------------------------------------
% Acquisition: corr2   
    global Fuc Fus beta Ndf Nhd Ngi Fsc N;
    global N1 k1 N2 k2 N3 k3;
    global coefficient;
    load '.\looup_table.mat' 'looup_table';
    len = length(temp2);
    corr2 = zeros(len-2.0*N/k1+1,1);      % auto-correlation of the received signal
    corr2(1) = sum(temp2(1:N/k1).*conj(temp2(N/k1+1:2*N/k1)));
    for index = 2:len-2.0*N/k1+1
        corr2(index) = corr2(index-1) + temp2(index-1+N/k1).*conj(temp2(index-1+2*N/k1))...
            - temp2(index-1).*conj(temp2(index-1+N/k1));
    end
%pick the location within first 'short' symbol using threshold
    corr2 = abs(corr2);
    maxval = max(corr2);   minval = min(corr2);
    threshold = maxval - coefficient * (maxval - minval);
    f = find(corr2>=threshold);
    pickone = f(1);
%% Time tracking
    start = pickone + N/k1;     % within the second 'short' symbol
    candi = fft(temp2(start:start+N/k1*4-1));
    temp = repmat(candi,[1,N/k1]);
    % normalization of the lookup-table using energy
    aveT = sum(abs(looup_table(:,1)).^2);    aveP = sum(abs(candi).^2);   
    temp = temp / sqrt(aveP / aveT);
    % calculating and comparing
    MSE = sum(abs((temp-looup_table)).^2)/(4*N1/k1);
    [~,shift] = min(MSE);       % shift index in second 'short' symol
    toa2 = start - (shift) + 1;
end
%% the others
function [corr1,corr2,corr3,corr4] = CorrCurv_C(temp1,temp2)
end
function [corr1,corr2,corr3,corr4] = CorrCurv_D(temp1,temp2)
end
function [corr1,corr2,corr3,corr4] = CorrCurv_E(temp1,temp2)
end


