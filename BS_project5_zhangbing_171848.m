%�ļ�����  :  BS_Project5_zhangbing_171848
%ʵ�ֹ���  :  ����ANNͨ��������������Ԥ�������۸�
%                          
%�ο�����  : 
%������Ϣ  :  171848-�ű�
%             537405288@qq.com
%             18795969032
%�޶�ʱ��  :  2018��5��23��15��43��
%���ø�ʽ  :  ��
%��������  :  ��

%��Ŀ·��
addpath(genpath(pwd));
clc;
%=============��excel�ж�ȡ������Ϣ=============
filename = 'Cars.xlsx';
sheet = 1;
%ѵ������������
xlRange_X = 'D2:Q43';
%ѵ���������۸�
xlRange_Ylabel = 'B2:B43';
%���Լ���������
xlRange_x = 'D44:Q44';
%����ANN�����Լ�Ԥ����д���ļ�
xlRange_ywrite = 'C44:C44';
%����ANN��ѵ������Ԥ��Ľ��д���ļ�
xlRange_Ywrite = 'C2:C43';
%������
Cars_X      = xlsread(filename,sheet,xlRange_X);
Cars_Ylabel = xlsread(filename,sheet,xlRange_Ylabel);
Cars_x      = xlsread(filename,sheet,xlRange_x);
Cars_ylabel = xlsread(filename,sheet,xlRange_ylabel);

%=============�����ݼ�����Ԥ����=============
%�����ݼ�ת�óɷ���ANN�ĸ�ʽ
P = Cars_X';
T = Cars_Ylabel';
A = Cars_x';
%�����ݼ����й�һ��
[p1,ps] = mapminmax(P,0,1);
[t1,ts] = mapminmax(T,0,1);
a = mapminmax('apply',A,ps);
%����ѵ���������ü�������������ѵ������ģ
p2 = p1;
t2 = t1;
for i = 1:100
    disp(i);
    p2 = horzcat(p2,awgn(p1,10*log(100/4)));
    t2 = horzcat(t2,awgn(t1,10*log(100/4)));
end

%=============���������ѵ��=============
%�������ز�8���ڵ��ǰ��������
%��������matlab���º������netff����
carNet = feedforwardnet(8,'trainlm');
carNet = init(carNet);              %��ʼ��
carNet.trainParam.lr = 0.001;       %���ò���0.001
carNet.trainParam.epochs = 10000;   %����ѵ��10000��
carNet.trainParam.goal = 0.0000001; %�����������0.0000001
%ѵ��
carNet = train(carNet,p2,t2);

%=============�����������ѵ��=============
y = sim(carNet,a);      %���ò��Լ�Ԥ��۸�
y1 = sim(carNet,p1);    %����ѵ������Ԥ��۸�
%��ѵ������ֵ���з���һ������
cp=mapminmax('reverse',y1,ts);
c =mapminmax('reverse',y,ts);
%�����д���ļ�
xlswrite(filename,c,sheet,xlRange_ywrite);
xlswrite(filename,cp',sheet,xlRange_Ywrite);

%===����Ϊԭ����ģ�͵ĳ���
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
%�����µĺ������netff
% netEamp = feedforwardnet(6,'trainlm');
% %����ѵ������
% netEamp.trainParam.epochs = 5000;
% %�����������
% netEamp.trainParam.goal=0.0000001;
% netEamp = train(netEamp,p1,t1);
% a=[3.0;9.3;3.3;2.05;100;2.8;11.2;50];
% %��������
% a=[3.0;9.3;3.3;2.05;100;2.8;11.2;50];
% %���������ݹ�һ��
% a=premnmx(a);
% %���뵽�����������
% b=sim(netEamp,a);
% %���õ������ݷ���һ���õ�Ԥ������
% c=postmnmx(b,mint,maxt);
% disp(c);
