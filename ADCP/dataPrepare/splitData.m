%%
%�ڶ��������������ݽ���������򲢷�Ϊtrain��test
clear all;clc;
%%
%�ȶ�����
maxIter=3;
A=[];B=[];
for iter=1:maxIter
   load(['result',num2str(iter),'.mat']);
   load(['tag',num2str(iter),'.mat']);
   A=[A;elpsetMF];
   B=[B;tagMF];
end
%%
%�����������
randIndex = randperm(size(A,1));
%�������
A_new=A(randIndex,:);
B_new=B(randIndex,:);
%%
clear A B
threshold=0.9;
data1=A_new(1:threshold*size(A_new,1),:);
data2=A_new(threshold*size(A_new,1)+1:size(A_new,1),:);
save("train_data1", 'data1');
save("test_data1",'data2');
tag1=B_new(1:threshold*size(B_new,1),:);
tag2=B_new(threshold*size(B_new,1)+1:size(B_new,1),:);
save("train_tag1",'tag1');
save("test_tag1",'tag2');