%%
%第二步，构建发射信号
%根据施刘远师兄代码构筑
clear;close all;clc;
%% 重复编码脉冲信号（sc300kHz型ADCP测流发射信号）
%参数设定
fs = 98.039e4;          %采样频率
fc = 300e3;         %脉冲调制信号载频
band = 100e3;        %有效带宽-论文3.3.2提到大部分信号集中在250-350kHz
pulse_width = 31*6*2/fc;   %32位Barker码，重复2次，计算出码元持续时间，这里位1.3ms
single_width = 6/fc;   %单个码长度

t = 0:1/fs:pulse_width - 1/fs;%整个信号的时间轴
s_L = length(t);%时间域上的采样点个数

t_s = 0:1/fs:single_width - 1/fs;%单个码的时间轴
sig_L = length(t_s);

single_signal = sin(2*pi*fc*t_s);%单个码长度的载波

sendS = zeros(1,s_L);
sendC = zeros(1,s_L);

%编码调制
%sendC使用1-0表示的编码信息
%sendS则是根据sendC调制的信号
for num_bit = 1:31
    if(bitget(uint32(hex2dec('b7937045')),num_bit))
      sendS((num_bit-1)*sig_L+1:num_bit*sig_L) = single_signal;
      sendC((num_bit-1)*sig_L+1:num_bit*sig_L) = ones(1,sig_L);
    else
      sendS((num_bit-1)*sig_L+1:num_bit*sig_L) = -single_signal;  
    end   
end
for num_bit = 32:62
    if(bitget(uint32(hex2dec('b7937045')),num_bit-31))
      sendS((num_bit-1)*sig_L+1:num_bit*sig_L) = single_signal;
      sendC((num_bit-1)*sig_L+1:num_bit*sig_L) = ones(1,sig_L);
    else
      sendS((num_bit-1)*sig_L+1:num_bit*sig_L) = -single_signal;  
    end   
end
%%
%零相位数字滤波
lowband = fc - band/2;
higband = fc + band/2;
%涉及FIR滤波器，具体用法见网上说明
b=fir1(60,[2*lowband/fs,2*higband/fs]);%基于窗函数的FIR滤波器 带通滤波 返回68+1个系数 
                                       %输出滤波器系数b按照z的降序排列
sendS = filtfilt(b,1,sendS);           %零相位数字滤波器-b是分母系数，a是分子系数

%傅里叶变换
fftN = length(sendS);%每个重复编码信号的时间长度为1240
F = linspace(0,fs,fftN);%将fs按照1240等分，每份约791Hz
sendSpec = fft(sendS,fftN);

%选取并保存频率范围-只保存300kHz附近的频谱
ps = find(abs((F - lowband))==min(abs(F - lowband)));
pe = find(abs((F - higband))==min(abs(F - higband)));
ns = fftN+2-pe;
ne = fftN+2-ps;
frange = F(ps:pe);%覆盖250kHz-350kHz的范围点数为127
save send_spec_300k.mat sendSpec ps pe ns ne frange fs fc fftN;