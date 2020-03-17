function [output,runtime,T,a] = suppre(signal)
%suppre: to suppress impulse noise of the signal
   global suplabel;
   global simple;
   tic;
   if suplabel==1
        [T,a] = bruteForce(signal);
   elseif suplabel==2
        [T,a] = Simulannealing(signal);
   end
   runtime=toc;
   %[T1,a1] = bruteForce(signal);
   %[T2,a2] = Simulannealing(signal);
   output = f(signal,T,a);
end

function [T,a] = bruteForce(signal)
%generationAT: obtain the optimal parameters T and a for impulse noise suppression
    global stepA stepT simple;
    scaleA = 1:stepA:4;
    if simple == 2
        scaleA = 1;
    end
    scaleT = 1:stepT:4;
    res = ones(length(scaleA),length(scaleT));
    for a_index = 1:length(scaleA)
        for T_index = 1:length(scaleT)
            temp = f(signal,scaleT(T_index),scaleA(a_index));     % Receiver doesn't know P 
            ave = mean(temp.^2);
            res(a_index,T_index) = SINR(ave);%exp(SINR(ave));
        end
    end
    % display
    
  %{  
    figure;  hold on;
    pcolor(scaleT,scaleA,res);
    shading interp;
    colorbar;   colormap(jet);
    xlabel('T');ylabel('a');
    %}
    
    % T
    [~,resT] = max(max(res));
    T = scaleT(resT);
    % a
    [~,resA] = max(res(:,resT));
    a = scaleA(resA);
end

%% 模拟退火
function [Topt,Aopt] = Simulannealing(signal)
    global simple;
    if simple == 2
        [Topt,Aopt] = Simul2(signal);
    elseif simple ==3
        [Topt,Aopt] = Simul3(signal);
    else
        Topt = 2;   Aopt = 1;
    end
end
% 两段式
function [Topt,Aopt] = Simul2(signal)
    global T Tmin delta stepT stepA itertime;
    Tempra = T;
    count = 1;
    Aopt = 1;
    recordT = zeros(ceil(log(Tmin/T)/log(delta)),1);
    Teav = zeros(1,itertime);   Eeav = zeros(1,itertime);
    for k=1:itertime
        Topt = rand()+2;
        % record
        recordT(count) = Topt;
        temp = f(signal,Topt,1);
        E = SINR(mean(temp.^2));
        while(Tempra>Tmin)
            count = count + 1;
            T_next = Topt + (randi(3)-2)*stepT;
            if T_next < 1.5
                T_next = 1.8;
            elseif T_next > 5
                T_next = 4;
            end
            signal_next = f(signal,T_next,1);
            E_next = SINR(mean(signal_next.^2));
            dE = E_next - E;
            if dE >= 0
                Topt = T_next;   E = E_next;
            elseif exp(dE/Tempra) > rand()
                Topt = T_next;   E = E_next;
            end
            recordT(count) = Topt;
            Tempra = delta * Tempra;
        end
        Teav(k) = Topt;  Eeav(k) = E;
    end
    [~,loc] = min(Eeav);
    Topt = Teav(loc);
    %dispSimu2(recordT);
end
function [] = dispSimu2(recordT)
    for index = 1:length(recordT)
        plot(recordT(index),'*k');
    end
    title('两段式模拟退火搜索路径');
end
% 三段式
function [Topt,Aopt] = Simul3(signal)
    global T Tmin delta stepT stepA itertime;
    Tempra = T;
    count = 1;
    recordT = zeros(ceil(log(Tmin/T)/log(delta)),1);    recordA = recordT;
    Teav = zeros(1,itertime); aeav = zeros(1,itertime);   Eeav = zeros(1,itertime);
    for k=1:itertime
        Topt = rand()+2;   Aopt = rand()+1;
        % record
        recordT(count) = Topt;  recordA(count) = Aopt;
        temp = f(signal,Topt,Aopt);
        E = SINR(mean(temp.^2));
        while(Tempra>Tmin)
            count = count + 1;
            T_next = Topt + (randi(3)-2)*stepT;  A_next = Aopt + (randi(3)-2)*stepA;
            if A_next<1
                A_next = 1.1;
            elseif A_next > 5
                A_next = 4;
            end
            if T_next < 1.5
                T_next = 1.8;
            elseif T_next > 5
                T_next = 4;
            end
            signal_next = f(signal,T_next,A_next);
            E_next = SINR(mean(signal_next.^2));
            dE = E_next - E;
            if dE >= 0
                Topt = T_next; Aopt = A_next;   E = E_next;
            elseif exp(dE/Tempra) > rand()
                Topt = T_next; Aopt = A_next;   E = E_next;
            end
            recordT(count) = Topt;  recordA(count) = Aopt;
            Tempra = delta * Tempra;
        end
        Teav(k) = Topt; aeav(k) = Aopt; Eeav(k) = E;
    end
    [~,loc] = min(Eeav);
    Topt = Teav(loc);   Aopt = aeav(loc);
    %dispSimu3(recordT,recordA);
end
function [] = dispSimu3(recordT,recordA)
    for index = 1:length(recordT)
        plot(recordT(index),recordA(index),'*k');
    end
    title('三段式模拟退火搜索路径');
end





























