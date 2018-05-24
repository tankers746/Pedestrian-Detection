%% 
baseDir = '\\uniwa.uwa.edu.au\userhome\Students3\21490093\My Documents\CITS4402\Pedestrian-Detection\';
annotDir = [baseDir 'PennFudanPed\Annotation\'];

files = dir(annotDir); files(1:2) = [];
close all;
for ii = 1 : length(files)
    fileName = [annotDir files(ii).name];
    record = PASreadrecord(fileName);
    imshow([baseDir record.imgname]); hold on;
    for jj = 1 : length(record.objects)
        bbox = record.objects(jj).bbox;
        bbox(3:4) = bbox(3:4) - bbox(1:2);
        rectangle('Position', bbox, 'EdgeColor','g','LineWidth',2);
    end
    hold off;    
    pause(0.5);
end
