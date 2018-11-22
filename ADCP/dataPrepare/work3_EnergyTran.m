%% 第三步 根据浓度场、粒径场、发射信号来仿真接收信号
clear;close all;clc;
%% 读取信号
%load('send_spec_200k.mat')
%load('send_spec_300k.mat')
load('send_spec_400k.mat')

%% 载入环境数据
index=3;%1为rouse剖面 2为线性剖面 3为log剖面
load(['env_data',num2str(index),'.mat']);
conc = flipud(conc_all')';
a_size = flipud(a_size_all')';

%% 基本环境设置
layer_h = l_h;
layer_num = l_num;
ping_num = p_num;
f_num = length(frange);%
s_num = length(sendSpec);%
%%
ELpdb = zeros(f_num,layer_num,ping_num);
Sv = zeros(f_num,layer_num,ping_num);

%% 计算剖面
for pid =1:ping_num
	%声源级
	SLp = 1; M0 = -190;
	SL = 10*log10(SLp) - M0 ;

	%双向传播损失计算
	DTL = zeros(f_num,layer_num);

	%吸收衰减
	density = 2650; 
	[rv rs rw]= rv_rs_rw(frange,a_size(pid,:),density,conc(pid,:));
	rf = rv+rs+rw;

	%近场修正因子
	f = fc;
	a_r = 6.5e-2;
	c = 1500;
	Rcri = pi*a_r*a_r/c*f;
	range = (1:l_num).*l_h;
	z = range./Rcri;
	fai = (1+1.35*z+(2.5*z).^3.2)./(1.35*z+(2.5*z).^3.2);

	%叠加扩展衰减
	for i = 1:layer_num
		atten = sum(rf(:,1:i),2);
		if i == 1
			atten = rf(:,1:i);
		end    
		%     ab = atten*layer_h - rf(:,i)*layer_h/2;
		%     rg = (i-1)*layer_h +layer_h/2;   
		ab = atten*layer_h;
		rg = i*layer_h;   
		DTL(:,i) = 2*(20*log10(fai(i)*rg) + ab);   %球面衰减+近场修正
	end

	%目标强度计算  
	TS = zeros(f_num,layer_num);

	%单位体积反向散射
	Sv = sv(frange,a_size(pid,:),conc(pid,:),density);

	%波束角
	theta = 8/180*pi;
	solid_angle = 2*pi*(1-cos(theta/2));

	%叠加照射体积
	tao = s_num/fs; %重复编码信号时长-1.3ms
	taoN = tao*c/4;
	for i = 1:layer_num
		Vrec = ((i*layer_h+taoN).^3 - (i*layer_h-taoN).^3)*solid_angle/3;
		TS(:,i) = Sv(:,i) + 10*log10(Vrec);
	end

	%回波强度与功率响应
	EL = SL-DTL+TS;
	ELp = 10.^((EL + M0)/20);%根据（3-11），这里的ELp应该就是散射回波的能量
	%根据s4代码以及（3-12），后面傅里叶合成时散射回波能量需要开方，所以上面的20是把开方的2也算上去了
	%ELP就是散射回波的能量的开方
		
	%保存数据
	ELpdb(:,:,pid) = ELp;
    if(mod(pid,100)==0)
        fprintf('No%d is done\n', pid); % 注意输出格式前须有%符号
    end
end
%% 提取中间频率
selef = floor(f_num/2);
elpset = zeros(ping_num,layer_num);
for pid = 1:ping_num
    elpset(pid,:) = 10*log10(ELpdb(selef,:,pid));
end
%% 保存

%resultName=['sonar_para_200k_',num2str(index)];
%resultName=['sonar_para_300k_',num2str(index)];
resultName=['sonar_para_400k_',num2str(index)];
%save(resultName, 'rfdb', 'TSdb', 'TLdb', 'ELdb', 'Svdb', 'ELpdb');
save(resultName, 'elpset');

