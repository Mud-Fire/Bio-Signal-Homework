%文件名称  :  ECG_Plot
%实现功能  :  读取MIT-BIH-DB文件，读取信号，利用Bessel，Butterworth，
%             Chebyshev，Elliptic进行滤波，实现图像输出。
%参考资料  :  
%作者信息  :  171848-张冰
%             537405288@qq.com
%             18795969032
%修订时间  :  2018年4月2日19点46分
%调用格式  :  无
%参数释义  :  无


%项目路径
addpath(genpath(pwd));
clc;clear all;
%设置要读的数据文件路径
PATH= 'SignalFile';
HEADERFILE= '100.hea';
ATRFILE= '100.atr';
DATAFILE='100.dat';

%================================读取ECG数据==============================%
%调用读取信号的函数
[M,TIME] = ECG_Signal(PATH,HEADERFILE,ATRFILE,DATAFILE);
%这里只取一组信号进行滤波器设置
M1 = M(:,1);
%获取十个R点的数据集
M_10_Pulse = getPulse(M1,2);
%加白噪声
%M_10_Pulse_Wgn = addWgn(M_10_Pulse);

%================================读取ECG数据==============================%
%Butterworth滤波器滤波
output1 = filter(ButterWorth,M_10_Pulse);
%ChebyshevI滤波器滤波
output2 = filter(ChebyshevI,M_10_Pulse);
%ChebyshevII滤波器滤波
output3 = filter(ChebyshevII,M_10_Pulse);
%Elliptic滤波器滤波
output4 = filter(Elliptic,M_10_Pulse);
%bessel滤波器滤波
[b,a] = besself(16,360);
[num,den] = bilinear(b,a,360);
output5 = filter(num,den,M_10_Pulse);

%===================================画图==================================%
figure('NumberTitle', 'off', 'Name', 'ECG作图');
clf, box on, hold on;
%因为图像较大较多，这里让画图面板最大化
set(gcf,'Position',get(0,'ScreenSize'))
%分配3*2的画图区间
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
