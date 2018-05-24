

imset = imageSet('\\uniwa.uwa.edu.au\userhome\Students3\21490093\My Documents\CITS4402\Pedestrian-Detection\PennFudanPed\PNGImages', 'recursive');
[tr_set,test_set] = imset.partition(700);
test_set = test_set.partition(200);