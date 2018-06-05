clear; close all; clc;

% Setup libsvm
addpath('./libsvm')

%% Set up image data
categories = {'positive', 'negative'};
imds = imageDatastore(fullfile('.\', categories), 'LabelSource', 'foldernames');
tbl = countEachLabel(imds);

%% Use the smallest overlap set
minSetCount = min(tbl{:,2});

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

%% Divide data into training and testing sets
%[trainingSet, testSet] = splitEachLabel(imds, 0, 'randomize');
trainingSet = imds;


%% Hog config
outputSize = [100 50];
hogfeaturelength = 3780;
cellsize = [6 6];

%% Extract HoG features from training set
trainingFeatures = double(zeros(length(trainingSet.Files), hogfeaturelength,'single'));
trainingLabels = zeros(length(trainingSet.Labels), 1);
for i = 1:length(trainingSet.Files)
    waitbar (i/ length(trainingSet.Files));
    img = readimage(trainingSet, i);
    if(size(img,3)==3)
        img = rgb2gray(img);
    end
    trainingFeatures(i, :) = extractHOGFeatures(img,'Cellsize',cellsize);
    if trainingSet.Labels(i) == 'positive'
        trainingLabels(i) = 1;
    else
        trainingLabels(i) = 0;
    end
end

%% Extract HoG Features from test set
%{
testFeatures = double(zeros(length(testSet.Files), hogfeaturelength,'single'));
testLabels = zeros(length(testSet.Labels), 1);
for i = 1:length(testSet.Files)
    waitbar (i/ length(testSet.Files));
    img = readimage(testSet, i);
    testFeatures(i, :) = extractHOGFeatures(img,'Cellsize',cellsize);
    if testSet.Labels(i) == 'positive'
        testLabels(i) = 1;
    else
        testLabels(i) = 0;
    end
end
%}
 
classifier = svmtrain(trainingLabels, trainingFeatures, '-t 0 -b 1'); 
%[predict_label_L, accuracy_L, dec_values_L] = svmpredict(testLabels, testFeatures, classifier);

%save classifier to disk
save('hog_classifier.mat','classifier');
