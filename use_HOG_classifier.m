clear;
% load classifier
load hog_classifier
addpath('./libsvm')
run('./vlfeat/toolbox/vl_setup');
%load image
[FileName,FilePath ]= uigetfile({'*','All Files'});
ExPath = fullfile(FilePath, FileName);
rgb = imread(ExPath);
im = rgb2gray(rgb);

cellsize = 6;

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

bboxes = [0 0 0 0];
scores = [0 0];
n = 1;
for sf = 0.5:0.1:1
    scaleFactor = 100/sf; % tune denominator for pedestrian height as a fraction of image height
    scale = scaleFactor/Oy;
    im2 = imresize(im,scale);
    [Ny,Nx] = size(im2); % new image sizes

    for hx = 1:Xoverlap:(Nx-sx)
        for hy = 1:Yoverlap:(Ny-sy)
            seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
            seg=single(seg);
    % extract HOG features from bounding box
            features = vl_hog(seg, cellsize);
            features = reshape(features, [], size(features,4))' ;
            [label, accuracy, prob] = svmpredict(0, double(features), classifier, '-b 1');
            if (label == 1)
                    bbox = [hx/scale hy/scale sx/scale sy/scale];
                    bboxes(n,1:4) = bbox;
                    scores(n) = prob(1);
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

for i = 1: size(bboxes, 1)
    rectangle('Position', bboxes(i, 1:4),...
                        'EdgeColor','g')
end

figure; imshow(rgb); hold on
[selectedBbox,selectedScore] = selectStrongestBbox(bboxes,scores(:), 'OverlapThreshold', 0.2); 
for i = 1: size(selectedBbox, 1)
    rectangle('Position', selectedBbox(i, 1:4),...
                        'EdgeColor','g')
end
%end
toc
% check confidence