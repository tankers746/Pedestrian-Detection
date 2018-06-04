% load classifier
load HOGclassifier
%load image
[FileName,FilePath ]= uigetfile({'*','All Files'});
ExPath = fullfile(FilePath, FileName);
rgb = imread(ExPath);
im = rgb2gray(rgb);

cellsize = [6 6];

[Oy,Ox] = size(im); % get original image size, for later

tic
% set sliding window size, must return a 50 by 100 segment for the HOG
% classifier used
sx = 50;
sy = 100;
Xoverlap = 12;
Yoverlap = 21;
% slide
f1 = figure(1); clf;
imshow(rgb); hold on

storage = [0 0 0 0];
n = 1;
%for sf = 0.6:0.1:0.9
scaleFactor = 100/0.65; % tune denominator for pedestrian height as a fraction of image height
scale = scaleFactor/Oy;
im2 = imresize(im,scale);
[Ny,Nx] = size(im2); % new image sizes

for hx = 1:Xoverlap:(Nx-sx)
    for hy = 1:Yoverlap:(Ny-sy)
        seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
% extract HOG features from bounding box
        features = extractHOGFeatures(seg,'CellSize',cellsize);
        [label, score] = predict(classifier,features);
        if (label == 'positive') && (abs(score(1)) > 0.7) && (abs(score(1)) < 1)
                %rectangle('Position', [hx/scale hy/scale sx/scale sy/scale])
                storage(n,1:2) = score;
                storage(n,3:4) = [hx hy];
                n = n + 1;
        end
    end
end

%end
toc
% check confidence