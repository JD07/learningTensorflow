%% ������ ����Ũ�ȳ����������������ź�����������ź�
clear;close all;clc;
%% ��ȡ�ź�
%load('send_spec_200k.mat')
%load('send_spec_300k.mat')
load('send_spec_400k.mat')

%% ���뻷������
index=3;%1Ϊrouse���� 2Ϊ�������� 3Ϊlog����
load(['env_data',num2str(index),'.mat']);
conc = flipud(conc_all')';
a_size = flipud(a_size_all')';

%% ������������
layer_h = l_h;
layer_num = l_num;
ping_num = p_num;
f_num = length(frange);%
s_num = length(sendSpec);%
%%
ELpdb = zeros(f_num,layer_num,ping_num);
Sv = zeros(f_num,layer_num,ping_num);

%% ��������
for pid =1:ping_num
	%��Դ��
	SLp = 1; M0 = -190;
	SL = 10*log10(SLp) - M0 ;

	%˫�򴫲���ʧ����
	DTL = zeros(f_num,layer_num);

	%����˥��
	density = 2650; 
	[rv rs rw]= rv_rs_rw(frange,a_size(pid,:),density,conc(pid,:));
	rf = rv+rs+rw;

	%������������
	f = fc;
	a_r = 6.5e-2;
	c = 1500;
	Rcri = pi*a_r*a_r/c*f;
	range = (1:l_num).*l_h;
	z = range./Rcri;
	fai = (1+1.35*z+(2.5*z).^3.2)./(1.35*z+(2.5*z).^3.2);

	%������չ˥��
	for i = 1:layer_num
		atten = sum(rf(:,1:i),2);
		if i == 1
			atten = rf(:,1:i);
		end    
		%     ab = atten*layer_h - rf(:,i)*layer_h/2;
		%     rg = (i-1)*layer_h +layer_h/2;   
		ab = atten*layer_h;
		rg = i*layer_h;   
		DTL(:,i) = 2*(20*log10(fai(i)*rg) + ab);   %����˥��+��������
	end

	%Ŀ��ǿ�ȼ���  
	TS = zeros(f_num,layer_num);

	%��λ�������ɢ��
	Sv = sv(frange,a_size(pid,:),conc(pid,:),density);

	%������
	theta = 8/180*pi;
	solid_angle = 2*pi*(1-cos(theta/2));

	%�����������
	tao = s_num/fs; %�ظ������ź�ʱ��-1.3ms
	taoN = tao*c/4;
	for i = 1:layer_num
		Vrec = ((i*layer_h+taoN).^3 - (i*layer_h-taoN).^3)*solid_angle/3;
		TS(:,i) = Sv(:,i) + 10*log10(Vrec);
	end

	%�ز�ǿ���빦����Ӧ
	EL = SL-DTL+TS;
	ELp = 10.^((EL + M0)/20);%���ݣ�3-11���������ELpӦ�þ���ɢ��ز�������
	%����s4�����Լ���3-12�������渵��Ҷ�ϳ�ʱɢ��ز�������Ҫ���������������20�ǰѿ�����2Ҳ����ȥ��
	%ELP����ɢ��ز��������Ŀ���
		
	%��������
	ELpdb(:,:,pid) = ELp;
    if(mod(pid,100)==0)
        fprintf('No%d is done\n', pid); % ע�������ʽǰ����%����
    end
end
%% ��ȡ�м�Ƶ��
selef = floor(f_num/2);
elpset = zeros(ping_num,layer_num);
for pid = 1:ping_num
    elpset(pid,:) = 10*log10(ELpdb(selef,:,pid));
end
%% ����

%resultName=['sonar_para_200k_',num2str(index)];
%resultName=['sonar_para_300k_',num2str(index)];
resultName=['sonar_para_400k_',num2str(index)];
%save(resultName, 'rfdb', 'TSdb', 'TLdb', 'ELdb', 'Svdb', 'ELpdb');
save(resultName, 'elpset');

