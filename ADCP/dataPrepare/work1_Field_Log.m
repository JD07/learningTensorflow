%%
%该代码用于构建训练数据
%深度方面采用log公式
close all;clear all;clc
%% 深度r和到底部的距离z
deltar = 0.5; 
height = 20+deltar;
r=deltar:deltar:height; %深度
z=height+deltar-r; %z为到底部的距离
lr=length(r);
%% 总共数据量
maxIter=200;%最大迭代次数
nn=50+1;%每次迭代产生多少数据（这里加1是因为后边滤波会去掉最后一个，同样深度方面也会去掉一个）
a_size_all=zeros(maxIter*(nn-1),lr-1);%提前分配好内存方便计算
conc_all=zeros(maxIter*(nn-1),lr-1);
%% 开始生产数据
for iter=1:maxIter
	%影响生产的浓度场和粒径场的参数有5个
	%周期干扰函数y
	%平均浓度c0（单位kg/m3）
	%平均粒径a0（单位um）
	%对数方程底M
	%粒径经验公式Rouse常数b
	xz=1:nn;
	za=2;%Rouse公式参考高度
	
	%y用于构建毕业论文（3-20）中的周期函数
	%para=[40,30,80,34];
	para=round(30 + (80-30).*rand(1,4));
	y=abs(0.8*(sin(2*pi*xz/para(1))+4*cos(2*pi*xz/para(2))+3*sin(2*pi*xz/para(3)))+2*cos(2*pi*xz/para(4)));
	y=y/5;
	
	c0=4 + (14-4).*rand; 
	a0=50 + (150-50).*rand; 
	M=round(2 + (10-2).*rand); %Rouse参数ws/(k*ustar);
	b=0.1 + (0.3-0.1).*rand; %(3-21)中提到的经验参数
	%rand('seed',0), %指定随机种子保证每次结果一致
	% 浓度与深度、时间的关系
	cnc=zeros(nn,lr);
	a_cnc=zeros(nn,lr);
	%选取距离底部2m处的浓度和粒径作为参考值

	for vz=1:nn
		modelconc=c0*(log(r)/log(M));% 毕业论文（3-19）
        modelconc=modelconc+abs(min(modelconc))+0.1;
		modelconcb=(y(vz).^2)*modelconc;%周期性干扰
		%add reandom component
		modelconc=modelconcb+0.5*rand(1,lr).*modelconc;%加上随机噪声
		cnc(vz,:)=modelconc;
	end

	% 粒子粒径与深度的关系
	for vr=1:lr
		modelsize=a0*(z(vr)/za).^(-b); % relative profile in eqn 12b in the paper
		%构建对数正态分布
		m = modelsize;%均值a(z)
		v = modelsize*0.4;%标准差v，该设定值见表3.3
		%毕业论文（3-22）
		mu = log((m^2)/sqrt(v+m^2));
		sigma = sqrt(log(v/(m^2)+1));
		%利用上面计算出的均值和方差构建对数正态分布，并抽取随机数
		modelsizeb = lognrnd(mu,sigma,nn,1)./1e6;%随机产生粒子粒径
		a_cnc(:,vr) = 0.2*modelsizeb.*y'+0.8.*modelsizeb;%对该粒径增加周期干扰
	end
	clear modelsizeb

	%对仿真产生的随机浓度场和随机粒径场进行平滑滤波
	conc=medfilt2(cnc,[2 2]);   %二维中值滤波
	conc=conc(1:end-1,1:end-1);%去掉第101次数据
	a_size=medfilt2(a_cnc,[2 2]); %二维中值滤波
	a_size=a_size(1:end-1,1:end-1);%去掉第101次数据
	%存入总矩阵
    a_size_all((nn-1)*(iter-1)+1:(nn-1)*iter,:)=a_size;
    conc_all((nn-1)*(iter-1)+1:(nn-1)*iter,:)=conc;
% 	%savedata
% 	resultName=['env_data',num2str(iter)];
% 	save(resultName, 'a_size', 'conc', 'l_h', 'l_num', 'p_num');
    fprintf('No%d is done\n', iter); % 注意输出格式前须有%符号，
end


%% savedata
%维度信息
l_num = size(conc_all,2);%深度维度长度
l_h = deltar;%深度维度步进长度
p_num = maxIter*(nn-1);%时间维度长度
%保存
index=3;
resultName=['env_data',num2str(index)];
save(resultName, 'a_size_all', 'conc_all', 'l_h', 'l_num', 'p_num');
fprintf('done\n'); % 注意输出格式前须有%符号，

