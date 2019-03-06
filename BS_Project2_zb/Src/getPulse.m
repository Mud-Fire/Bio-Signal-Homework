function getPulse = getPulse(Signal,PulseTime)
%GETPULSE ��ȡ��Ҫ������pulse ���ź�����
%   ���������signal���ź�Դ����PulseTime����Ҫ��ȡ�ĸ�����
%   �����������ȡ�����ڵ��ź�����
% �۲�Rֵ��0.5���ϣ�������Rֵǰ����������������0.5��Χ����Ѱ�Ҽ�ֵȷ��R��λ��
[R_V,R_L]=findpeaks(Signal,'minpeakheight',0.5);
%�źŽ���ѡ��10R��λ�����11R��λ�õľ�ֵλ��
signStop = mean([R_L(PulseTime) R_L(PulseTime+1)]);
getPulse = Signal(1:signStop);
return
end

