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

handles.output = hObject;
run('./vlfeat/toolbox/vl_setup');
addpath('./libsvm');
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
        handles.rgb =  imread(filePath);  
        handles.gray = rgb2gray(handles.rgb);
        guidata(hObject, handles);
        axes(handles.axes1); 
        imshow(handles.rgb);
        handles.axes1.YAxis.Visible = 'off';
        handles.axes1.XAxis.Visible = 'off'; 
    end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    tic
    load hog_classifier
    cellsize = 6;
    [Oy,Ox] = size(handles.gray); % get original image size, for later
    % set sliding window size, must return a 50 by 100 segment for the HOG
    % classifier used
    sx = 50;
    sy = 100;
    Xoverlap = 24;
    Yoverlap = 30;

    bboxes = [0 0 0 0];
    scores = [0 0];
    n = 1;
    for sf = 0.4:0.4:0.8
        scaleFactor = 100/sf; % tune denominator for pedestrian height as a fraction of image height
        scale = scaleFactor/Oy;
        im2 = imresize(handles.gray, scale);
        [Ny,Nx] = size(im2); % new image sizes
        
        x_step = round(scale * Xoverlap);
        y_step = round(scale * Yoverlap);
        for hx = 1:x_step:(Nx-sx)
            for hy = 1:y_step:(Ny-sy)
                seg=im2(hy:(hy+sy-1),hx:(hx+sx-1));
                seg=single(seg);
                % extract HOG features from bounding box
                features = vl_hog(seg, cellsize);
                features = reshape(features, [], size(features,4))' ;
                [label, accuracy, prob] = svmpredict(0, double(features), classifier, '-b 1 -q');
                if (label == 1 & prob(1) > 0.7)
                        bbox = [hx/scale hy/scale (hx+sx)/scale (hy+sy)/scale];
                        bboxes(n,1:4) = bbox;
                        scores(n) = prob(1);
                        n = n + 1;
                end
            end
        end
    end
    imshow(handles.rgb)
    handles.axes1.YAxis.Visible = 'off';
    handles.axes1.XAxis.Visible = 'off'; 
    try
        [validBboxes] = non_max_supr_bbox(bboxes, scores(:), [Oy,Ox]); 
        for i = 1: size(bboxes, 1)
            if validBboxes(i) == 1
                bbox = [ bboxes(i, 1:2), bboxes(i, 3) - bboxes(i, 1), bboxes(i, 4) - bboxes(i, 2)];
                rectangle('Position', bbox, 'EdgeColor','g')
                text(bbox(1), bbox(2)-20, num2str(scores(i)), 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 14)
            end
        end
    end
    set(handles.text4,'String',toc);
    guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
hObject.YAxis.Visible = 'off';
hObject.XAxis.Visible = 'off';
