%文件名称  :  BS_Project3_zhangbing_171848
%实现功能  :  读取MIT-BIH-DB文件，读取信号，画图，
%             使用wavelet toolbox，选择三个小波变换母函数进行信号转换，
%             将转换后信号画图。
%参考资料  :  
%作者信息  :  171848-张冰
%             537405288@qq.com
%             18795969032
%修订时间  :  2018年4月25日19点46分
%调用格式  :  无
%参数释义  :  无

%项目路径
addpath(genpath(pwd));
clc;clear all;

%设置要读的data-set 路径
PATH   = 'SignalFile';
SAMPLE = 'samples.txt';
PulseTime = 5;

%==========读取信号信息
%这里为了读取数据方便，做了数据预处理，把txt文件里的前两行非数值数据删除了
%这次没有使用原始数据信号，直接用数据库在线转换后的数据，省去了信号翻译的过程
samples = fullfile(PATH,SAMPLE);
fid = fopen(samples,'r');
z = textscan(fid,'%f %f %f');
fclose(fid);

%==========选取5个pulse数据
% 观察R值在0.5以上，并且在R值前后函数单调，所以在0.5范围以上寻找极值确定R点位置
[R_V,R_L]=findpeaks(z{2},'minpeakheight',0.5);
%信号截至选第10R点位置与第11R点位置的均值位置
signStop = mean([R_L(PulseTime) R_L(PulseTime+1)]);

Time = z{1}(1:signStop)/360;
MLII = z{2}(1:signStop);
V5 = z{3}(1:signStop);

%==========画图
figure('NumberTitle', 'off', 'Name', 'ECG作图');
clf, box on, hold on;
plot(Time,MLII,'r');
plot(Time,V5,'b');