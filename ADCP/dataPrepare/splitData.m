%%
%第二步，对所有数据进行随机排序并分为train和test
clear all;clc;
%%
%先读数据
maxIter=3;
A=[];B=[];
for iter=1:maxIter
   load(['result',num2str(iter),'.mat']);
   load(['tag',num2str(iter),'.mat']);
   A=[A;elpsetMF];
   B=[B;tagMF];
end
clear elpsetMF tagMF
%%
%生产随机种子
randIndex = randperm(size(A,1));
%随机排序
A_new=A(randIndex,:);
B_new=B(randIndex,:);
%%
clear A B
threshold=0.9;
data=A_new(1:threshold*size(A_new,1),:);
save("train_data", 'data');
data=A_new(threshold*size(A_new,1)+1:size(A_new,1),:);
save("test_data",'data');
tag=B_new(1:threshold*size(B_new,1),2:2:40);
save("train_tag",'tag');
tag=B_new(threshold*size(B_new,1)+1:size(B_new,1),2:2:40);
save("test_tag",'tag');