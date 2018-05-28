function montageImageDatastore(imds, label)
%MONTAGEIMAGEDATASTORE Display 16 images as montage
%
% montageImageDatastore(imds, label)
%
%       imds : Image datastore
%       label : Labels used for picking up images
%
% Copyright 2016 The MathWorks, Inc.

tmp = splitEachLabel(imds, 16, 'Include', label);

I = readall(tmp);
I = cat(4, I{:});
montage(I)
