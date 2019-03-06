function [M,TIME] = ECG_Signal(PATH,HEADERFILE,ATRFILE,DATAFILE)
%ECG_SIGNAL ��ȡECG�ź�
%   ���������[�ź��ļ�·����ͷ�ļ����ƣ�ע���ļ����ƣ��ź��ļ�����]
%   ���������[�źž���ʱ������]


%=========================��100.hea�ļ����ݵĴ���=========================%
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
SAMPLES2READ = A(3);    %ȡʮ������

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
return
end
