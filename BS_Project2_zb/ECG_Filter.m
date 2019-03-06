%�ļ�����  :  ECG_Plot
%ʵ�ֹ���  :  ��ȡMIT-BIH-DB�ļ�����ȡ�źţ�����Bessel��Butterworth��
%             Chebyshev��Elliptic�����˲���ʵ��ͼ�������
%�ο�����  :  
%������Ϣ  :  171848-�ű�
%             537405288@qq.com
%             18795969032
%�޶�ʱ��  :  2018��4��2��19��46��
%���ø�ʽ  :  ��
%��������  :  ��


%��Ŀ·��
addpath(genpath(pwd));
clc;clear all;
%����Ҫ���������ļ�·��
PATH= 'SignalFile';
HEADERFILE= '100.hea';
ATRFILE= '100.atr';
DATAFILE='100.dat';

%================================��ȡECG����==============================%
%���ö�ȡ�źŵĺ���
[M,TIME] = ECG_Signal(PATH,HEADERFILE,ATRFILE,DATAFILE);
%����ֻȡһ���źŽ����˲�������
M1 = M(:,1);
%��ȡʮ��R������ݼ�
M_10_Pulse = getPulse(M1,2);
%�Ӱ�����
%M_10_Pulse_Wgn = addWgn(M_10_Pulse);

%================================��ȡECG����==============================%
%Butterworth�˲����˲�
output1 = filter(ButterWorth,M_10_Pulse);
%ChebyshevI�˲����˲�
output2 = filter(ChebyshevI,M_10_Pulse);
%ChebyshevII�˲����˲�
output3 = filter(ChebyshevII,M_10_Pulse);
%Elliptic�˲����˲�
output4 = filter(Elliptic,M_10_Pulse);
%bessel�˲����˲�
[b,a] = besself(16,360);
[num,den] = bilinear(b,a,360);
output5 = filter(num,den,M_10_Pulse);

%===================================��ͼ==================================%
figure('NumberTitle', 'off', 'Name', 'ECG��ͼ');
clf, box on, hold on;
%��Ϊͼ��ϴ�϶࣬�����û�ͼ������
set(gcf,'Position',get(0,'ScreenSize'))
%����3*2�Ļ�ͼ����
s(1) = subplot(3,2,1);
s(2) = subplot(3,2,2);
s(3) = subplot(3,2,3);
s(4) = subplot(3,2,4);
s(5) = subplot(3,2,5);
s(6) = subplot(3,2,6);
plot(s(1),M_10_Pulse,'r');title(s(1),[string,' ECG']);
xlabel(s(1),'Time / s'); ylabel(s(1),'Voltage / mV');
plot(s(2),output5,'b');title(s(2),[string,' ECG Bessel']);
xlabel(s(2),'Time / s'); ylabel(s(2),'Voltage / mV');
plot(s(3),output1,'b');title(s(3),[string,' ECG ButterWorth']);
xlabel(s(3),'Time / s'); ylabel(s(3),'Voltage / mV');
plot(s(4),output2,'b');title(s(4),[string,' ECG ChebyshevI']);
xlabel(s(4),'Time / s'); ylabel(s(4),'Voltage / mV');
plot(s(5),output3,'b');title(s(5),[string,' ECG ChebyshevII']);
xlabel(s(5),'Time / s'); ylabel(s(5),'Voltage / mV');
plot(s(6),output4,'b');title(s(6),[string,' ECG Elliptic']);
xlabel(s(6),'Time / s'); ylabel(s(6),'Voltage / mV');
