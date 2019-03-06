%�ļ�����  :  ECG_Plot
%ʵ�ֹ���  :  ��ȡMIT-BIH-DB�ļ�����ȡ�źţ����źż��������������˲���ȥ�룬��
%             ʵ��ͼ�������
%�ο�����  :  rddata.m    Author-Robert Tratnig 
%������Ϣ  :  171848-�ű�
%             537405288@qq.com
%             18795969032
%�޶�ʱ��  :  2018��3��27��17��03��
%���ø�ʽ  :  ��
%��������  :  ��

clc;clear all;

PATH= '';
HEADERFILE= '100.hea';
ATRFILE= '100.atr';
DATAFILE='100.dat';

%=========================��100.dat�ļ����ݵĴ���=========================%
%.hea�ļ��洢��ECG�Ļ�����Ϣ
% ͨ������ fullfile ���ͷ�ļ�������·��
signalh= fullfile(PATH, HEADERFILE);
% ��ͷ�ļ������ʶ��Ϊ fid1 ������Ϊ'r'--��ֻ����
fid1=fopen(signalh,'r');
% ��ȡͷ�ļ��ĵ�һ�����ݣ��ַ�����ʽ
z= fgetl(fid1);
% ���ո�ʽ '%*s %d %d %d' ת�����ݲ�������� A ��
A= sscanf(z, '%*s %d %d %d',[1,3]);

nosig= A(1);    % �ź�ͨ����Ŀ
sfreq=A(2);     % ���ݲ���Ƶ��
SAMPLES2READ = 10*sfreq;    %ȡʮ������

for k=1:nosig           % ��ȡÿ��ͨ���źŵ�������Ϣ
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);           % �źŸ�ʽ; ����ֻ����Ϊ 212 ��ʽ
    gain(k)= A(2);              % ÿ mV ��������������
    bitres(k)= A(3);            % �������ȣ�λ�ֱ��ʣ�
    zerovalue(k)= A(4);         % ECG �ź������Ӧ������ֵ
    firstvalue(k)= A(5);        % �źŵĵ�һ������ֵ (����ƫ�����)
end;
fclose(fid1);
clear A;

%=========================��100.dat�ļ����ݵĴ���=========================%
%.dat�ļ������ݸ�ʽ��ȡΪÿ�������ֽ�,��������λ�Ķ���������,�����ݺ���Ϊ
%      0000 0000  ||             0000 0000              ||  0000 0000
%sign1(L)�Ͱ�λ��Ϣ||����λsign2(R)��Ϣ,����λsign1(L)��Ϣ||sign2(R)�Ͱ�λ��Ϣ
%���ڶ��ֽڵ���Ϣ������,����λ������һ�ֽ�����λ���õ�������sign1
%���ڶ��ֽڵ���Ϣ������,ǰ��λ������һ�ֽ�����λ���õ�������sign2.
signald = fullfile(PATH , DATAFILE);
fid2 = fopen(signald,'r');
A= fread(fid2, [3, SAMPLES2READ], 'uint8')';
fclose(fid2);

%�Եڶ��ֽ�����λ�����㣬λ�ƾ���-4
%�õ��ڶ��ֽ�����λ����sign2�ĸ���λ����������λ,�Ҹ���Ϣ
M_R_H = bitshift(A(:,2), -4);
%�Եڶ��ֽں�1111�������㣬
%�����ڶ��ֽ�����λ����sign1�ĵ���λ����������λ,�����Ϣ
M_L_H = bitand(A(:,2), 15);
%�Եڶ��ֽں�1000�������㣬
%�����ڶ��ֽ��ұߵ���λ����ȡsign2����λ,������λ�ƾ�λ��������sign1��������
PRL=bitshift(bitand(A(:,2),8),9); 
%�Եڶ��ֽں�10000000�������㣬
%�����ڶ��ֽ��ұߵ���λ����ȡsign1����λ��������λ��5λ��������sign2��������
PRR=bitshift(bitand(A(:,2),128),5);

%M����Ϊsign1��2�Ĵ洢���󣬴洢100.dat����������
%��sign1(L)��λ����sign1��λǰ(A(:,1))
%��sign2(R)��λ����sign2��λǰ(A(:,3))
%����źŷ���λ��Ϣȥ��
M( : , 1)= bitshift(M_L_H,8)+ A(:,1)-PRL;
M( : , 2)= bitshift(M_R_H,8)+ A(:,3)-PRR;

