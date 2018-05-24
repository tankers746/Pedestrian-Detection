%% Anomaly Detection Using DeCAF
%
% Copyright 2018 The MathWorks, Inc.

%% Initialization

clear, close all

%% Load Pre-trained CNN

convnet = alexnet;
imageSize = convnet.Layers(1).InputSize;

%% Load Images

imds = imageDatastore('./ImageData/ImagesWithAnomalies');
imds.ReadFcn = @(filename)readAndPreprocessImage(filename, imageSize);

%% Extract Features using CNN

featureLayer = 'fc7';
X = activations(convnet, imds, featureLayer, 'MiniBatchSize', 1);

%% Calculate Anomaly Score using One-Class SVM

W = ones(size(X, 1), 1);
d = fitcsvm(X, W, 'KernelScale', 'auto', 'Standardize', false, 'OutlierFraction', 0.05);

[~, score] = predict(d, X);
[score_sorted, idx] = sort(score);

%% Display Images Sorted by Anomaly Scores

im = readall(imds);
im = im(idx);

I = cat(4, im{:});
montage(I, 'Size', [8 12])
