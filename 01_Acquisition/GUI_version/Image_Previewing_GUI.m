function varargout = Image_Previewing_GUI(varargin)
% IMAGE_PREVIEWING_GUI MATLAB code for Image_Previewing_GUI.fig
%      IMAGE_PREVIEWING_GUI, by itself, creates a new IMAGE_PREVIEWING_GUI or raises the existing
%      singleton*.
%
%      H = IMAGE_PREVIEWING_GUI returns the handle to a new IMAGE_PREVIEWING_GUI or the handle to
%      the existing singleton*.
%
%      IMAGE_PREVIEWING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_PREVIEWING_GUI.M with the given input arguments.
%
%      IMAGE_PREVIEWING_GUI('Property','Value',...) creates a new IMAGE_PREVIEWING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Image_Previewing_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Image_Previewing_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Image_Previewing_GUI

% Last Modified by GUIDE v2.5 31-Oct-2015 19:42:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Image_Previewing_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Image_Previewing_GUI_OutputFcn, ...
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


% --- Executes just before Image_Previewing_GUI is made visible.
function Image_Previewing_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_Previewing_GUI (see VARARGIN)

% Choose default command line output for Image_Previewing_GUI
handles.output = hObject;
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%% Make sure you have access to all functions/subfucntions
addpath(genpath('D:\ZT_Matlab'));

%% Move to spooling disk and find "live-recording" directory
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');livepath=fscanf(fileID,'%s');fclose(fileID);
handles.livepath=livepath;
cd(livepath);
%%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_Previewing_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% --- Executes on button press in live_upd_toggle.
function live_upd_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to live_upd_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of live_upd_toggle


set(handles.path_string,'String',handles.livepath);
fi_flag=0;
t_pr=0;
MouseCordb=0;
  send_location=0;
 % k=0;
