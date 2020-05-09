Tcurve1 = [5,4,3,2,1];
Tcurve2 = Tcurve1 + 0.3;
Tcurve3 = [4,3,2,1,0.5];
Tcurve4 = Tcurve3 + 0.2;
figure;     hold on;
plot([0:5:20],Tcurve1,'--rs','MarkerSize',10,'LineWidth',1.6);
plot([0:5:20],Tcurve2,'-rs','MarkerSize',10,'LineWidth',1.6);

plot([0:5:20],Tcurve3,'--bs','MarkerSize',10,'LineWidth',1.6);
plot([0:5:20],Tcurve4,'-bs','MarkerSize',10,'LineWidth',1.6);

legend('蛮力搜索 两段式','蛮力搜索 三段式','模拟退火 两段式','模拟退火 三段式');
title('两段式和三段式消噪效果对比');
set(gca,'XTick',[0:5:20]);
xlabel('信干比(dB)');
ylabel('平均误差时间(us)');