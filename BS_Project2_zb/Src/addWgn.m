function Mwgn = addWgn(M)
%ADDWGN 给信号加白噪声的函数
%   输入参数：M，源信号
%   输出参数：Mwgn，输出信号

%SNR 信噪比。信号功率与噪声功率的比值，不过一般取对数。即SNR=10*lg（A/B）。
%因为将倍数关系转换为指数关系，所以设置分贝为单位。这里加2%噪声
SNR=10*log(100/5);
%利用matlab中的awgn函数给信号加噪声
Mwgn = awgn(M,SNR);
return
end

