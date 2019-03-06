function [M,TIME] = ECG_Signal(PATH,HEADERFILE,ATRFILE,DATAFILE)
%ECG_SIGNAL 获取ECG信号
%   输入参数：[信号文件路径，头文件名称，注释文件名称，信号文件名称]
%   输出参数：[信号矩阵，时间序列]


%=========================对100.hea文件数据的处理=========================%
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
SAMPLES2READ = A(3);    %取十秒数据

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
return
end