%��sign����ֵ������������õ�����ֵ
%�ٽ��õ��ľ��������Ե�ֵ��ÿmV������ֵ��������õ���ѹ����mV
M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
%�������趨�Ĳ�����������Ƶ�ʼ��õ������Ʒ�Ĳⶨʱ�䡣
TIME =(0:(SAMPLES2READ-1))/sfreq;
%�ͷű���
clear A M_R_H M_L_H PRR PRL;

%===============================���źżӰ�����=============================%
%SNR ����ȡ��źŹ������������ʵı�ֵ������һ��ȡ��������SNR=10*lg��A/B����
%��Ϊ��������ϵת��Ϊָ����ϵ���������÷ֱ�Ϊ��λ�������2%����
SNR=10*log(100/2);
%����matlab�е�awgn�������źż�����
Mwgn = awgn(M,SNR);

%==============================����˲������˲�============================%
%�����˲���
M_filter1 = [0,1,2,3,2,1,0];
%�����˲���
M_filter2 = [0,1,1,1,1,1,0];
%����filter��������sign1�����������˲����˲�����ƽ�����õ��µ��ź�ֵ
Mflt(:,1) = filter(M_filter1,1,M(:,1) )/sum(M_filter1);
%����conv2��������sign2�����������˲����˲�������������ƽ�����õ��µ��ź�ֵ
%M_filter2��Ҫ��ת180�ȣ�����һ��ת��
%Ч����filter������ͬ������ֻ����һ�²�ͬ�ķ�����
Mflt(:,2) = conv2(Mwgn(:,2) , M_filter2','same')/sum(M_filter2);

%=================================��������================================%
%�۲�Rֵ��0.5���ϣ�������Rֵǰ����������������0.5��Χ����Ѱ�Ҽ�ֵȷ��R��λ��
[R_V,R_L]=findpeaks(M(:,1),'minpeakheight',0.5);
%����λ�úͲ���Ƶ����������������ڵ�ƽ������
H_Rate = 60*(length(R_L)-1)/((R_L(length(R_L))-R_L(1))/sfreq);
%���������ʱ������
R_Time = R_L(length(R_L))/sfreq;
%��ӡ���
disp('**********************�����Ϣ**********************')
disp('**                                                **')
disp(['**','  ��λ���Զ�����',num2str(R_Time,3),'���ڣ���ƽ�������ǣ�  '...
    num2str(H_Rate,3),'��  ','**']);
disp('**                                                **')
disp('**********************ף������**********************')

%===================================��ͼ==================================%
%��2���ź���ԭͼ/��������wgn��/�˲���flt����ͼ��-----���δ��ϵ���
%����λ�ź�1������Ϊ�ź�2
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
string=['ECG signal ',DATAFILE];
%ԭͼ
plot(s(1),TIME, M(:,1),'r');title(s(1),[string,' MLII']);
xlabel(s(1),'Time / s'); ylabel(s(1),'Voltage / mV');
plot(s(2),TIME, M(:,2),'b');title(s(2),[string,' V5']);
xlabel(s(2),'Time / s'); ylabel(s(2),'Voltage / mV');
%������ͼ��wgn��
plot(s(3),TIME, Mwgn(:,1),'r');title(s(3),[string,' MLII wgn']);
xlabel(s(3),'Time / s'); ylabel(s(3),'Voltage / mV');
plot(s(4),TIME, Mwgn(:,2),'b');title(s(4),[string,' V5 wgn']);
xlabel(s(4),'Time / s'); ylabel(s(4),'Voltage / mV');
%�˲���ͼ��flt��
%ֱ���˲�ԭ���ݵ�ͼ
plot(s(5),TIME, Mflt(:,1),'r');title(s(5),[string,' MLII flt']);
xlabel(s(5),'Time / s'); ylabel(s(5),'Voltage / mV');
%�˲����������ͼ
plot(s(6),TIME, Mflt(:,2),'b');title(s(6),[string,' V5 wgn flt']);
xlabel(s(6),'Time / s'); ylabel(s(6),'Voltage / mV');
%���������˲�������״ͼ
figure('NumberTitle', 'off', 'Name', '�˲���');
clf, box on, hold on;
f(1) = subplot(2,1,1);
f(2) = subplot(2,1,2);
plot(f(1),M_filter1,'r');title(f(1),'�����˲���');
plot(f(2),M_filter2,'b');title(f(2),'�����˲���');
