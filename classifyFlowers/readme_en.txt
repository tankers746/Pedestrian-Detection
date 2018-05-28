< Description of each programs >

classifyFlowers.m
--> Classify the similar flowers, 'Dandelion' and 'ColtsFoot'

searchSimilarFlowers.m
--> Search flowers similar to a certain flower using KNN
--> This program uses the image data folder 'FlowerMixed'

detectAnomaly.m
--> Sort flowers according to anomaly scores which 1-class SVM calculates
--> This program uses the image data folder 'ImagesWithAnomalies'

We use image data from Oxford Flower Dataset.

About Oxford Flower Dataset :
http://www.robots.ox.ac.uk/~vgg/data/flowers/17/index.html

< What's You Need >

- MATLAB
- Neural Network Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox
- Computer Vision System Toolbox
- Parallel Computing Toolbox (If you use GPU)


< Preparation >

1. Please install support package for alexnet (pretrained model)

2. Please execute the following script to set up data folders

>> setupScript


Copyright 2018 The MathWorks, Inc.
