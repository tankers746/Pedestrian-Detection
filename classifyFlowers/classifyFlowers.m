% Setup MatConVent
run('../matconvnet/matlab/vl_setupnn');

%% Image Category Classification Using Deep Learning
% This example shows how to use a pre-trained Convolutional Neural Network
% (CNN) as a feature extractor for training an image category classifier. 
%
% Copyright 2018 The MathWorks, Inc.

%% Initialization

clear, close all

%% Load Pre-trained CNN
net = load('../imagenet-vgg-f.mat');
convnet = vl_simplenn_tidy(net) ;
imageSize = net.meta.inputs.size;
%% Load Images

imds = imageDatastore(fullfile('../', {'positive', 'negative'}), ...
    'LabelSource', 'foldernames');
imds.ReadFcn = @(filename)readAndPreprocessImage(filename, imageSize);

%% 

figure, montageImageDatastore(imds, 'positive')
figure, montageImageDatastore(imds, 'negative')

%% Prepare Training and Test Image Sets

[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');

%% Extract Features using CNN

featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer, 'MiniBatchSize', 1);

%% Train A Multiclass SVM Classifier Using CNN Features

classifier = fitcsvm(trainingFeatures, trainingSet.Labels);

%% Evaluate Classifier

testFeatures = activations(convnet, testSet, featureLayer, 'MiniBatchSize', 32);
predictedLabels = predict(classifier, testFeatures);
C = confusionmat(testSet.Labels, predictedLabels);
%imagesc(C);
