%文件名称  :  ECG_Plot
%实现功能  :  读取MIT-BIH-DB文件，读取信号，对信号加噪声，并利用滤波器去噪，并
%             实现图像输出。
%参考资料  :  rddata.m    Author-Robert Tratnig 
%作者信息  :  171848-张冰
%             537405288@qq.com
%             18795969032
%修订时间  :  2018年3月27日17点03分
%调用格式  :  无
%参数释义  :  无

clc;clear all;

PATH= '';
HEADERFILE= '100.hea';
ATRFILE= '100.atr';
DATAFILE='100.dat';

%=========================对100.dat文件数据的处理=========================%
%.hea文件存储了ECG的基本信息
% 通过函数 fullfile 获得头文件的完整路径
signalh= fullfile(PATH, HEADERFILE);
% 打开头文件，其标识符为 fid1 ，属性为'r'--“只读”
fid1=fopen(signalh,'r');
% 读取头文件的第一行数据，字符串格式
z= fgetl(fid1);
% 按照格式 '%*s %d %d %d' 转换数据并存入矩阵 A 中
A= sscanf(z, '%*s %d %d %d',[1,3]);

nosig= A(1);    % 信号通道数目
sfreq=A(2);     % 数据采样频率
SAMPLES2READ = 10*sfreq;    %取十秒数据

for k=1:nosig           % 读取每个通道信号的数据信息
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);           % 信号格式; 这里只允许为 212 格式
    gain(k)= A(2);              % 每 mV 包含的整数个数
    bitres(k)= A(3);            % 采样精度（位分辨率）
    zerovalue(k)= A(4);         % ECG 信号零点相应的整数值
    firstvalue(k)= A(5);        % 信号的第一个整数值 (用于偏差测试)
end;
fclose(fid1);
clear A;

%=========================对100.dat文件数据的处理=========================%
%.dat文件的数据格式读取为每行三个字节,即三个八位的二进制数字,其内容含义为
%      0000 0000  ||             0000 0000              ||  0000 0000
%sign1(L)低八位信息||左四位sign2(R)信息,右四位sign1(L)信息||sign2(R)低八位信息
%将第二字节的信息处理后,后四位移至第一字节最左位即得到完整的sign1
%将第二字节的信息处理后,前四位移至第一字节最左位即得到完整的sign2.
signald = fullfile(PATH , DATAFILE);
fid2 = fopen(signald,'r');
A= fread(fid2, [3, SAMPLES2READ], 'uint8')';
fclose(fid2);

%对第二字节做左位移运算，位移距离-4
%得到第二字节左四位，即sign2的高四位，包括符号位,右高信息
M_R_H = bitshift(A(:,2), -4);
%对第二字节和1111做与运算，
%保留第二字节右四位，即sign1的低四位，包括符号位,左高信息
M_L_H = bitand(A(:,2), 15);
%对第二字节和1000做与运算，
%保留第二字节右边第四位，获取sign2符号位,并向左位移九位，与整体sign1进行运算
PRL=bitshift(bitand(A(:,2),8),9); 
%对第二字节和10000000做与运算，
%保留第二字节右边第四位，获取sign1符号位，并向左位移5位，与整体sign2进行运算
PRR=bitshift(bitand(A(:,2),128),5);

%M矩阵为sign1，2的存储矩阵，存储100.dat处理后数据
%将sign1(L)高位移至sign1低位前(A(:,1))
%将sign2(R)高位移至sign2低位前(A(:,3))
%最后将信号符号位信息去掉
M( : , 1)= bitshift(M_L_H,8)+ A(:,1)-PRL;
M( : , 2)= bitshift(M_R_H,8)+ A(:,3)-PRR;

%将sign的数值与零点做减法得到正负值
%再将得到的具有正负性的值与每mV的整数值相除，即得到电压多少mV
M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
%将我们设定的采样个数除以频率即得到这段样品的测定时间。
TIME =(0:(SAMPLES2READ-1))/sfreq;
%释放变量
clear A M_R_H M_L_H PRR PRL;

