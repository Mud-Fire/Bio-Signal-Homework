%�ļ�����  :  BS_Project3_zhangbing_171848
%ʵ�ֹ���  :  ��ȡMIT-BIH-DB�ļ�����ȡ�źţ���ͼ��
%             ʹ��wavelet toolbox��ѡ������С���任ĸ���������ź�ת����
%             ��ת�����źŻ�ͼ��
%�ο�����  :  
%������Ϣ  :  171848-�ű�
%             537405288@qq.com
%             18795969032
%�޶�ʱ��  :  2018��4��25��19��46��
%���ø�ʽ  :  ��
%��������  :  ��

%��Ŀ·��
addpath(genpath(pwd));
clc;clear all;

%����Ҫ����data-set ·��
PATH   = 'SignalFile';
SAMPLE = 'samples.txt';
PulseTime = 5;

%==========��ȡ�ź���Ϣ
%����Ϊ�˶�ȡ���ݷ��㣬��������Ԥ������txt�ļ����ǰ���з���ֵ����ɾ����
%���û��ʹ��ԭʼ�����źţ�ֱ�������ݿ�����ת��������ݣ�ʡȥ���źŷ���Ĺ���
samples = fullfile(PATH,SAMPLE);
fid = fopen(samples,'r');
z = textscan(fid,'%f %f %f');
fclose(fid);

%==========ѡȡ5��pulse����
% �۲�Rֵ��0.5���ϣ�������Rֵǰ����������������0.5��Χ����Ѱ�Ҽ�ֵȷ��R��λ��
[R_V,R_L]=findpeaks(z{2},'minpeakheight',0.5);
%�źŽ���ѡ��10R��λ�����11R��λ�õľ�ֵλ��
signStop = mean([R_L(PulseTime) R_L(PulseTime+1)]);

Time = z{1}(1:signStop)/360;
MLII = z{2}(1:signStop);
V5 = z{3}(1:signStop);

%==========��ͼ
figure('NumberTitle', 'off', 'Name', 'ECG��ͼ');
clf, box on, hold on;
plot(Time,MLII,'r');
plot(Time,V5,'b');