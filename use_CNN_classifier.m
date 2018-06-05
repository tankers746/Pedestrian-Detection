clear,clc;
addpath('./libsvm')
% Setup MatConVent and libsvm
run('./matconvnet/matlab/vl_setupnn');
%Load the pre-trained net
net = load('imagenet-vgg-f.mat');
net = vl_simplenn_tidy(net) ;
%Remove the last layer (softmax layer)
net.layers = net.layers(1 : end - 1);

% load cnn_classifier
load cnn_classifier
%load image
[FileName,FilePath ]= uigetfile({'*','All Files'});
ExPath = fullfile(FilePath, FileName);
rgb = imread(ExPath);
im = single(rgb); % note: 0-255 range

[Oy,Ox] = size(im); % get original image size, for later


tic
% set sliding window size, must return a 50 by 100 segment for the HOG
% classifier used
sx = 50;
sy = 100;
Xoverlap = 12;
Yoverlap = 15;
% slide
f1 = figure(1); clf;
imshow(rgb); hold on

storage = [0 0 0 0 0];
n = 1;
for sf = 0.6:0.1:9
    scaleFactor = 100/sf; % tune denominator for pedestrian height as a fraction of image height
    scale = scaleFactor/Oy;
    im2 = imresize(im,scale);
    [Ny,Nx] = size(im2); % new image sizes

    for hx = 1:Xoverlap:(Nx-sx)
        for hy = 1:Yoverlap:(Ny-sy)
            seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
            seg=imresize(seg, net.meta.normalization.imageSize(1:2));
            seg = bsxfun(@minus, seg, net.meta.normalization.averageImage);

            feats = vl_simplenn(net, seg) ;
            features(:) = squeeze(feats(end).x);
            [label, accuracy, prob] = svmpredict(0, double(features), classifier, '-b 1');
            if (label == 1)
                    bbox = [hx/scale hy/scale sx/scale sy/scale];
                    storage(n,1:4) = bbox;
                    storage(n,5) = prob(1);
                    n = n + 1;
            end
        end
    %     if storage ~= [0 0 0 0 0]
    %     [M, I] = min(storage(:,2));
    %     rectangle('Position',[storage(I,4)/scale storage(I,5)/scale sx/scale sy/scale],...
    %         'EdgeColor','g')
    % %     storage(I,:)
    %     
    %     end

    end
end

for i = 1: length(storage)
    rectangle('Position', storage(i,1:4),...
                        'EdgeColor','g')
end

figure; imshow(rgb); hold on
[selectedBbox,selectedScore] = selectStrongestBbox(storage(:,1:4),storage(:,5), 'OverlapThreshold', 0.1); 
for i = 1: size(selectedBbox)
    rectangle('Position', selectedBbox(i,:),...
                        'EdgeColor','g')
end
%end
toc