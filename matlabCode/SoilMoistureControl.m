function varargout = SoilMoistureControl(varargin)
% SOILMOISTURECONTROL MATLAB code for SoilMoistureControl.fig
%      SOILMOISTURECONTROL, by itself, creates a new SOILMOISTURECONTROL or raises the existing
%      singleton*.
%
%      H = SOILMOISTURECONTROL returns the handle to a new SOILMOISTURECONTROL or the handle to
%      the existing singleton*.
%
%      SOILMOISTURECONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOILMOISTURECONTROL.M with the given input arguments.
%
%      SOILMOISTURECONTROL('Property','Value',...) creates a new SOILMOISTURECONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SoilMoistureControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SoilMoistureControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SoilMoistureControl

% Last Modified by GUIDE v2.5 20-Jan-2019 12:53:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SoilMoistureControl_OpeningFcn, ...
                   'gui_OutputFcn',  @SoilMoistureControl_OutputFcn, ...
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


% --- Executes just before SoilMoistureControl is made visible.
function SoilMoistureControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SoilMoistureControl (see VARARGIN)

% Choose default command line output for SoilMoistureControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SoilMoistureControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = SoilMoistureControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


clear all;
if ~isempty(instrfind)
    fclose(instrfind);
    delete (instrfind);
end
global s;
global mode;
mode = 'A';
s = serial(seriallist);
fclose(s);
fopen(s);
global x
global y
global maxData
global counter
x = []; y = [];
maxData = 50;
counter = 0;
readMoisture();



function setObj(text1,text2,text3)
set(findobj(0, 'tag', text1), text2, text3);

function x = getObj(text1,text2)
x = get(findobj(0, 'tag', text1), text2);

function readMoisture()
global s;
global running;
global x
global y
global maxData
global counter
running = true;
fscanf(s);
fprintf(s, 'Q');
while running
   pause(0.5);
   values = strsplit(fscanf(s),';');
   setObj('text2','string', 'Moisture(%): '+string(values{1}));
   setObj('text3','string', 'Pump Intensity(%): '+string(str2num(values{2})/100*100));
   y = [y, str2num(values{1})];
   x = [x, counter];
   if length(y) > maxData
       y(1) = [];
       x(1) = [];
   end
   plot(x,y)
   xlabel('Time (seconds)');
   ylabel('Moisture (%)');
   counter = counter + 1;
   drawnow;
 end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setObj('pushbutton1', 'enable', 'off');
setObj('pushbutton2', 'enable', 'off');
setObj('pushbutton3', 'enable', 'on');
setObj('slider1', 'enable', 'off');
global s;
fprintf(s, 'Q');

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setObj('pushbutton2', 'enable', 'on');
setObj('pushbutton1', 'enable', 'on');
setObj('pushbutton3', 'enable', 'off');
setObj('slider1', 'enable', 'on');

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global status;
global pumpIntensity;
pumpIntensity = int8(getObj('slider1', 'value'));
setObj('text4', 'string', 'Value Pump Intensitiy(%): ' + string(pumpIntensity));
%disp(pumpIntensity);
if pumpIntensity == 0
    setObj('text5', 'string', 'Status: OFF');
elseif pumpIntensity == 100
    setObj('text5', 'string', 'Status: HIGH');
elseif pumpIntensity > 0 && pumpIntensity < 33
    setObj('text5', 'string', 'Status: LOW');
elseif pumpIntensity >= 33 && pumpIntensity < 66
    setObj('text5', 'string', 'Status: MEDIUM');
elseif pumpIntensity >= 66
    setObj('text5', 'string', 'Status: HIGH');
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global s;
global pumpIntensity;
fprintf(s,'%s','W'+string(pumpIntensity));

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
global s;
global running;
running = false;
fprintf(s, 'T');
fclose(s);
