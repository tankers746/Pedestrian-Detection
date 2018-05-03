%% 
baseDir = 'C:\EVERYTHING\TEACHING\CITS4402-Computer-Vision\2017_Sem1\2017project\Data_toolkit\';
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
