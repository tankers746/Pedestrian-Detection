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

%% Extract HoG features from training set
outputSize = [100 50];
hogfeaturelength = 3780;
cellsize = [6 6];
numImages = length(trainingSet.Files);
trainingFeatures = zeros(numImages,hogfeaturelength,'single');

for i = 1:numImages
    img = readimage(trainingSet, i);
    img = rgb2gray(img);
    
    trainingFeatures(i,:) = extractHOGFeatures(img,'Cellsize',cellsize);
end

%% Extract HoG Features from test set
numImages = length(testSet.Files);
testFeatures = zeros(numImages,hogfeaturelength,'single');
for i = 1:numImages
    img = readimage(testSet, i);
    img = rgb2gray(img);
    
    testFeatures(i,:) = extractHOGFeatures(img,'Cellsize',cellsize);
end
%% Classifier training
testLabels = testSet.Labels;
trainingLabels = trainingSet.Labels;
 
classifier = fitcecoc(trainingFeatures, trainingLabels); 
predictedLabels = predict(classifier, testFeatures);
 
confMat = confusionmat(testLabels', predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
 
% Display the mean accuracy
mean(diag(confMat))
%save classifier to disk
save('HOGclassifier.mat','classifier');