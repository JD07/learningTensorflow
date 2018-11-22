%%
%第二步，对所有数据进行随机排序并分为train和test
clear all;clc;
%%
%先读数据
maxIter=3;
A=[];B=[];
for iter=11:maxIter+10
   load(['result',num2str(iter),'.mat']);
   load(['tag',num2str(iter),'.mat']);
   A=[A;elpsetMF];
   B=[B;tagMF];
end
%%
%生产随机种子
randIndex = randperm(size(A,1));
%随机排序
A_new=A(randIndex,:);
B_new=B(randIndex,:);
%%
clear A B
threshold=0.9;
date=A_new(1:threshold*size(A_new,1),:);
tag=A_new(threshold*size(A_new,1)+1:size(A_new,1),:);
save("train_data2", 'date');
save("train_tag2",'tag');
date=B_new(1:threshold*size(B_new,1),:);
tag=B_new(threshold*size(B_new,1)+1:size(B_new,1),:);
save("test_data2",'date');
save("test_tag2",'tag');