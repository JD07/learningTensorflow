work1_Field_Linear.m\work1_Field_Log.m\work1_Field_Rouse.m:通过公式生产垂直方向上的悬浮物浓度分布以及粒子粒径分布，并加上随机扰动与噪声
work2_Signal_200k.m\work2_Signal_300k.m\work2_Signal_400k.m:产生制定频率的编码调制信号
work3_EnergyTran.m:通过work1产生的浓度场和粒径场，仿真制定频率的信号在其中的损失，从而得到相应的回波强度
sourceIntegration.m：将work3中产生的不同频率信号的回波强度整合到一起，便于后面tfRecord生成
dataAugument.m:通过翻转的方式扩充数据集
splitData.m：对数据随机排序并划分为训练集和测试集

2018/11/22
原本为了防止内存溢出，所以扩展的数据和原数据是分开进行随机排序的，但是后来觉得麻烦，于是修改为一起排序

2018/11/23
回归的确很难，网络loss一直不下降，估计是FCN没办法完成这一任务，打算以后换网络，现在先降低任务难度，对splitData做了修改，是的tag从40维下降到了20维