while get(handles.live_upd_toggle,'Value')==1;
    t_pr=t_pr+1;
    % try
    
    [F,R,Fnum,Rnum]=read_most_recent_fluoroANDreflection();
    
    c_upper_limit_r=get(handles.clim_up_ref,'Value'); c_lower_limit_r=get(handles.clim_down_ref,'Value');
    c_upper_limit_f=get(handles.clim_up_flr,'Value'); c_lower_limit_f=get(handles.clim_down_flr,'Value');
    
    if fi_flag==0;
        hh_r=handles.im_axis_ref; axes(hh_r);hhh_r=imshow(R,[c_lower_limit_r c_upper_limit_r]);
        hh_f=handles.im_axis_flr; axes(hh_f);hhh_f=imshow(F,[c_lower_limit_f c_upper_limit_f]);
        fi_flag=1; drawnow;
    else
        set(hhh_r,'CData',R); set(hh_r,'CLim',[c_lower_limit_r c_upper_limit_r]);
        title(hh_r,['Reflection Image\_Lim:[' num2str(c_lower_limit_r) '-' num2str(c_upper_limit_r) '] Frame' num2str(Rnum)]);
        drawnow limitrate;
        set(hhh_f,'CData',F); set(hh_f,'CLim',[c_lower_limit_f c_upper_limit_f]);
        title(hh_f,['Fluoro Image\_Lim:[' num2str(c_lower_limit_f) '-' num2str(c_upper_limit_f) '] Frame' num2str(Fnum)]);
        drawnow limitrate;
    

        try
            try delete(h4_r); delete(h5_r);   catch; end
        trackingImageF_ID = fopen('TrackingXYimage_current','r');XY_Imag_TRC=fread(trackingImageF_ID,[1,2],'uint16');fclose(trackingImageF_ID);
        trackingGalvoF_ID = fopen('TrackingXYgalvo','r');XY_Galvo_TRC=fread(trackingGalvoF_ID,[1,2],'uint16');fclose(trackingGalvoF_ID);
        hold(hh_r,'on');
        h4_r=plot(hh_r,XY_Imag_TRC(1),XY_Imag_TRC(2),'or','MarkerSize',7);
        h5_r=plot(hh_r,XY_Galvo_TRC(1),XY_Galvo_TRC(2),'*g','MarkerSize',12); 
        drawnow limitrate;          
        catch
        end

      
     % set(hhh_r,'ButtonDownFcn', 'send_location=1');
      MouseCordn= get(hh_r, 'currentpoint');
     %MouseCordn=[MouseCordn(1,1) MouseCordn(1,2)]
      if ~sum(sum(MouseCordb-MouseCordn))==0
          send_location=1;
          
      end
     
       set(handles.Send_Coord,'String',[num2str(send_location)]);
       set(handles.Coord_X,'String',[num2str(MouseCordn(1))]);
       set(handles.Coord_Y,'String',[num2str(MouseCordn(2))]);

          
       if send_location==1
             %  MouseCord;         %   display(MouseCord);
            fileID = fopen('MouseOveride','w+');fwrite(fileID,uint16(MouseCordn),'uint16');fclose(fileID); 
            send_location=0;
       end
     MouseCordb=MouseCordn;

    end
    % catch     display(['Updating during like view has issues...' num2str(t_pr)]; end
end


% --- Executes on button press in upd_path_button.
function upd_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to upd_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('Preloading images... Please wait')
recorded_path=get(handles.path_string,'String');
cd(recorded_path);
sizeR=fread(fopen('Size_RefImag'),[1 2],'uint16');
sizeF=fread(fopen('Size_FluoroImag'),[1 2],'uint16');

All_refl_imag=dir('R_*');
All_fluoro_imag=dir('F_*');

f_frames_number=length(All_fluoro_imag);
i_f_frames=1;
fi_flag=0;
display('Images Preloades. Preview will start soon...')
set(handles.total_frames_str,'String',num2str(f_frames_number));
MouseCordPreviews=[0];
k=0;
while get(handles.upd_path_button,'Value')==1;
  
    i_0to1=get(handles.time_slider,'Value');
    i_f_frames=round(i_0to1*f_frames_number);
    
    
    if get(handles.play_rec_toggle,'Value')==0;
        i_0to1=get(handles.time_slider,'Value');
        i_f_frames=round(i_0to1*f_frames_number);
        
    else
        speed_multipler=str2double(get(handles.playback_speed_str,'String'));
        i_f_frames=i_f_frames+1*speed_multipler;
        i_0to1=i_f_frames./f_frames_number;
        if i_f_frames>=f_frames_number
            i_f_frames=1;
            i_0to1=i_f_frames./f_frames_number;            
        end
        set(handles.time_slider,'Value',i_0to1);
    end
    set(handles.current_frame_str,'String',[num2str(i_0to1.*100)]);
    
    %% Find correspondance between frames
    % display(i./f_frames_number)
    i_f=round((length(All_fluoro_imag)*i_f_frames./f_frames_number));
    i_r=round((length(All_refl_imag)*i_f_frames./f_frames_number));
    
    try
    %% Load images.
    Rfile=fopen(All_refl_imag(i_r).name);R=fread(Rfile,sizeR,'uint8');fclose(Rfile);
    Ffile=fopen(All_fluoro_imag(i_f).name);F=fread(Ffile,sizeF,'uint16');fclose(Ffile);
    catch
    end
    %% Show images.
    
    c_upper_limit_r=get(handles.clim_up_ref,'Value'); c_lower_limit_r=get(handles.clim_down_ref,'Value');
    c_upper_limit_f=get(handles.clim_up_flr,'Value'); c_lower_limit_f=get(handles.clim_down_flr,'Value');
    
    if fi_flag==0;
        hh_r=handles.im_axis_ref; axes(hh_r);hhh_r=imshow(R,[c_lower_limit_r c_upper_limit_r]);
        hh_f=handles.im_axis_flr; axes(hh_f);hhh_f=imshow(F,[c_lower_limit_f c_upper_limit_f]);
        fi_flag=1; drawnow;
    else
        set(hhh_r,'CData',R); set(hh_r,'CLim',[c_lower_limit_r c_upper_limit_r]);
        title(hh_r,['Reflection Image\_Lim:[' num2str(c_lower_limit_r) '-' num2str(c_upper_limit_r) '] Perc' num2str(i_0to1) 'N' All_refl_imag(i_r).name ]);
        drawnow limitrate;
        set(hhh_f,'CData',F); set(hh_f,'CLim',[c_lower_limit_f c_upper_limit_f]);
        title(hh_f,['Fluoro Image\_Lim:[' num2str(c_lower_limit_f) '-' num2str(c_upper_limit_f) '] Perc' num2str(i_0to1) 'N' All_fluoro_imag(i_f).name ]);
        drawnow limitrate;
        
        
   
       
    end
end



%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% --- Outputs from this function are returned to the command line.
function varargout = Image_Previewing_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function clim_up_ref_Callback(hObject, eventdata, handles)
% hObject    handle to clim_up_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function clim_up_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_up_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function clim_down_ref_Callback(hObject, eventdata, handles)
% hObject    handle to clim_down_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function clim_down_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_down_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function clim_up_flr_Callback(hObject, eventdata, handles)
% hObject    handle to clim_up_flr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function clim_up_flr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_up_flr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function clim_down_flr_Callback(hObject, eventdata, handles)
% hObject    handle to clim_down_flr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function clim_down_flr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clim_down_flr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function path_string_Callback(hObject, eventdata, handles)
% hObject    handle to path_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of path_string as text
%        str2double(get(hObject,'String')) returns contents of path_string as a double


% --- Executes during object creation, after setting all properties.
function path_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in play_rec_toggle.
function play_rec_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to play_rec_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of play_rec_toggle



function playback_speed_str_Callback(hObject, eventdata, handles)
% hObject    handle to playback_speed_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playback_speed_str as text
%        str2double(get(hObject,'String')) returns contents of playback_speed_str as a double


% --- Executes during object creation, after setting all properties.
function playback_speed_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playback_speed_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
