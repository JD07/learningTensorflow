%%
clear;close all;clc;
%%
%��һ���������ݽ�������
index=3; % 1ΪRouse���� 2Ϊ���� 3Ϊlog����
%��ȡ��Ƶ����
load(['env_data',num2str(index),'.mat']);
% 	conc = flipud(conc')';
% 	a_size = flipud(a_size')'; 
load(['sonar_para_200k_',num2str(index),'.mat']);
elpset1=elpset;
clear elpset;
load(['sonar_para_300k_',num2str(index),'.mat']);
elpset2=elpset;
clear elpset;
load(['sonar_para_400k_',num2str(index),'.mat']);
elpset3=elpset;
clear elpset;
%����չ������
ping_num = p_num;
elpsetMF=zeros(ping_num,3*l_num);
tagMF=zeros(ping_num,l_num);
for i=1:ping_num  
    temp1=-[elpset1(i,:),elpset2(i,:),elpset3(i,:)];%����ֵȡ��
    temp1=roundn(temp1,-3);%����3λС��
    elpsetMF(i,:)=temp1;
    %temp2=[conc(i,:),a_size(i,:)*1e5];%������λum̫С����������
    temp2=conc_all(i,:);
    temp2=roundn(temp2,-3);%����3λС�� 
    tagMF(i,:)=temp2;
end
    
%% ����
resultName1=['result',num2str(index)];
save(resultName1, 'elpsetMF');
resultName2=['tag',num2str(index)];
save(resultName2, 'tagMF');



