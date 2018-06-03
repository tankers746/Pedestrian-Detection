function varargout = pedestrian_detection(varargin)
% PEDESTRIAN_DETECTION MATLAB code for pedestrian_detection.fig
%      PEDESTRIAN_DETECTION, by itself, creates a new PEDESTRIAN_DETECTION or raises the existing
%      singleton*.
%
%      H = PEDESTRIAN_DETECTION returns the handle to a new PEDESTRIAN_DETECTION or the handle to
%      the existing singleton*.
%
%      PEDESTRIAN_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PEDESTRIAN_DETECTION.M with the given input arguments.
%
%      PEDESTRIAN_DETECTION('Property','Value',...) creates a new PEDESTRIAN_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pedestrian_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pedestrian_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pedestrian_detection

% Last Modified by GUIDE v2.5 03-May-2018 14:38:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pedestrian_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @pedestrian_detection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pedestrian_detection is made visible.
function pedestrian_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pedestrian_detection (see VARARGIN)

% Choose default command line output for pedestrian_detection
run('./matconvnet/matlab/vl_setupnn');
%Load the pre-trained net
handles.net = load('imagenet-vgg-f.mat');
handles.net = vl_simplenn_tidy(handles.net) ;
 
%Remove the last layer (softmax layer)
handles.net.layers = handles.net.layers(1 : end - 1);
handles.output = hObject;
handles.classifier = load('.\classifier.mat');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pedestrian_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pedestrian_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        [file, folder] = uigetfile(...    
        {'*.jpg; *.JPG; *.jpeg; *.JPEG; *.img; *.IMG; *.tif; *.TIF; *.tiff; *.TIFF; *.png; *.PNG;', 'Supported Files (*.jpg,*.img,*.tiff,*.png)'; ...
        '*.jpg','jpg Files (*.jpg)';...
        '*.JPG','JPG Files (*.JPG)';...
        '*.jpeg','jpeg Files (*.jpeg)';...
        '*.JPEG','JPEG Files (*.JPEG)';...
        '*.img','img Files (*.img)';...
        '*.IMG','IMG Files (*.IMG)';...
        '*.tif','tif Files (*.tif)';...
        '*.TIF','TIF Files (*.TIF)';...
        '*.tiff','tiff Files (*.tiff)';...
        '*.TIFF','TIFF Files (*.TIFF)';...
        '*.png','png Files (*.png)';...
        '*.PNG','PNG Files (*.PNG)'});

        filePath = fullfile(folder, file);
        handles.image =  imread(filePath);  
        guidata(hObject, handles);
        axes(handles.axes1); 
        imshow(handles.image);
        handles.axes1.YAxis.Visible = 'off';
        handles.axes1.XAxis.Visible = 'off'; 
    end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    im = handles.image; % note: 0-255 range
% Step 2. Detect ROI          % Convert to gray for detection
    [bboxes, flow] = findPet(rgb2gray(im),opticalFlowFarneback);   % Find bounding boxes
    if ~isempty(bboxes)
        img = zeros([handles.net.meta.normalization.imageSize 3 size(bboxes,1)]);
        for ii = 1:size(bboxes,1)
            test = imresize(imcrop(im,bboxes(ii,:)),handles.net.meta.normalization.imageSize(1:2));
            figure; imshow(test);
            % Step 3: Extract image features and predict label
            feats = vl_simplenn(handles.net, test) ;
            imageFeatures(:) = squeeze(feats(end).x);
            label = predict(handles.classifier, imageFeatures);

            % Step 4: Annotation
            handles.image = insertObjectAnnotation(handles.image,'Rectangle',bboxes(ii,:),cellstr(label),'FontSize',40);

        end
    end
    imshow(handles.image);





% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
hObject.YAxis.Visible = 'off';
hObject.XAxis.Visible = 'off';
