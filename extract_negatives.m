%% 
baseDir = 'C:\Users\Tom\OneDrive\Documents\CITS4402\Pedestrian-Detection\';
annotDir = [baseDir 'PennFudanPed\Annotation\'];

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
        crop_width = bbox(3);
        shift=150;
        
        right_shift_xmin = bbox(1)+crop_width;
        if right_shift_xmin + crop_width <= width 
            neg_right =  [right_shift_xmin, bbox(2), bbox(3), bbox(4)];
            crop_right = imcrop(I, neg_right);
            imwrite(crop_right, strcat('C:\negative\', files(ii).name, num2str(jj),'right.png'));
        end
        
        left_shift_xmin = bbox(1)-crop_width;
        if left_shift_xmin >= 0
            neg_left = [left_shift_xmin, bbox(2), bbox(3), bbox(4)];
            crop_left = imcrop(I, neg_left);
            imwrite(crop_left, strcat('C:\negative\', files(ii).name, num2str(jj),'left.png'));
        end
    end
    hold off;    
    pause(0.5);
end
