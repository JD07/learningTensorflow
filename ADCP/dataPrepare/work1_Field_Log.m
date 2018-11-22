%%
%�ô������ڹ���ѵ������
%��ȷ������log��ʽ
close all;clear all;clc
%% ���r�͵��ײ��ľ���z
deltar = 0.5; 
height = 20+deltar;
r=deltar:deltar:height; %���
z=height+deltar-r; %zΪ���ײ��ľ���
lr=length(r);
%% �ܹ�������
maxIter=200;%����������
nn=50+1;%ÿ�ε��������������ݣ������1����Ϊ����˲���ȥ�����һ����ͬ����ȷ���Ҳ��ȥ��һ����
a_size_all=zeros(maxIter*(nn-1),lr-1);%��ǰ������ڴ淽�����
conc_all=zeros(maxIter*(nn-1),lr-1);
%% ��ʼ��������
for iter=1:maxIter
	%Ӱ��������Ũ�ȳ����������Ĳ�����5��
	%���ڸ��ź���y
	%ƽ��Ũ��c0����λkg/m3��
	%ƽ������a0����λum��
	%�������̵�M
	%�������鹫ʽRouse����b
	xz=1:nn;
	za=2;%Rouse��ʽ�ο��߶�
	
	%y���ڹ�����ҵ���ģ�3-20���е����ں���
	%para=[40,30,80,34];
	para=round(30 + (80-30).*rand(1,4));
	y=abs(0.8*(sin(2*pi*xz/para(1))+4*cos(2*pi*xz/para(2))+3*sin(2*pi*xz/para(3)))+2*cos(2*pi*xz/para(4)));
	y=y/5;
	
	c0=4 + (14-4).*rand; 
	a0=50 + (150-50).*rand; 
	M=round(2 + (10-2).*rand); %Rouse����ws/(k*ustar);
	b=0.1 + (0.3-0.1).*rand; %(3-21)���ᵽ�ľ������
	%rand('seed',0), %ָ��������ӱ�֤ÿ�ν��һ��
	% Ũ������ȡ�ʱ��Ĺ�ϵ
	cnc=zeros(nn,lr);
	a_cnc=zeros(nn,lr);
	%ѡȡ����ײ�2m����Ũ�Ⱥ�������Ϊ�ο�ֵ

	for vz=1:nn
		modelconc=c0*(log(r)/log(M));% ��ҵ���ģ�3-19��
        modelconc=modelconc+abs(min(modelconc))+0.1;
		modelconcb=(y(vz).^2)*modelconc;%�����Ը���
		%add reandom component
		modelconc=modelconcb+0.5*rand(1,lr).*modelconc;%�����������
		cnc(vz,:)=modelconc;
	end

	% ������������ȵĹ�ϵ
	for vr=1:lr
		modelsize=a0*(z(vr)/za).^(-b); % relative profile in eqn 12b in the paper
		%����������̬�ֲ�
		m = modelsize;%��ֵa(z)
		v = modelsize*0.4;%��׼��v�����趨ֵ����3.3
		%��ҵ���ģ�3-22��
		mu = log((m^2)/sqrt(v+m^2));
		sigma = sqrt(log(v/(m^2)+1));
		%�������������ľ�ֵ�ͷ����������̬�ֲ�������ȡ�����
		modelsizeb = lognrnd(mu,sigma,nn,1)./1e6;%���������������
		a_cnc(:,vr) = 0.2*modelsizeb.*y'+0.8.*modelsizeb;%�Ը������������ڸ���
	end
	clear modelsizeb

	%�Է�����������Ũ�ȳ����������������ƽ���˲�
	conc=medfilt2(cnc,[2 2]);   %��ά��ֵ�˲�
	conc=conc(1:end-1,1:end-1);%ȥ����101������
	a_size=medfilt2(a_cnc,[2 2]); %��ά��ֵ�˲�
	a_size=a_size(1:end-1,1:end-1);%ȥ����101������
	%�����ܾ���
    a_size_all((nn-1)*(iter-1)+1:(nn-1)*iter,:)=a_size;
    conc_all((nn-1)*(iter-1)+1:(nn-1)*iter,:)=conc;
% 	%savedata
% 	resultName=['env_data',num2str(iter)];
% 	save(resultName, 'a_size', 'conc', 'l_h', 'l_num', 'p_num');
    fprintf('No%d is done\n', iter); % ע�������ʽǰ����%���ţ�
end


%% savedata
%ά����Ϣ
l_num = size(conc_all,2);%���ά�ȳ���
l_h = deltar;%���ά�Ȳ�������
p_num = maxIter*(nn-1);%ʱ��ά�ȳ���
%����
index=3;
resultName=['env_data',num2str(index)];
save(resultName, 'a_size_all', 'conc_all', 'l_h', 'l_num', 'p_num');
fprintf('done\n'); % ע�������ʽǰ����%���ţ�

