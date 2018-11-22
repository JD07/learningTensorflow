%%
%�ڶ��������������ź�
%����ʩ��Զʦ�ִ��빹��
clear;close all;clc;
%% �ظ����������źţ�sc300kHz��ADCP���������źţ�
%�����趨
fs = 98.039e4;          %����Ƶ��
fc = 300e3;         %��������ź���Ƶ
band = 100e3;        %��Ч����-����3.3.2�ᵽ�󲿷��źż�����250-350kHz
pulse_width = 31*6*2/fc;   %32λBarker�룬�ظ�2�Σ��������Ԫ����ʱ�䣬����λ1.3ms
single_width = 6/fc;   %�����볤��

t = 0:1/fs:pulse_width - 1/fs;%�����źŵ�ʱ����
s_L = length(t);%ʱ�����ϵĲ��������

t_s = 0:1/fs:single_width - 1/fs;%�������ʱ����
sig_L = length(t_s);

single_signal = sin(2*pi*fc*t_s);%�����볤�ȵ��ز�

sendS = zeros(1,s_L);
sendC = zeros(1,s_L);

%�������
%sendCʹ��1-0��ʾ�ı�����Ϣ
%sendS���Ǹ���sendC���Ƶ��ź�
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
%����λ�����˲�
lowband = fc - band/2;
higband = fc + band/2;
%�漰FIR�˲����������÷�������˵��
b=fir1(60,[2*lowband/fs,2*higband/fs]);%���ڴ�������FIR�˲��� ��ͨ�˲� ����68+1��ϵ�� 
                                       %����˲���ϵ��b����z�Ľ�������
sendS = filtfilt(b,1,sendS);           %����λ�����˲���-b�Ƿ�ĸϵ����a�Ƿ���ϵ��

%����Ҷ�任
fftN = length(sendS);%ÿ���ظ������źŵ�ʱ�䳤��Ϊ1240
F = linspace(0,fs,fftN);%��fs����1240�ȷ֣�ÿ��Լ791Hz
sendSpec = fft(sendS,fftN);

%ѡȡ������Ƶ�ʷ�Χ-ֻ����300kHz������Ƶ��
ps = find(abs((F - lowband))==min(abs(F - lowband)));
pe = find(abs((F - higband))==min(abs(F - higband)));
ns = fftN+2-pe;
ne = fftN+2-ps;
frange = F(ps:pe);%����250kHz-350kHz�ķ�Χ����Ϊ127
save send_spec_300k.mat sendSpec ps pe ns ne frange fs fc fftN;