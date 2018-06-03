clear; close all; clc;
% Setup VLFeat
%run('./vlfeat/toolbox/vl_setup');
% Setup MatConVent and libsvm
run('./matconvnet/matlab/vl_setupnn');
addpath('./libsvm')


%Load the pre-trained net
net = load('imagenet-vgg-f.mat');
net = vl_simplenn_tidy(net) ;
 
%Remove the last layer (softmax layer)
net.layers = net.layers(1 : end - 1);
 
%% Set up image data
categories = {'positive', 'negative'};
imds = imageDatastore(fullfile('.\', categories), 'LabelSource', 'foldernames');
tbl = countEachLabel(imds);

%% Use the smallest overlap set
minSetCount = min(tbl{:,2});

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

%% Divide data into training and testing sets
[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');


trainingFeatures = zeros(1000,length(trainingSet.Files));
for i = 1 : length(trainingSet.Files)
    waitbar (i/ length(trainingSet.Files));
     
    % Preprocess the data and get it ready for the CNN
    im = readimage(trainingSet, i);
    im_ = single(im); % note: 0-255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage);
 
    % run the CNN to compute the features
    feats = vl_simplenn(net, im_) ;
    trainingFeatures(:,i) = squeeze(feats(end).x);
end

testFeatures = zeros(1000,length(testSet.Files));
for i = 1 : length(testSet.Files)
    waitbar (i/ length(testSet.Files));
     
    % Preprocess the data and get it ready for the CNN
    im = readimage(testSet, i);
    im_ = single(im); % note: 0-255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage);
 
    % run the CNN to compute the features
    feats = vl_simplenn(net, im_) ;
    testFeatures(:,i) = squeeze(feats(end).x);
end
 
%% Classifier training
testLabels = testSet.Labels;
trainingLabels = trainingSet.Labels;
 
classifier = fitcecoc(trainingFeatures', trainingLabels); 
predictedLabels = predict(classifier, testFeatures');
 
confMat = confusionmat(testLabels, predictedLabels);
 
% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
 
% Display the mean accuracy
mean(diag(confMat))