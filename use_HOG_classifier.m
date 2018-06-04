% load classifier
load HOGclassifier
%load image
[FileName,FilePath ]= uigetfile({'*','All Files'});
ExPath = fullfile(FilePath, FileName);
rgb = imread(ExPath);
im = rgb2gray(rgb);

[Oy,Ox] = size(im); % get original image size, for later
scaleFactor = 100/0.6; % tune denominator for pedestrian height as a fraction of image height
scale = scaleFactor/Oy;
im2 = imresize(im,scale);
[Ny,Nx] = size(im2); % new image sizes
% set sliding window size
sx = 50;
sy = 100;
overlap = 5;
% slide
imshow(im2); hold on
for hx = 1:overlap:(Nx-sx)
    for hy = 1:overlap:(Ny-sy)
        seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
% extract HOG features from bounding box
        features = extractHOGFeatures(seg);
        [label, score] = predict(classifier,features);
        if label == 'positive'
            rectangle('Position', [hx hy sx sy])
        end
    end
end

% check confidence