%% Setup Script for Transfer Learning using Alex Net
%
% Copyright 2018 The MathWorks, Inc.

%% Set Image Data Directories

clear
targetDir = pwd;

% Create the image data folder
imageDataDir = fullfile(targetDir, 'ImageData');
image17FlowersDir = fullfile(imageDataDir, '17Flowers');

%% Download Oxford Flower Dataset and untar

if ~exist(image17FlowersDir, 'dir')
    mkdir(image17FlowersDir)
end

% Download the tgz file
url = 'http://www.robots.ox.ac.uk/~vgg/data/flowers/17/17flowers.tgz';
imageDataFile = fullfile(image17FlowersDir, '17flowers.tgz');

if ~exist(imageDataFile, 'file')
     disp('Downloading 59MB Oxford Flower Dataset ...');
     untar(url, image17FlowersDir);
end

%% Split Images into Folders

Labels = {'Daffodil', 'Snowdrop', 'LilyValley', 'Bluebell', 'Crocus', ...
    'Iris', 'Tigerlily', 'Tulip', 'Fritillary', 'Sunflower', 'Daisy', 'ColtsFoot',...
    'Dandelion', 'Cowslip', 'Buttercup', 'Windflower', 'Pansy'};

for ii = 1:numel(Labels)
    
    targetDir = fullfile(image17FlowersDir, Labels{ii});
    
    if ~exist(targetDir, 'dir')
        mkdir(targetDir)
    end
    
    for jj = 1:80
        kk = 80 * (ii - 1) + jj;
        imageFile = sprintf('image_%04d.jpg', kk);
        imageFile = fullfile(image17FlowersDir, 'jpg', imageFile);
        movefile(imageFile, targetDir)        
    end
end

%% Create Data Folder with Various Flowers

targetDir = fullfile(imageDataDir, 'FlowersMixed');

if ~exist(targetDir, 'dir')
    mkdir(targetDir)
end

imds = imageDatastore(image17FlowersDir, 'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

imds = splitEachLabel(imds, 9, 'randomize');

for kk = 1:numel(imds.Files)
    copyfile(imds.Files{kk}, targetDir)
end

%% Create Data Folder with Anomalies

targetDir = fullfile(imageDataDir, 'ImagesWithAnomalies');

if ~exist(targetDir, 'dir')
    mkdir(targetDir)
end

% Copy all Dandelion flower as normal data
imageFiles = fullfile(image17FlowersDir, 'Dandelion', '*.jpg');
copyfile(imageFiles, targetDir)

% Copy 1 Daisy flower as an anomal data
imageFiles = fullfile(image17FlowersDir, 'Daisy', 'image_0801.jpg');
copyfile(imageFiles, targetDir)

% Copy 3 ColtsFoot flowers as anomal data
imageFiles = fullfile(image17FlowersDir, 'ColtsFoot', 'image_0887.jpg');
copyfile(imageFiles, targetDir)
imageFiles = fullfile(image17FlowersDir, 'ColtsFoot', 'image_0905.jpg');
copyfile(imageFiles, targetDir)
imageFiles = fullfile(image17FlowersDir, 'ColtsFoot', 'image_0909.jpg');
copyfile(imageFiles, targetDir)

% Copy 2 Buttercup flowers as anomal data
imageFiles = fullfile(image17FlowersDir, 'Buttercup', 'image_1124.jpg');
copyfile(imageFiles, targetDir)
imageFiles = fullfile(image17FlowersDir, 'Buttercup', 'image_1124.jpg');
copyfile(imageFiles, targetDir)

%%

% % Location of pre-trained "AlexNet"
% cnnURL = 'http://www.vlfeat.org/matconvnet/models/beta16/imagenet-caffe-alex.mat';
% 
% % Store CNN model in a temporary folder
% cnnMatFile = fullfile(targetDir, 'imagenet-caffe-alex.mat');
% 
% if ~exist(cnnMatFile, 'file') % download only once
%     disp('Downloading 240MB pre-trained CNN model...');
%     websave(cnnMatFile, cnnURL);
% end
