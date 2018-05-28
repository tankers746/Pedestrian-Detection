< 各プログラムの概要 >

classifyFlowers.m
--> タンポポとフキタンポポという似た花を分類します

searchSimilarFlowers.m
--> KNNを使って、特定の花の画像に似た花の画像を見つけ出します
--> このコードは、FlowerMixed というフォルダにあるデータを使います

detectAnomaly.m
--> 1クラス SVM の計算する異常スコアに沿って画像をソートします（異常検出）
--> このコードは、ImagesWithAnomalies というフォルダにあるデータを使います。

画像データは Oxford Flower Dataset のものを使っています。

Oxford Flower Dataset について :
http://www.robots.ox.ac.uk/~vgg/data/flowers/17/index.html

< 必要となるもの >

- MATLAB
- Neural Network Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox
- Computer Vision System Toolbox
- Parallel Computing Toolbox（GPUを使う場合）


< 準備作業 >

１．次のURLを参考に、学習済みモデル alexnet のサポートパッケージをインストールして下さい。

https://jp.mathworks.com/matlabcentral/answers/315764-alexnet

２．次のコマンドを実行して、データフォルダのセットアップをして下さい。

>> setupScript


Copyright 2018 The MathWorks, Inc.

