% Setup VLFeat
run('./vlfeat/toolbox/vl_setup');
% Setup MatConVent
run('./matconvnet/matlab/vl_setupnn');

% Load a model and upgrade it to MatConvNet current version.
net = load('imagenet-vgg-f.mat') ;
net = vl_simplenn_tidy(net) ;

% Obtain and preprocess an image.
im = imread('C:/cropped/FudanPed00038.txt1.png') ;
im_ = single(im) ; % note: 255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;

% Run the CNN.
res = vl_simplenn(net, im_) ;

% Show the classification result.
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im_) ;
title(sprintf('%s (%d), score %.3f',...
   net.meta.classes.description{best}, best, bestScore)) ;


% Before starting to fine tune it is important to remove the
% last two layers of a trained model and replace them with a new fully
% connected layer. For VGG-16 the following commands can do the job.

net = []; % your network structure

% load pre-trained network
old_net = load('imagenet-vgg-f.mat') ;

numClasses=2;

% add dropout layers in network (saved model has dropout removed)
%drop1 = struct('name', 'dropout6', 'type', 'dropout', 'rate', 0.5);
%drop2 = struct('name', 'dropout7', 'type', 'dropout', 'rate', 0.5);
%old_net.layers = [old_net.layers(1:33) drop1 old_net.layers(34:35)
%drop2 old_net.layers(36:end)] ;

% ignore classification and last softmax layers (we will insert our own)
net=old_net;
net.layers = net.layers(1:end-2);

% add our own conv layer and loss layer This is for Simple NN
net.layers{end+1} = struct('type', 'conv','name','fc8', ...
     'weights', {{zeros(1,1,4096,numClasses, 'single'), ...
      zeros(numClasses,1,'single')}}, ...
      'stride',1,'pad',0,'learningRate',[1,2],'weightDecay',[1,0],'momentum',{{zeros(1,1,4096,numClasses, 'single'),

zeros(numClasses,1,'single')}},'precious',false);
net.layers{end+1} = struct('type', 'softmaxloss') ; % add loss layer

net = vl_simplenn_tidy(net) ;
inputSize = net.meta.inputs.size;
%featureLayer = 'fc7';
%trainingFeatures = activations(convnet, trainingSet, featureLayer, 'MiniBatchSize', 1);




filePath = fullfile('./positive', 'FudanPed00007.txt1.png');
im =  imread(filePath);
im = im2single(im);

cellSize = 8;
hog = vl_hog(im, cellSize) ;
imhog = vl_hog('render', hog) ;
figure(2) ; clf ;
imagesc(imhog) ;
axis image off ; colormap gray ;

