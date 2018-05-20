positiveDir = fullfile('positive');
positiveImages = imageDatastore(positiveDir,'labelsource','foldernames');

outputSize = [100 50];
hogfeaturelength = 1980;
cellsize = [8 8];
numImages = ceil(numel(positiveImages.Files)/2);
trainingFeatures = zeros(numImages,hogfeaturelength,'single');

for i = 1:numImages
    img = readimage(positiveImages, i);
    img = rgb2gray(img);
    
    trainingFeatures(i,:) = extractHOGFeatures(img,'Cellsize',cellsize);
end

trainingLabels = positiveImages.Labels(1:numImages);