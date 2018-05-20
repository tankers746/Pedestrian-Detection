%% 
baseDir = 'C:\Users\Tom\OneDrive\Documents\CITS4402\Pedestrian-Detection\';
annotDir = [baseDir 'PennFudanPed\Annotation\'];

files = dir(annotDir); files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    I = imread([baseDir record.imgname]);
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        cropped_image = imcrop(I, bbox);
        imwrite(cropped_image, strcat('C:\cropped\', files(ii).name, num2str(jj),'.png'));
    end
    hold off;    
    pause(0.5);
end
