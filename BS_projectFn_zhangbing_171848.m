%�ļ�����  :  BS_ProjectFn_zhangbing_171848
%ʵ�ֹ���  :  ����С���任������������ECG���ݽ��з���
%                          
%�ο�����  : Signal Classification with Wavelet Analysis and Convolutional Neural Networks
%https://ww2.mathworks.cn/help/wavelet/examples/signal-classification-with-
%wavelet-analysis-and-convolutional-neural-networks.html
%
%������Ϣ  :  171848-�ű�
%             537405288@qq.com
%             18795969032
%�޶�ʱ��  :  2018��6��30��2��06��
%���ø�ʽ  :  ��
%��������  :  ��

%��Ŀ·��
addpath(genpath(pwd));
clc;

% ====================����·�������ݼ�׼��====================
% ѵ�����ݵĲ���·��
practiceDir = 'practiceData'; 
practiceDataDir = 'practice';
testDir = 'testData';
testDataDir = 'test';

% �������ϵ�ѵ������mat�ļ�
% mat�ļ���ʽ��data��label������
% dataΪ162 * 65536�ĸ�ʽ����Ϊ162���ĵ���������������Ƶ��128HZ
% labelΪ162 * 1 �ĸ�ʽ����¼����162���ĵ����ݵĲ������͡�
load(fullfile(practiceDir,'physionet_ECG_data-master','ECGData.mat'))
disp(fullfile(practiceDir,'physionet_ECG_data-master','ECGData.mat'))

% �����������ѡ��Ĳ������ݵ�mat�ļ�
% 100mΪARR
% 16786mΪNRC
% chf06mΪCHF
% �����������val�����������г���200�ķ���֮����������
load(fullfile(testDir,'dataMat','100m.mat'))
ARR100 = val/200;
load(fullfile(testDir,'dataMat','16786m.mat'));
NSR16786 = val/200;
load(fullfile(testDir,'dataMat','chf06m.mat'));
CHF06 = val/200;
clear val;
%��Ϊ�����ʲ�ͬ�����Ƚ������ʶ���Ϊ128Hz
ARR_test = resample(ARR100,128,360);
NSR_test = resample(NSR16786,128,128);
CHF_test = resample(CHF06,128,250);
signList(1,:) = ARR_test(1:65536)';
signList(2,:) = NSR_test(1:65536)';
signList(3,:) = CHF_test(1:65536)';

clear ARR_test NSR_test CHF_test ARR100 NSR16786 CHF06
display("ECG��������׼�����");
% ====================ѵ������Ԥ����====================

% ���ø�����������ѵ�����ݵ�ѵ���ļ���
disp("�Ƿ���Ҫ���´����洢ѵ������ͼƬ���ļ��У�");
iflag = input('���ǡ�����1����������0:');
if iflag == 1
    helperCreateECGDirectories(ECGData,practiceDir,practiceDataDir);
    disp("ѵ������·��׼����ϣ�������һ��...");
else
    disp("ѵ������·��׼����ϣ�������һ��...");
end

% ���ø���������������������ARR��CHF��NSR�ĵ�һ������ͼ
% ����ͼѡȡ�������ݵ�ǰһǧ������
helperPlotReps(ECGData);

% С���仯scalogram������
% ������С���任CWT
% ���ݳ���1000��Ƶ��128��ʹ��8Ƶ�ȷֽ���12Ϊ����
% Fs = 128; 
% fb = cwtfilterbank('SignalLength',1000,'SamplingFrequency',Fs,'VoicesPerOctave',12); 
% sig = ECGData.Data(1,1:1000); 
% [cfs,frq] = wt(fb,sig); 
% t =(0:999)/ Fs; figure; pcolor(t,frq,abs(cfs))
% set(gca,'yscale','log'); shading interp ; axis tight ; 
% title('Scalogram'); xlabel('Time(s)'); ylabel('Frequency(Hz)')

% ���ø�����������ѵ����������С���任��ͼ��
disp("�Ƿ���Ҫ���´���ѵ������С���仯ͼ��");
iflag = input('���ǡ�����1����������0:');
if iflag == 1
    helperCreateRGBfromTF(ECGData,practiceDir,practiceDataDir);
    disp("ѵ������CWT scalogramͼ�������ϣ�������һ��...");
else
    disp("ѵ������CWT scalogramͼ�������ϣ�������һ��...");
end

