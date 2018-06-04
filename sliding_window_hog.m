clear; close all; clc;
tic
% Setup MatConVent and libsvm
addpath('./libsvm')
run('./matconvnet/matlab/vl_setupnn');
%Load the pre-trained net
net = load('imagenet-vgg-f.mat');
net = vl_simplenn_tidy(net) ;
%Remove the last layer (softmax layer)
net.layers = net.layers(1 : end - 2);

% load classifier
load hog_classifier
%load image
im = imread('.\PennFudanPed\PNGImages\FudanPed00001.png');


[Oy,Ox] = size(im); % get original image size, for later
scaleFactor = 100/0.6; % tune denominator for pedestrian height as a fraction of image height
scale = scaleFactor/Oy;
im2 = imresize(im,scale);

[Ny,Nx] = size(im2); % new image sizes
% set sliding window size
sx = 50;
sy = 100;
overlap = 10;

% slide
imshow(im2); hold on
for hx = 1:overlap:(Nx-sx)
    for hy = 1:overlap:(Ny-sy)
        seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
        %seg=imresize(seg, net.meta.normalization.imageSize(1:2));
        %seg = single(seg); % note: 0-255 range
        %seg = bsxfun(@minus, seg, net.meta.normalization.averageImage);
        
        % extract HOG features from bounding box
        features = extractHOGFeatures(seg);
        [predict_label_L, accuracy_L, dec_values_L] = svmpredict(0, double(features), classifier, '-b 1');
        
        if ((predict_label_L == 1) & (dec_values_L(1) > 0.80))
            dec_values_L
            rectangle('Position', [hx hy sx sy]);
        end
    end
end
toc
% check confidence