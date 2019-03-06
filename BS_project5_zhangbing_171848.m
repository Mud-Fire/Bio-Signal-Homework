%文件名称  :  BS_Project5_zhangbing_171848
%实现功能  :  利用ANN通过汽车的配置来预测汽车价格
%                          
%参考资料  : 
%作者信息  :  171848-张冰
%             537405288@qq.com
%             18795969032
%修订时间  :  2018年5月23日15点43分
%调用格式  :  无
%参数释义  :  无

%项目路径
addpath(genpath(pwd));
clc;
%=============在excel中读取数据信息=============
filename = 'Cars.xlsx';
sheet = 1;
%训练集汽车配置
xlRange_X = 'D2:Q43';
%训练集汽车价格
xlRange_Ylabel = 'B2:B43';
%测试集汽车配置
xlRange_x = 'D44:Q44';
%利用ANN将测试集预测结果写回文件
xlRange_ywrite = 'C44:C44';
%利用ANN将训练集再预测的结果写回文件
xlRange_Ywrite = 'C2:C43';
%读数据
Cars_X      = xlsread(filename,sheet,xlRange_X);
Cars_Ylabel = xlsread(filename,sheet,xlRange_Ylabel);
Cars_x      = xlsread(filename,sheet,xlRange_x);
Cars_ylabel = xlsread(filename,sheet,xlRange_ylabel);

%=============对数据集进行预处理=============
%将数据集转置成符合ANN的格式
P = Cars_X';
T = Cars_Ylabel';
A = Cars_x';
%对数据集进行归一化
[p1,ps] = mapminmax(P,0,1);
[t1,ts] = mapminmax(T,0,1);
a = mapminmax('apply',A,ps);
%扩大训练集，利用加噪声数据扩大训练集规模
p2 = p1;
t2 = t1;
for i = 1:100
    disp(i);
    p2 = horzcat(p2,awgn(p1,10*log(100/4)));
    t2 = horzcat(t2,awgn(t1,10*log(100/4)));
end

%=============对网络进行训练=============
%生成隐藏层8个节点的前向神经网络
%这里利用matlab最新函数替代netff函数
carNet = feedforwardnet(8,'trainlm');
carNet = init(carNet);              %初始化
carNet.trainParam.lr = 0.001;       %设置步长0.001
carNet.trainParam.epochs = 10000;   %设置训练10000次
carNet.trainParam.goal = 0.0000001; %设置收敛误差0.0000001
%训练
carNet = train(carNet,p2,t2);

%=============利用网络进行训练=============
y = sim(carNet,a);      %利用测试集预测价格
y1 = sim(carNet,p1);    %利用训练集再预测价格
%对训练出的值进行反归一化处理
cp=mapminmax('reverse',y1,ts);
c =mapminmax('reverse',y,ts);
%将结果写入文件
xlswrite(filename,c,sheet,xlRange_ywrite);
xlswrite(filename,cp',sheet,xlRange_Ywrite);

%===以下为原跳高模型的程序
% P=[3.2 3.2 3 3.2 3.2 3.4 3.2 3 3.2 3.2 3.2 3.9 3.1 3.2;
% 9.6 10.3 9 10.3 10.1 10 9.6 9 9.6 9.2 9.5 9 9.5 9.7;
% 3.45 3.75 3.5 3.65 3.5 3.4 3.55 3.5 3.55 3.5 3.4 3.1 3.6 3.45;
% 2.15 2.2 2.2 2.2 2 2.15 2.14 2.1 2.1 2.1 2.15 2 2.1 2.15;
% 140 120 140 150 80 130 130 100 130 140 115 80 90 130;
% 2.8 3.4 3.5 2.8 1.5 3.2 3.5 1.8 3.5 2.5 2.8 2.2 2.7 4.6;
% 11 10.9 11.4 10.8 11.3 11.5 11.8 11.3 11.8 11 11.9 13 11.1 10.85;
% 50 70 50 80 50 60 65 40 65 50 50 50 70 70];
% T=[2.24 2.33 2.24 2.32 2.2 2.27 2.2 2.26 2.2 2.24 2.24 2.2 2.2 2.35];
%[p1,minp,maxp,t1,mint,maxt]=premnmx(P,T);
%利用新的函数替代netff
% netEamp = feedforwardnet(6,'trainlm');
% %设置训练次数
% netEamp.trainParam.epochs = 5000;
% %设置收敛误差
% netEamp.trainParam.goal=0.0000001;
% netEamp = train(netEamp,p1,t1);
% a=[3.0;9.3;3.3;2.05;100;2.8;11.2;50];
% %输入数据
% a=[3.0;9.3;3.3;2.05;100;2.8;11.2;50];
% %将输入数据归一化
% a=premnmx(a);
% %放入到网络输出数据
% b=sim(netEamp,a);
% %将得到的数据反归一化得到预测数据
% c=postmnmx(b,mint,maxt);
% disp(c);
