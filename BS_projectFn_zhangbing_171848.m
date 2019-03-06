%文件名称  :  BS_ProjectFn_zhangbing_171848
%实现功能  :  利用小波变换及卷积神经网络对ECG数据进行分类
%                          
%参考资料  : Signal Classification with Wavelet Analysis and Convolutional Neural Networks
%https://ww2.mathworks.cn/help/wavelet/examples/signal-classification-with-
%wavelet-analysis-and-convolutional-neural-networks.html
%
%作者信息  :  171848-张冰
%             537405288@qq.com
%             18795969032
%修订时间  :  2018年6月30日2点06分
%调用格式  :  无
%参数释义  :  无

%项目路径
addpath(genpath(pwd));
clc;

% ====================数据路径及数据集准备====================
% 训练数据的操作路径
practiceDir = 'practiceData'; 
practiceDataDir = 'practice';
testDir = 'testData';
testDataDir = 'test';

% 载入网上的训练数据mat文件
% mat文件格式分data和label两部分
% data为162 * 65536的格式，即为162个心电数据样本，采样频率128HZ
% label为162 * 1 的格式，记录了这162个心电数据的病理类型。
load(fullfile(practiceDir,'physionet_ECG_data-master','ECGData.mat'))
disp(fullfile(practiceDir,'physionet_ECG_data-master','ECGData.mat'))

% 载入网上随机选择的测试数据的mat文件
% 100m为ARR
% 16786m为NRC
% chf06m为CHF
% 所有载入后都是val变量名，所有除以200的幅度之后重新命名
load(fullfile(testDir,'dataMat','100m.mat'))
ARR100 = val/200;
load(fullfile(testDir,'dataMat','16786m.mat'));
NSR16786 = val/200;
load(fullfile(testDir,'dataMat','chf06m.mat'));
CHF06 = val/200;
clear val;
%因为采样率不同，首先将采样率都降为128Hz
ARR_test = resample(ARR100,128,360);
NSR_test = resample(NSR16786,128,128);
CHF_test = resample(CHF06,128,250);
signList(1,:) = ARR_test(1:65536)';
signList(2,:) = NSR_test(1:65536)';
signList(3,:) = CHF_test(1:65536)';

clear ARR_test NSR_test CHF_test ARR100 NSR16786 CHF06
display("ECG数字数据准备完毕");
% ====================训练数据预处理====================

% 利用辅助函数创建训练数据的训练文件夹
disp("是否需要重新创建存储训练数据图片的文件夹：");
iflag = input('“是”输入1，“否”输入0:');
if iflag == 1
    helperCreateECGDirectories(ECGData,practiceDir,practiceDataDir);
    disp("训练数据路径准备完毕，进入下一步...");
else
    disp("训练数据路径准备完毕，进入下一步...");
end

% 利用辅助函数画三个类型数据ARR，CHF，NSR的第一个数据图
% 数据图选取三个数据的前一千个数据
helperPlotReps(ECGData);

% 小波变化scalogram的例子
% 做连续小波变换CWT
% 数据长度1000，频率128，使用8频度分解以12为数量
% Fs = 128; 
% fb = cwtfilterbank('SignalLength',1000,'SamplingFrequency',Fs,'VoicesPerOctave',12); 
% sig = ECGData.Data(1,1:1000); 
% [cfs,frq] = wt(fb,sig); 
% t =(0:999)/ Fs; figure; pcolor(t,frq,abs(cfs))
% set(gca,'yscale','log'); shading interp ; axis tight ; 
% title('Scalogram'); xlabel('Time(s)'); ylabel('Frequency(Hz)')

% 利用辅助函数创建训练数据连续小波变换的图像
disp("是否需要重新创建训练数据小波变化图：");
iflag = input('“是”输入1，“否”输入0:');
if iflag == 1
    helperCreateRGBfromTF(ECGData,practiceDir,practiceDataDir);
    disp("训练数据CWT scalogram图像绘制完毕，进入下一步...");
else
    disp("训练数据CWT scalogram图像绘制完毕，进入下一步...");
end

% 将绘图数据路径、文件夹名称（即病情label）等信息存储在matlab中
allImages = imageDatastore(fullfile(practiceDir,practiceDataDir),...
                           'IncludeSubfolders',true,'LabelSource',...
                           'foldernames');
disp("CWT scalogram存入matlab，进入下一步...");

