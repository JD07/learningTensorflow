%% �����ݽ��е��£����������ݵ�����
clear all;clc;
%%
%�ȶ�����
maxIter=3;

for index=1:maxIter
   load(['result',num2str(index),'.mat']);
   load(['tag',num2str(index),'.mat']);
   elpsetMF=flip(elpsetMF,2);
   tagMF=flip(tagMF,2);
   resultName1=['result',num2str(index+10)];
    save(resultName1, 'elpsetMF');
    resultName2=['tag',num2str(index+10)];
    save(resultName2, 'tagMF');
end