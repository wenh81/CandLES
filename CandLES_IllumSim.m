%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_IllumSim - GUI for showing Illumination results
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_IllumSim(varargin)
% CANDLES_ILLUMSIM MATLAB code for CandLES_IllumSim.fig
%      CANDLES_ILLUMSIM, by itself, creates a new CANDLES_ILLUMSIM or raises the existing
%      singleton*.
%
%      H = CANDLES_ILLUMSIM returns the handle to a new CANDLES_ILLUMSIM or the handle to
%      the existing singleton*.
%
%      CANDLES_ILLUMSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_ILLUMSIM.M with the given input arguments.
%
%      CANDLES_ILLUMSIM('Property','Value',...) creates a new CANDLES_ILLUMSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_IllumSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_IllumSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_IllumSim

% Last Modified by GUIDE v2.5 19-Aug-2016 14:30:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_IllumSim_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_IllumSim_OutputFcn, ...
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


% --- Executes just before CandLES_IllumSim is made visible.
function CandLES_IllumSim_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_IllumSim (see VARARGIN)

% Choose default command line output for CandLES_IllumSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesIllumSim', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv      = getappdata(h_GUI_CandlesMain,'mainEnv');
IllumSimEnv  = mainEnv;
PLANE_SELECT = min(1,mainEnv.rm.height);
ILLUM_RES    = candles_classes.candlesResIllum();
setappdata(hObject, 'IllumSimEnv', IllumSimEnv);
setappdata(hObject, 'PLANE_SELECT', PLANE_SELECT);
setappdata(hObject, 'ILLUM_RES', ILLUM_RES);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_IllumSim_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global STR

response = questdlg(STR.MSG29, '',STR.YES,STR.NO,STR.YES);
if strcmp(response,STR.YES)
    % FIXME: Need to add option to save results and add a variable to
    % indicate if the most recent results have been saved.
    
    % Remove the handle value of the figure from root (handle 0) and then
    % delete (close) the figure
    rmappdata(0, 'h_GUI_CandlesIllumSim');
    delete(hObject);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function edit_Plane_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT = max(min(str2double(get(hObject,'String')),IllumSimEnv.rm.height),0);
setappdata(h_GUI_CandlesIllumSim, 'PLANE_SELECT', PLANE_SELECT);
set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function slider_Plane_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT = max(min(get(hObject,'Value'),IllumSimEnv.rm.height),0);
setappdata(h_GUI_CandlesIllumSim, 'PLANE_SELECT', PLANE_SELECT);
set_values(); % Set the values and display room with selected TX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULTS DISPLAY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function pushbutton_GenRes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
PLANE_SELECT          = getappdata(h_GUI_CandlesIllumSim,'PLANE_SELECT');
ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');

ILLUM_RES = IllumSimEnv.getIllum(PLANE_SELECT, ILLUM_RES);

setappdata(h_GUI_CandlesIllumSim, 'ILLUM_RES', ILLUM_RES);
set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function pushbutton_GenRes2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenRes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');
global STR

% Get a vector input from the user
prompt={STR.MSG33};
name = STR.MSG34;
defaultans = {''};
options.Interpreter = 'tex';
plane_list = inputdlg(prompt,name,[1 40],defaultans,options);
if ~isempty(plane_list)
    plane_list = str2num(plane_list{1}); %#ok<ST2NM>

    % Error check plane_list
    plane_list = plane_list(plane_list >= 0);
    plane_list = plane_list(plane_list <= IllumSimEnv.rm.height);

    % Generate results for the planes in plane_list
    ILLUM_RES = IllumSimEnv.getIllum(plane_list, ILLUM_RES);

    setappdata(h_GUI_CandlesIllumSim, 'ILLUM_RES', ILLUM_RES);
end
set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function pushbutton_GenResVideo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenResVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');
handles               = guidata(h_GUI_CandlesIllumSim);

scale_for_maximum = get(handles.checkbox_colorscale,'Value');
ILLUM_RES.display_video(scale_for_maximum);

% --------------------------------------------------------------------
function pushbutton_DispRes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DispRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
PLANE_SELECT          = getappdata(h_GUI_CandlesIllumSim,'PLANE_SELECT');
ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');
handles               = guidata(h_GUI_CandlesIllumSim);

% Display the results on the GUI results axes
figure();
my_ax = axes();
display_results(ILLUM_RES, PLANE_SELECT, handles, my_ax);

% --------------------------------------------------------------------
function radiobutton_results_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_cdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_values();

% --------------------------------------------------------------------
function checkbox_colorscale_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_colorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_values();

% --------------------------------------------------------------------
function checkbox_cdfAll_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_cdfAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_values();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display results on my_ax axes
% --------------------------------------------------------------------
function display_results(ILLUM_RES, PLANE_SELECT, handles, my_ax)
    global STR

    % Display results
    res_view = get(get(handles.panel_display,'SelectedObject'),'String');
    if (~ILLUM_RES.results_exist(PLANE_SELECT))
        % Display a message on the Results Axis
        cla(my_ax,'reset')
        text(0.23, 0.5, sprintf(STR.MSG30), 'Parent', my_ax);
    else
        scale_for_maximum = get(handles.checkbox_colorscale,'Value');
        if(strcmp(res_view,'Spatial Plane'))
            ILLUM_RES.display_plane(PLANE_SELECT, scale_for_maximum, my_ax);
        elseif(strcmp(res_view,'CDF'))
            cdf_all = get(handles.checkbox_cdfAll,'Value');
            ILLUM_RES.display_cdf(PLANE_SELECT, scale_for_maximum, cdf_all, my_ax);
        end
    end
    

% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesIllumSim = getappdata(0,'h_GUI_CandlesIllumSim');
    IllumSimEnv           = getappdata(h_GUI_CandlesIllumSim,'IllumSimEnv');
    PLANE_SELECT          = getappdata(h_GUI_CandlesIllumSim,'PLANE_SELECT');
    ILLUM_RES             = getappdata(h_GUI_CandlesIllumSim,'ILLUM_RES');
    handles               = guidata(h_GUI_CandlesIllumSim);
    
    % Display room with selected Plane
    IllumSimEnv.display_room(handles.axes_room, 4, PLANE_SELECT);
    
    % Display the results on the GUI results axes
    display_results(ILLUM_RES, PLANE_SELECT, handles, handles.axes_results);
    
    % Set Selection Boxes
    set(handles.edit_Plane,'String',num2str(PLANE_SELECT));
    set(handles.slider_Plane,'Value',PLANE_SELECT);
    set(handles.slider_Plane,'Min',0);
    set(handles.slider_Plane,'Max',IllumSimEnv.rm.height);
    set(handles.slider_Plane,'SliderStep',[0.1/IllumSimEnv.rm.height, ...
                                             1/IllumSimEnv.rm.height]);
    


