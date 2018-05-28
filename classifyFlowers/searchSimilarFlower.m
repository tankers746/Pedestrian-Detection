%% Search Similar Flowers Using DeCAF
%
% Copyright 2016 The MathWorks, Inc.

%% Initialization

clear, close all

%% Load Pre-trained CNN

convnet = alexnet;
imageSize = convnet.Layers(1).InputSize;

%% Load Images

imds = imageDatastore('./ImageData/FlowersMixed');
imds.ReadFcn = @(filename)readAndPreprocessImage(filename, imageSize);

im = readall(imds);
im = cat(4, im{:});

%% Extract Features using CNN

featureLayer = 'fc7';
feat = activations(convnet, im, featureLayer, 'MiniBatchSize', 1);

%% Search Similar Flowers Using KNN

N = 87;

subplot(2, 1, 1)
imshow(im(:, :, :, N))

subplot(2, 1, 2)
[idx, d] = knnsearch(feat, feat(N, :), 'K', 17);
idx(1) = [];

montage(im(:, :, :, idx))

