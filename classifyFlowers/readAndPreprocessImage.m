function Iout = readAndPreprocessImage(filename, imageSize)
%READANDPREPROCESSIMAGE Read and preprocess images
%
% readAndPreprocessImage(filename, imageSize)
%
%       filename : File name
%       imageSize : Resolution of input image
%
% Copyright 2016 The MathWorks, Inc.

I = imread(filename);

if ismatrix(I)
    I = cat(3, I, I, I);
end

Iout = imresize(I, imageSize(1:2));

end