% 将随机种子设为全局默认值
% rng default
% 将随机种子设为固定值
rng(1);
% 将每个图像数据按标签随机分为两份
% 一份为训练数据，一份为验证数据，比例为0.8
% imgsTrain和imgsValidation也是imgDataStore模式，存储图像信息
[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized');
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]);
disp("googlenet喂入数据准备完毕，进入下一步...");

% ====================训练GoogLeNet====================

% 加载预训练的GoogLeNet
net = googlenet;
% 提取GoogLeNet中的神经网络图层图
lgraph = layerGraph(net);
% 提取GoogLeNet的神经层数：144层
numberOfLayers = numel(lgraph.Layers);
% 把GoogLeNet的神经网络图画出来
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph);
title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);

% 重新配置神经网络
% 删除GoogLeNet最后四层
% pool5-drop_7x7_s1是droplayer用来防止过拟合，概率0.5
% 'loss3-classifier','prob','output'用来分类，适用于1000类
lgraph = removeLayers(lgraph,{ 'pool5-drop_7x7_s1',...
                               'loss3-classifier','prob','output' });
% 我们要分类的数量就是3个label的数量
numClasses = numel(categories(imgsTrain.Labels));
% 设置新的最后四层
newLayers = [
    % 新的drop层，概率0.6
    dropoutLayer(0.6,'Name','newDropout')
    % 新的全连接层
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',...
                        5,'BiasLearnRateFactor',5)
    % 新的softmax层，可以使值小的部分也被取到
    softmaxLayer('Name','softmax')
    % 分类输出层
    classificationLayer('Name','classoutput')];
% 将新的四层加在处理过的GoogLeNet后
lgraph = addLayers(lgraph,newLayers); % 合并
lgraph = connectLayers(lgraph,'pool5-7x7_s1','newDropout'); % 链接
inputSize = net.Layers(1).InputSize; % 按GoogleNet格式训练

% 设置训练参数
options = trainingOptions('sgdm',...
    'MiniBatchSize',15,...
    'MaxEpochs',20,...
    'InitialLearnRate',1e-4,...
    'ValidationData',imgsValidation,...
    'ValidationFrequency',10,...
    'ValidationPatience',Inf,...
    'Verbose',1,...
    'ExecutionEnvironment','cpu',...
    'Plots','training-progress');

% 对编辑后的GoogLenet进行训练
% imgsTrain 训练图像存储集
% lgraph    神经网络图层
% options   训练参数
rng default
trainedGN = trainNetwork(imgsTrain,lgraph,options);

trainedGN.Layers(end-2:end);
% 输出结果类的格式为{'ARR','CHF','NSR'}的数组
cNames = trainedGN.Layers(end).ClassNames;
disp("测试分类矩阵：");
disp(cNames);

% 用验证集确认准确度
% YPred 类别
% probs 预测打分
[YPred,probs] = classify(trainedGN,imgsValidation);
accuracy = mean(YPred==imgsValidation.Labels);
display(['GoogLeNet Accuracy: ',num2str(accuracy)]);
% 输出预测值，按照结果类打分，分数高的为预测结果
display(predict(trainedGN,imgsValidation));

% ====================预处理测试GoogLeNet的网上数据====================

% 对测试数据转化成图像
[~,signalLength] = size(signList);
fb = cwtfilterbank('SignalLength',signalLength,'VoicesPerOctave',12);
r = size(signList,1);
% 记好下载的数据类型作为文件名
testLabel = ["ARR";"NSR"; "CHF"];
for ii = 1:r
    cfs = abs(fb.wt(signList(ii,:)));
    im = ind2rgb(im2uint8(rescale(cfs)),jet(128));
    imgLoc = fullfile(fullfile(testDir,testDataDir));
    imFileName = strcat(char(testLabel(ii)),'.jpg');
    imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName));
end
imgsTest = imageDatastore(fullfile(testDir,testDataDir),...
                          'IncludeSubfolders',true,...
                          'LabelSource','foldernames');
disp("测试图像数据集存储完毕，进入下一步...");

% ====================用训练好的GoogLeNet进行预测====================

% 输出测试结果
result = predict(trainedGN,imgsTest);
[max_result, result_index] = max(result,[],2);
disp("打印预测结果的打分矩阵")
disp(result);
testResult = [cNames(result_index(1)); ...
              cNames(result_index(2)); ...
              cNames(result_index(3))];
disp("***************以下为预测结果***************")
disp(["预测分类:",testResult(1),",正确分类：",imgsTest.Files(1)]);
disp(["预测分类:",testResult(2),",正确分类：",imgsTest.Files(1)]);
disp(["预测分类:",testResult(3),",正确分类：",imgsTest.Files(1)]);