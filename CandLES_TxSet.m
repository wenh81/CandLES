%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandLES_TxSet - GUI for updating CandLES Transmitter settings.
%    Author: Michael Rahaim
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suppress unnecessary warnings
%#ok<*INUSL>
%#ok<*INUSD>
%#ok<*DEFNU>
function varargout = CandLES_TxSet(varargin)
% CANDLES_TXSET MATLAB code for CandLES_TxSet.fig
%      CANDLES_TXSET, by itself, creates a new CANDLES_TXSET or raises the existing
%      singleton*.
%
%      H = CANDLES_TXSET returns the handle to a new CANDLES_TXSET or the handle to
%      the existing singleton*.
%
%      CANDLES_TXSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANDLES_TXSET.M with the given input arguments.
%
%      CANDLES_TXSET('Property','Value',...) creates a new CANDLES_TXSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CandLES_TxSet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CandLES_TxSet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CandLES_TxSet

% Last Modified by GUIDE v2.5 23-Oct-2015 13:24:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CandLES_TxSet_OpeningFcn, ...
                   'gui_OutputFcn',  @CandLES_TxSet_OutputFcn, ...
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


% --- Executes just before CandLES_TxSet is made visible.
function CandLES_TxSet_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CandLES_TxSet (see VARARGIN)

% Choose default command line output for CandLES_TxSet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load images using function from CandLES.m
h_GUI_CandlesMain = getappdata(0,'h_GUI_CandlesMain');
feval(getappdata(h_GUI_CandlesMain,'fhLoadImages'),handles);

% Store the handle value for the figure in root (handle 0)
setappdata(0, 'h_GUI_CandlesTxSet', hObject);

% Generate a temporary CandLES environment and store in the GUI handle so
% that it can be edited without modifying the main environment until saved.
mainEnv   = getappdata(h_GUI_CandlesMain,'mainEnv');
txSetEnv  = mainEnv;
TX_SELECT = 1;
setappdata(hObject, 'txSetEnv', txSetEnv);
setappdata(hObject, 'TX_SELECT', TX_SELECT);
set_values(); % Set the values and display environment


% --- Outputs from this function are returned to the command line.
function varargout = CandLES_TxSet_OutputFcn(hObject, ~, handles) 
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

% Hint: delete(hObject) closes the figure
response = questdlg('Keep updates?', '','Yes','No','Yes');
if strcmp(response,'Yes')
    % FIXME: Need to store the updated info back to mainEnv or have a save
    % option where this becomes a question "Close without save" and only
    % shows up if changes have been made and not saved yet.
    
end
% Remove the handle value of the main figure from root (handle 0) and
% delete (close) the figure
rmappdata(0, 'h_GUI_CandlesTxSet');
delete(hObject);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% TX MENU FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_addTx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_addTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

[txSetEnv, TX_SELECT]  = txSetEnv.addTx();

setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
set_values(); % Set the values and display room with selected TX

% --------------------------------------------------------------------
function menu_deleteTx_Callback(hObject, eventdata, handles)
% hObject    handle to menu_deleteTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');

[txSetEnv, ERR]  = txSetEnv.removeTx(TX_SELECT);
TX_SELECT = min(TX_SELECT, length(txSetEnv.txs));
if(ERR == 1)
    errordlg('CandLES environment must contain a Tx.','Tx Delete');
else
    % NOTE: Do this in the else statement so that the error box doesn't 
    % get hidden when the GUI is updated in set_values()
    setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
    set_values(); % Set the values and display room with selected TX
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% TX SELECT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function popup_tx_select_Callback(hObject, eventdata, handles)
% hObject    handle to popup_tx_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT = get(hObject,'Value');
setappdata(h_GUI_CandlesTxSet, 'TX_SELECT', TX_SELECT);
set_values(); % Set the values and display room with selected TX


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX LOCATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Tx_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tx_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
temp               = str2double(get(hObject,'String'));

[txSetEnv, ERR] = txSetEnv.setTxPos(TX_SELECT,'x',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
end
set_values();

function edit_Tx_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tx_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
temp               = str2double(get(hObject,'String'));

[txSetEnv, ERR] = txSetEnv.setTxPos(TX_SELECT,'y',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
end
set_values();

function edit_Tx_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tx_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
temp               = str2double(get(hObject,'String'));

[txSetEnv, ERR] = txSetEnv.setTxPos(TX_SELECT,'z',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
end
set_values();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% TX ROTATION FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_Tx_az_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tx_az (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
temp               = str2double(get(hObject,'String'));

[txSetEnv, ERR] = txSetEnv.setTxPos(TX_SELECT,'az',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
end
set_values();

function edit_Tx_el_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Tx_el (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
temp               = str2double(get(hObject,'String'));

[txSetEnv, ERR] = txSetEnv.setTxPos(TX_SELECT,'el',temp);
% FIXME: Add warning boxes for ERR and bring to front after set_values
if (ERR == 0)
    setappdata(h_GUI_CandlesTxSet, 'txSetEnv', txSetEnv);
end
set_values();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ADDITIONAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the values within the GUI
% --------------------------------------------------------------------
function set_values()
    h_GUI_CandlesTxSet = getappdata(0,'h_GUI_CandlesTxSet');
    TX_SELECT          = getappdata(h_GUI_CandlesTxSet,'TX_SELECT');
    txSetEnv           = getappdata(h_GUI_CandlesTxSet,'txSetEnv');
    handles            = guidata(h_GUI_CandlesTxSet);
    
    % Display room with selected Tx
    SYS_display_room(handles.axes_room, txSetEnv, 1, TX_SELECT);
    
    % Set Location boxes
    set(handles.edit_Tx_x,'string',num2str(txSetEnv.txs(TX_SELECT).x));
    set(handles.edit_Tx_y,'string',num2str(txSetEnv.txs(TX_SELECT).y));
    set(handles.edit_Tx_z,'string',num2str(txSetEnv.txs(TX_SELECT).z));

    % Set Rotation boxes
    [my_az,my_el] = txSetEnv.txs(TX_SELECT).get_angle_deg();
    set(handles.edit_Tx_az,'string',num2str(my_az));
    set(handles.edit_Tx_el,'string',num2str(my_el));

    % Set Tx Selection box
    set(handles.popup_tx_select,'String',1:1:length(txSetEnv.txs));
    set(handles.popup_tx_select,'Value',TX_SELECT);

    