function getPulse = getPulse(Signal,PulseTime)
%GETPULSE 获取想要数量的pulse 的信号数据
%   输入参数：signal（信号源），PulseTime（需要获取的个数）
%   输出参数：获取个数内的信号数据
% 观察R值在0.5以上，并且在R值前后函数单调，所以在0.5范围以上寻找极值确定R点位置
[R_V,R_L]=findpeaks(Signal,'minpeakheight',0.5);
%信号截至选第10R点位置与第11R点位置的均值位置
signStop = mean([R_L(PulseTime) R_L(PulseTime+1)]);
getPulse = Signal(1:signStop);
return
end

