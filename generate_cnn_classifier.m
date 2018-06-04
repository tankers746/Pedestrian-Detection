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
[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');


trainingFeatures = zeros(length(trainingSet.Files), 1000);
trainingLabels = zeros(length(trainingSet.Labels), 1);
for i = 1 : length(trainingSet.Files)
    waitbar (i/ length(trainingSet.Files));
     
    % Preprocess the data and get it ready for the CNN
    im = readimage(trainingSet, i);
    im_ = single(im); % note: 0-255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage);
 
    % run the CNN to compute the features
    feats = vl_simplenn(net, im_) ;
    trainingFeatures(i, :) = squeeze(feats(end).x);
    if trainingSet.Labels(i) == 'positive'
        trainingLabels(i) = 1;
    else
        trainingLabels(i) = 0;
    end    
end

testFeatures = zeros(length(testSet.Files), 1000);
testLabels = zeros(length(testSet.Labels), 1);
for i = 1 : length(testSet.Files)
    waitbar (i/ length(testSet.Files));
     
    % Preprocess the data and get it ready for the CNN
    im = readimage(testSet, i);
    im_ = single(im); % note: 0-255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2));
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage);
 
    % run the CNN to compute the features
    feats = vl_simplenn(net, im_) ;
    testFeatures(i, :) = squeeze(feats(end).x);
    if testSet.Labels(i) == 'positive'
        testLabels(i) = 1;
    else
        testLabels(i) = 0;
    end
end
 
 
classifier = svmtrain(trainingLabels, trainingFeatures, '-t 0 -b 1'); 
[predict_label_L, accuracy_L, dec_values_L] = svmpredict(testLabels, testFeatures, classifier);

 
%confMat = confusionmat(testLabels, predictedLabels);
 
% Convert confusion matrix into percentage form
%confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
 
% Display the mean accuracy
%mean(diag(confMat))

%save classifier to disk
save('cnn_classifier.mat','classifier');
