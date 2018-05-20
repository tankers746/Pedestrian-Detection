%% 
baseDir = 'C:\Users\Tom\OneDrive\Documents\CITS4402\Pedestrian-Detection\';
annotDir = [baseDir 'PennFudanPed\Annotation\'];

ratio = 2;
image_width = 50;

files = dir(annotDir); files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    I = imread([baseDir record.imgname]);
    [height, width, depth] = size(I);
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        if(bbox(3) >= image_width)
            new_width = max(bbox(3), bbox(4)/ratio);
            
            max_height = min(height, new_width*ratio);
            new_height = max(max_height, bbox(4));
            
            new_width = new_height / ratio;
            height_diff = new_height - bbox(4);
            width_diff = new_width - bbox(3);
            bbox(1) = bbox(1) - width_diff / 2;
            bbox(2) = bbox(2) - height_diff / 2;
            bbox(3) = new_width;
            bbox(4) = new_height;
            cropped_image = imcrop(I, bbox);
            resized = imresize(cropped_image, [image_width*ratio, image_width]);
            imwrite(resized, strcat('C:\cropped\', files(ii).name, num2str(jj),'.png'));
        end
    end
    hold off;    
    pause(0.5);
end
