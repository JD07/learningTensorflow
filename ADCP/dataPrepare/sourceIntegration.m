%%
clear;close all;clc;
%%
%第一步，对数据进行整合
index=3; % 1为Rouse曲线 2为线性 3为log曲线
%读取多频数据
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
%数据展开后打包
ping_num = p_num;
elpsetMF=zeros(ping_num,3*l_num);
tagMF=zeros(ping_num,l_num);
for i=1:ping_num  
    temp1=-[elpset1(i,:),elpset2(i,:),elpset3(i,:)];%将负值取反
    temp1=roundn(temp1,-3);%保留3位小数
    elpsetMF(i,:)=temp1;
    %temp2=[conc(i,:),a_size(i,:)*1e5];%粒径单位um太小，将其扩充
    temp2=conc_all(i,:);
    temp2=roundn(temp2,-3);%保留3位小数 
    tagMF(i,:)=temp2;
end
    
%% 保存
resultName1=['result',num2str(index)];
save(resultName1, 'elpsetMF');
resultName2=['tag',num2str(index)];
save(resultName2, 'tagMF');



