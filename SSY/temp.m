Tcurve1 = [5,4,3,2,1];
Tcurve2 = Tcurve1 + 0.3;
Tcurve3 = [4,3,2,1,0.5];
Tcurve4 = Tcurve3 + 0.2;
figure;     hold on;
plot([0:5:20],Tcurve1,'--rs','MarkerSize',10,'LineWidth',1.6);
plot([0:5:20],Tcurve2,'-rs','MarkerSize',10,'LineWidth',1.6);

plot([0:5:20],Tcurve3,'--bs','MarkerSize',10,'LineWidth',1.6);
plot([0:5:20],Tcurve4,'-bs','MarkerSize',10,'LineWidth',1.6);

legend('�������� ����ʽ','�������� ����ʽ','ģ���˻� ����ʽ','ģ���˻� ����ʽ');
title('����ʽ������ʽ����Ч���Ա�');
set(gca,'XTick',[0:5:20]);
xlabel('�Ÿɱ�(dB)');
ylabel('ƽ�����ʱ��(us)');