% ����ͼ����·�����ļ������ƣ�������label������Ϣ�洢��matlab��
allImages = imageDatastore(fullfile(practiceDir,practiceDataDir),...
                           'IncludeSubfolders',true,'LabelSource',...
                           'foldernames');
disp("CWT scalogram����matlab��������һ��...");

% �����������Ϊȫ��Ĭ��ֵ
% rng default
% �����������Ϊ�̶�ֵ
rng(1);
% ��ÿ��ͼ�����ݰ���ǩ�����Ϊ����
% һ��Ϊѵ�����ݣ�һ��Ϊ��֤���ݣ�����Ϊ0.8
% imgsTrain��imgsValidationҲ��imgDataStoreģʽ���洢ͼ����Ϣ
[imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,'randomized');
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]);
disp("googlenetι������׼����ϣ�������һ��...");

% ====================ѵ��GoogLeNet====================

% ����Ԥѵ����GoogLeNet
net = googlenet;
% ��ȡGoogLeNet�е�������ͼ��ͼ
lgraph = layerGraph(net);
% ��ȡGoogLeNet���񾭲�����144��
numberOfLayers = numel(lgraph.Layers);
% ��GoogLeNet��������ͼ������
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph);
title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);

% ��������������
% ɾ��GoogLeNet����Ĳ�
% pool5-drop_7x7_s1��droplayer������ֹ����ϣ�����0.5
% 'loss3-classifier','prob','output'�������࣬������1000��
lgraph = removeLayers(lgraph,{ 'pool5-drop_7x7_s1',...
                               'loss3-classifier','prob','output' });
% ����Ҫ�������������3��label������
numClasses = numel(categories(imgsTrain.Labels));
% �����µ�����Ĳ�
newLayers = [
    % �µ�drop�㣬����0.6
    dropoutLayer(0.6,'Name','newDropout')
    % �µ�ȫ���Ӳ�
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',...
                        5,'BiasLearnRateFactor',5)
    % �µ�softmax�㣬����ʹֵС�Ĳ���Ҳ��ȡ��
    softmaxLayer('Name','softmax')
    % ���������
    classificationLayer('Name','classoutput')];
% ���µ��Ĳ���ڴ������GoogLeNet��
lgraph = addLayers(lgraph,newLayers); % �ϲ�
lgraph = connectLayers(lgraph,'pool5-7x7_s1','newDropout'); % ����
inputSize = net.Layers(1).InputSize; % ��GoogleNet��ʽѵ��

% ����ѵ������
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

% �Ա༭���GoogLenet����ѵ��
% imgsTrain ѵ��ͼ��洢��
% lgraph    ������ͼ��
% options   ѵ������
rng default
trainedGN = trainNetwork(imgsTrain,lgraph,options);

trainedGN.Layers(end-2:end);
% ��������ĸ�ʽΪ{'ARR','CHF','NSR'}������
cNames = trainedGN.Layers(end).ClassNames;
disp("���Է������");
disp(cNames);

% ����֤��ȷ��׼ȷ��
% YPred ���
% probs Ԥ����
[YPred,probs] = classify(trainedGN,imgsValidation);
accuracy = mean(YPred==imgsValidation.Labels);
display(['GoogLeNet Accuracy: ',num2str(accuracy)]);
% ���Ԥ��ֵ�����ս�����֣������ߵ�ΪԤ����
display(predict(trainedGN,imgsValidation));

% ====================Ԥ�������GoogLeNet����������====================

% �Բ�������ת����ͼ��
[~,signalLength] = size(signList);
fb = cwtfilterbank('SignalLength',signalLength,'VoicesPerOctave',12);
r = size(signList,1);
% �Ǻ����ص�����������Ϊ�ļ���
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
disp("����ͼ�����ݼ��洢��ϣ�������һ��...");

% ====================��ѵ���õ�GoogLeNet����Ԥ��====================

% ������Խ��
result = predict(trainedGN,imgsTest);
[max_result, result_index] = max(result,[],2);
disp("��ӡԤ�����Ĵ�־���")
disp(result);
testResult = [cNames(result_index(1)); ...
              cNames(result_index(2)); ...
              cNames(result_index(3))];
disp("***************����ΪԤ����***************")
disp(["Ԥ�����:",testResult(1),",��ȷ���ࣺ",imgsTest.Files(1)]);
disp(["Ԥ�����:",testResult(2),",��ȷ���ࣺ",imgsTest.Files(1)]);
disp(["Ԥ�����:",testResult(3),",��ȷ���ࣺ",imgsTest.Files(1)]);