%===============================给信号加白噪声=============================%
%SNR 信噪比。信号功率与噪声功率的比值，不过一般取对数。即SNR=10*lg（A/B）。
%因为将倍数关系转换为指数关系，所以设置分贝为单位。这里加2%噪声
SNR=10*log(100/2);
%利用matlab中的awgn函数给信号加噪声
Mwgn = awgn(M,SNR);

%==============================设计滤波器并滤波============================%
%三角滤波器
M_filter1 = [0,1,2,3,2,1,0];
%梯形滤波器
M_filter2 = [0,1,1,1,1,1,0];
%利用filter函数，将sign1进行与三角滤波器滤波并作平均，得到新的信号值
Mflt(:,1) = filter(M_filter1,1,M(:,1) )/sum(M_filter1);
%利用conv2函数，将sign2进行与梯形滤波器滤波器做卷积，作平均，得到新的信号值
%M_filter2需要旋转180度，即做一次转置
%效果与filter函数相同，这里只是试一下不同的方法。
Mflt(:,2) = conv2(Mwgn(:,2) , M_filter2','same')/sum(M_filter2);

%=================================计算心率================================%
%观察R值在0.5以上，并且在R值前后函数单调，所以在0.5范围以上寻找极值确定R点位置
[R_V,R_L]=findpeaks(M(:,1),'minpeakheight',0.5);
%根据位置和采样频率来计算采样区间内的平均心率
H_Rate = 60*(length(R_L)-1)/((R_L(length(R_L))-R_L(1))/sfreq);
%算出采样的时间区间
R_Time = R_L(length(R_L))/sfreq;
%打印结果
disp('**********************诊断信息**********************')
disp('**                                                **')
disp(['**','  该位测试对象在',num2str(R_Time,3),'秒内，的平均心率是：  '...
    num2str(H_Rate,3),'下  ','**']);
disp('**                                                **')
disp('**********************祝您健康**********************')

%===================================画图==================================%
%画2个信号在原图/加噪声（wgn）/滤波后（flt）的图像-----依次从上到下
%左列位信号1，右列为信号2
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
string=['ECG signal ',DATAFILE];
%原图
plot(s(1),TIME, M(:,1),'r');title(s(1),[string,' MLII']);
xlabel(s(1),'Time / s'); ylabel(s(1),'Voltage / mV');
plot(s(2),TIME, M(:,2),'b');title(s(2),[string,' V5']);
xlabel(s(2),'Time / s'); ylabel(s(2),'Voltage / mV');
%加噪声图（wgn）
plot(s(3),TIME, Mwgn(:,1),'r');title(s(3),[string,' MLII wgn']);
xlabel(s(3),'Time / s'); ylabel(s(3),'Voltage / mV');
plot(s(4),TIME, Mwgn(:,2),'b');title(s(4),[string,' V5 wgn']);
xlabel(s(4),'Time / s'); ylabel(s(4),'Voltage / mV');
%滤波后图（flt）
%直接滤波原数据的图
plot(s(5),TIME, Mflt(:,1),'r');title(s(5),[string,' MLII flt']);
xlabel(s(5),'Time / s'); ylabel(s(5),'Voltage / mV');
%滤波加噪声后的图
plot(s(6),TIME, Mflt(:,2),'b');title(s(6),[string,' V5 wgn flt']);
xlabel(s(6),'Time / s'); ylabel(s(6),'Voltage / mV');
%画出两个滤波器的形状图
figure('NumberTitle', 'off', 'Name', '滤波器');
clf, box on, hold on;
f(1) = subplot(2,1,1);
f(2) = subplot(2,1,2);
plot(f(1),M_filter1,'r');title(f(1),'三角滤波器');
plot(f(2),M_filter2,'b');title(f(2),'梯形滤波器');

