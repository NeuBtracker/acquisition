function varargout = Acq_Controll(varargin)
% ACQ_CONTROLL MATLAB code for Acq_Controll.fig
%      ACQ_CONTROLL, by itself, creates a new ACQ_CONTROLL or raises the existing
%      singleton*.
%
%      H = ACQ_CONTROLL returns the handle to a new ACQ_CONTROLL or the handle to
%      the existing singleton*.
%
%      ACQ_CONTROLL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQ_CONTROLL.M with the given input arguments.
%
%      ACQ_CONTROLL('Property','Value',...) creates a new ACQ_CONTROLL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Acq_Controll_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Acq_Controll_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Acq_Controll

% Last Modified by GUIDE v2.5 18-May-2016 17:38:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Acq_Controll_OpeningFcn, ...
    'gui_OutputFcn',  @Acq_Controll_OutputFcn, ...
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


% --- Executes just before Acq_Controll is made visible.
function Acq_Controll_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Acq_Controll (see VARARGIN)

% Choose default command line output for Acq_Controll
handles.output = hObject;

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
handles.MessNumber=0;
addpath(genpath('D:\ZT_Matlab'));
load('D:\ZT_Matlab\Default_Fluoro_Camera_Params');
load('D:\ZT_Matlab\Default_Ref_Camera_Params');

handles.path4saving=create_saving_directory;
display([num2str(handles.MessNumber) 'Path Greated']);handles.MessNumber=handles.MessNumber+1;

set(handles.ref_exp_str,'String',num2str((RcP.ExposureTime)./1000));
set(handles.ref_bin_str,'String',num2str(RcP.BinningHorizontal));
set(handles.ref_gain_str,'String',num2str(RcP.Gain));

set(handles.flr_exp_str,'String',num2str((FcP.ExposureTime)*1000));
set(handles.flr_bin_str,'String',(FcP.AOIBinning));
set(handles.flr_gain_str,'String',(FcP.SimplePreAmpGainControl));

tp=num2str(fix(clock));
save(['Fluoro_Camera_Params_' num2str(tp)],'FcP');
save(['Ref_Camera_Params_' (tp)],'RcP');
save('Next_Fluoro_Camera_Params','FcP');
save('Next_Ref_Camera_Params','RcP');

system(' "D:\Program Files\MATLAB\R2015a\bin\matlab.exe" -nosplash -r "cd(''D:\ZT_Matlab\GUI_version''); run(''Image_Previewing_GUI.m'');" ');
display([num2str(handles.MessNumber) 'Preview SUB_GUI started(Matlab2015a)']);handles.MessNumber=handles.MessNumber+1;
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(0),'uint8');fclose(fileID);

%handles.j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR');
handles.j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR_ExtraFast');
%Scrip2Worker_FLUOR%Scrip2Worker_FLUOR_ExtraFast 
%handles.j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR4Solis');
%handles.j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR_EF');
handles.j2=batch(parcluster('local2'),'Scrip2Worker_REF');
%handles.j3=batch(parcluster('local3'),'Scrip2Worker_DeleteOldFiles');
handles.j3=batch(parcluster('local3'),'Scrip2Worker_DeleteOldFiles4MoveRecordings');

display([num2str(handles.MessNumber) 'CameraS are acquiring <3']);handles.MessNumber=handles.MessNumber+1;

devices = daq.getDevices;
s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
xValue=0; yValue=0; 
outputSingleScan(s,[xValue yValue]);

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Acq_Controll wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Acq_Controll_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on button press in restrart_refcam_btn.
function restrart_refcam_btn_Callback(hObject, eventdata, handles)
% hObject    handle to restrart_refcam_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('D:\ZT_Matlab\Default_Ref_Camera_Params');
RcP.ExposureTime=1000.*str2double(get(handles.ref_exp_str,'String'));
RcP.BinningHorizontal=str2double(get(handles.ref_bin_str,'String'));
RcP.Gain= str2double(get(handles.ref_gain_str,'String'));

tp=num2str(fix(clock));
save(['Ref_Camera_Params_' num2str(tp)],'RcP');
save('Next_Ref_Camera_Params','RcP');

cancel(handles.j2);
handles.j2=batch(parcluster('local2'),'Scrip2Worker_REF');
display([handles.MessNumber 'Reflection Camera is Re-initialized']);handles.MessNumber=handles.MessNumber+1;


% --- Executes on button press in restrart_fluorocam_btn.
function restrart_fluorocam_btn_Callback(hObject, eventdata, handles)
% hObject    handle to restrart_fluorocam_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('D:\ZT_Matlab\Default_Fluoro_Camera_Params');
FcP.ExposureTime=str2double(get(handles.flr_exp_str,'String'))./1000;
FcP.AOIBinning=(get(handles.flr_bin_str,'String'));
FcP.SimplePreAmpGainControl= (get(handles.flr_gain_str,'String'));

tp=num2str(fix(clock));
save(['Fluoro_Camera_Params_' num2str(tp)],'FcP');
save('Next_Fluoro_Camera_Params','FcP');

cancel(handles.j1);
handles.j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR');
display([handles.MessNumber 'Fluorescence Camera is Re-initialized']);handles.MessNumber=handles.MessNumber+1;


% --- Executes on button press in folder_description_pshb.
function folder_description_pshb_Callback(hObject, eventdata, handles)
% hObject    handle to folder_description_pshb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exp_description=(get(handles.exp_description_str,'String'));
fileID = fopen([handles.path4saving(1:12) handles.path4saving(13:16) '_' exp_description] ,'w');
fprintf(fileID,'%s',':)');
fclose(fileID);
display([num2str(handles.MessNumber) 'Folder Description Generated']);handles.MessNumber=handles.MessNumber+1;


% --- Executes on button press in load_registration_btn.
function load_registration_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_registration_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in load_registration_btn.

handles.ref2galvo_tmat=load(get(handles.tform2load_str,'String'));
% PUT HERE AXIS UPDATE.
display([num2str(handles.MessNumber) ':Prexisting Tranformation Matrix Loaded']); handles.MessNumber=handles.MessNumber+1;

% --- Executes on button press in manual_reg_btn.
function manual_reg_btn_Callback(hObject, eventdata, handles)
% hObject    handle to manual_reg_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('D:\ZT_Matlab\auto_opening_bash_shortcuts\Registraion.bat');
display([num2str(handles.MessNumber) ':SUB_VI for manual segmention opened']); handles.MessNumber=handles.MessNumber+1;


% --- Executes on button press in load_est_reg_btn.
function load_est_reg_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_est_reg_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('I:\NEXT_tform');
handles.ref2galvo_tmat=mytform;
display([num2str(handles.MessNumber) ':Estimated transformation loaded']); handles.MessNumber=handles.MessNumber+1;
guidata(hObject, handles);

% --- Executes on button press in update_reg_preview_btn.
function update_reg_preview_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_reg_preview_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tform_str,'String',num2str(handles.ref2galvo_tmat.tdata.T));

org_test_imag=im2bw(256-imread('D:\ZT_Matlab\Functions\Smiley4Registration.tif'));
org_test_imag(:,1:5)=256;org_test_imag(:,end-5:end)=256;org_test_imag(1:5,:)=256;org_test_imag(end-5:end,:)=256;
for i=25:25:175   org_test_imag(:,i)=100;   org_test_imag(i,:)=100;end
myaffine2d=affine2d(handles.ref2galvo_tmat.tdata.Tinv);
trs_test_imag=imresize(imwarp(org_test_imag,myaffine2d),0.01);
max_dim=max(max(size(org_test_imag)),max(size(trs_test_imag)));
im2show=zeros(max_dim,max_dim,3);
im2show(1:size(org_test_imag,1),1:size(org_test_imag,2),1)=org_test_imag;
im2show(1:size(trs_test_imag,1),1:size(trs_test_imag,2),3)=trs_test_imag;
%figure;imshow(im2show);
hh_r=handles.prv_reg_tfrom_axes; axes(hh_r);hhh_r=imshow(im2show);


% --- Executes on button press in get_background_btn.
function get_background_btn_Callback(hObject, eventdata, handles)
% hObject    handle to get_background_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
duration_of_averaging=str2double(get(handles.aver_dur_str,'String'));
fileID = fopen('DatasetAnnotation','a');fprintf(fileID,'%s',...
           ['GettinBackgroundStarted' 'Time:' datestr(datetime('now')) '\n']);fclose(fileID);
     
[Background]=get_background_data(duration_of_averaging);
fileID = fopen('DatasetAnnotation','a');fprintf(fileID,'%s',...
           ['GettinBackgroundFinished' 'Time:' datestr(datetime('now')) '\n']);fclose(fileID);
     
hh_r=handles.backgroun_n_roi_preview; axes(hh_r);hhh_r=imagesc(Background);axis image;axis off;
imwrite(Background,'BackgroundImage.tiff');
handles.background=Background;
display([num2str(handles.MessNumber) ':Background Image saved']); handles.MessNumber=handles.MessNumber+1;
guidata(hObject, handles);


% --- Executes on button press in select_roi_btn.
function select_roi_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_roi_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%based on michele's code
% BKGR_o = uint8(handles.background);
% figure
% imagesc(BKGR_o); colormap gray


    [~,IM]=read_most_recent_fluoroANDreflection();%M
    size_R=size(IM);%M
     figure; imagesc(IM);


title('Select X points on the edge of the arena')
%  [x,y] = ginput(3);
%  [arena_c, arena_r] = calc_circle([x(1) y(1)], [x(2) y(2)], [x(3) y(3)]);
%  %rectangle('Position', [arena_c(1)-arena_r,arena_c(2)-arena_r,2*arena_r,2*arena_r],'Curvature', [1,1], 'EdgeColor', 'r')
%  [x,y]=meshgrid(-(arena_c(1)-1):(size(BKGR_o,2)-arena_c(1)),-(arena_c(2)-1):(size(BKGR_o,1)-arena_c(2)));
% MASK_1=uint8(((x.^2+y.^2)<=arena_r^2));

MASK_o = roipoly;
MASK_o=uint8(MASK_o);

imagesc(double(MASK_o).*double(IM));

% im2show=zeros(size(BKGR_o,1),size(BKGR_o,2),3);
% im2show(:,:,1)=MASK_o.*imadjust(BKGR_o,stretchlim(BKGR_o,[0.25 0.97])).*256;
% im2show(:,:,2)=imadjust(BKGR_o,stretchlim(BKGR_o,[0.02 0.98])).*256;
hh_r=handles.backgroun_n_roi_preview; axes(hh_r);hhh_r=imagesc(im2show);axis image;axis off;
display([num2str(handles.MessNumber) ':ROI selection finished']); handles.MessNumber=handles.MessNumber+1;
handles.roi=MASK_o;
imwrite(MASK_o,'CurrentROI.jpg');
time_stmp=datestr(datetime('now'),'yymmddHHMMSSFFF');
imwrite(MASK_o,['ROI_' time_stmp '.jpg']);
guidata(hObject, handles);

% --- Executes on button press in Tracking_Preview_tbtn.
function Tracking_Preview_tbtn_Callback(hObject, eventdata, handles)
% hObject    handle to Tracking_Preview_tbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

devices = daq.getDevices;galvo_handle = daq.createSession('ni');
addAnalogOutputChannel(galvo_handle,'Dev1',0,'Voltage');
addAnalogOutputChannel(galvo_handle,'Dev1',2,'Voltage');
galvo_handle.Rate = 8000;
reb_fact=1;
display('TrackingPrevie')

    [~,IM]=read_most_recent_fluoroANDreflection();%M
    size_R=size(IM);%M
%[Mask_logic]=F_IM2ArenaMask_112(IM,0,'ell_sep');
%handles.Mask=Mask_logic;

% Hint: get(hObject,'Value') returns toggle state of Tracking_Preview_tbtn
k=0;COORD=[];
Xg=0;Yg=0;
while get(hObject,'Value')==1
    htime=tic;
    k=k+1;
    [~,IM1]=read_most_recent_fluoroANDreflection();%M
    pause(0.05);
    [~,IM2]=read_most_recent_fluoroANDreflection();%M
 
     if ~(size(IM1)==size(IM2));
       continue;
     end
    
    
    size_R=size(IM);%M
   % function_str=get(handles.used_algorithm_str,'String');
   
    %try
   % Coord=feval(function_str,256-IM,256-BKGR,MASK,reb_fact,myfilter);
   % [Coord,IM_mask] = F_IM2COORD_200(IM,0,Mask_logic,1);
   [Coord_diff,Coord_f,Coord_i,Imdif] = F_IMdif2Coord_102(IM1, IM2, 0,...
       round(handles.sld_blr.Value), round(handles.sld_nsig.Value), round(handles.sld_minsize.Value), 'trasmit');
   %  [Coord_diff,Coord_f,Coord_i,IMdif] = F_IMdif2Coord_102(IM, IM_o, 0,blur_fact,nsig_bin ,npxl_min,'trasmit')

   %[Coord_diff,Coord_f,Coord_i,Imdif] = F_IMdif2Coord_102(IM1, IM2,0);
   Coord=Coord_f;
  
    %catch
    %end
    %Coord = F_IM2COORD_113(IM,BKGR,MASK,reb_fact,myfilter);%M

     

    COORD=[COORD;Coord];  %M
    
    xA=Coord(2);
    yA=Coord(1);

      [Xt, Yt]= tformfwd(handles.ref2galvo_tmat, yA, xA); %%

        if (abs(Xt-Xg)>0.05 || abs(Yt-Yg)>0.05) & ~(Coord==[0,0]) %If tracked (XY) away from galvo move galvos to new position
          display('GalvoMove')
            Xg=Xt; Yg=Yt;
            if Yg>10; Yg=10; end
            if Xg>10; xg=10; end
            if Xg<-10; Xg=-10; end
            if Yg<-10; Yg=-10; end
            outputSingleScan(galvo_handle,[Xg Yg]);
        end
    %display(num2str([Xg Yg Xt Yt xA yA]));
    
    hh_r=handles.tracking_preview_axis;
    axes(hh_r);
    title('Fish head position') 
    
    hold off

    imagesc(Imdif,[-10 10]); colormap('spring');axis image;axis off;

  
  %  
  %rectangle('Position', [arena_c(1)-arena_r,arena_c(2)-arena_r,2*arena_r,2*arena_r],'Curvature', [1,1], 'EdgeColor', 'r')
    hold on
    plot(yA,xA,'-*k')
   % xlim([0 size_R(2)]); ylim([0 size_R(1)]);
    %display(k)
    drawnow;
            set(handles.time4tracking_str,'String',[toc(htime)./1000 'ms'])
 
            
              fileID = fopen('GalvoXYpos','a');fprintf(fileID,'%s',...
           ['Xt:' num2str(Xt,4) 'Y:' num2str(Yt,4) ...
            'Xg:' num2str(Xg,4) 'Yg:' num2str(Yg,4)  'Time:' datestr(datetime('now')) '\n']);fclose(fileID);
       
            
end
clear galvo_handle

% --- Executes on button press in save_tracking_params4worker_btn.
function save_tracking_params4worker_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_tracking_params4worker_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
par4tracking.background=handles.background;
par4tracking.roi=handles.roi;
par4tracking.used_algorithm_str=handles.used_algorithm_str;
par4tracking.ref2galvo_tmat=handles.ref2galvo_tmat;
save('Tracking_Params.mat','par4tracking');
display([num2str(handles.MessNumber) ':ParamsSaved. Ready for auto-tracking']); handles.MessNumber=handles.MessNumber+1;

% --- Executes on button press in start_rec_tbtn.
function start_rec_tbtn_Callback(hObject, eventdata, handles)
% hObject    handle to start_rec_tbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(1),'uint8');fclose(fileID);
display([num2str(handles.MessNumber) ':REC started']); handles.MessNumber=handles.MessNumber+1;

% --- Executes on button press in stop_rec_btn.
function stop_rec_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_rec_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(0),'uint8');fclose(fileID);
set(handles.start_rec_tbtn,'Value',0);
display([num2str(handles.MessNumber) ':REC stoped']); handles.MessNumber=handles.MessNumber+1;
guidata(hObject, handles);


% --- Executes on button press in update_dataset_annotation_btn.
function update_dataset_annotation_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_dataset_annotation_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileID = fopen('DatasetAnnotation','a');fprintf(fileID,'%s',...
           [char(get(handles.next_annotation_str,'String')) 'Time:' datestr(datetime('now')) '\n']);fclose(fileID);
     
       
       
% --- Executes on button press in start_autotracking_tbtn.
function start_autotracking_tbtn_Callback(hObject, eventdata, handles)
% hObject    handle to start_autotracking_tbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.j4=batch(parcluster('local4'),'Scrip2Worker_GALVOS_debugi');
display([num2str(handles.MessNumber) ':AutTracking started']); handles.MessNumber=handles.MessNumber+1;
guidata(hObject, handles);


% --- Executes on button press in stop_auto_tracking_btn.
function stop_auto_tracking_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_auto_tracking_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stop_auto_tracking_btn
cancel(handles.j4);
display([num2str(handles.MessNumber) ':AutTracking Stopped']); handles.MessNumber=handles.MessNumber+1;
set(handles.start_autotracking_tbtn,'Value',0);
guidata(hObject, handles);




% --- Executes on button press in start_joy_controll_tbtn.
function start_joy_controll_tbtn_Callback(hObject, eventdata, handles)
% hObject    handle to start_joy_controll_tbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of start_joy_controll_tbtn

devices = daq.getDevices
s = daq.createSession('ni')
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000

%% Also joystic
joy = vrjoystick(1)
figure;
while get(hObject,'Value')==1;  
[axes, buttons, povs] = read(joy);
if buttons(1)==1
xValue = +axes(2)*10;
yValues = -axes(1)*10;
% if xValue>10; xValue=10;end
% if xValue<-10;xValue=-10;end
% if yValues>10;yValues=10;end
% if yValues<-10;yValues=-10;end
outputSingleScan(s,[xValue yValues]);
plot(xValue,yValues,'or','MarkerSize',10);xlim([-10 10]);ylim([-10 10]);drawnow;
end
end



%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

%% DO NOT TOUCH BELLOW THIS POINT.
%%
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
function exp_description_str_Callback(hObject, eventdata, handles)
% hObject    handle to exp_description_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exp_description_str as text
%        str2double(get(hObject,'String')) returns contents of exp_description_str as a double


% --- Executes during object creation, after setting all properties.
function exp_description_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_description_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f_gain_listbox.
function f_gain_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to f_gain_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f_gain_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f_gain_listbox


% --- Executes during object creation, after setting all properties.
function f_gain_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_gain_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f_exptime_str_Callback(hObject, eventdata, handles)
% hObject    handle to f_exptime_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f_exptime_str as text
%        str2double(get(hObject,'String')) returns contents of f_exptime_str as a double


% --- Executes during object creation, after setting all properties.
function f_exptime_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_exptime_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f_bin_listbox.
function f_bin_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to f_bin_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f_bin_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f_bin_listbox


% --- Executes during object creation, after setting all properties.
function f_bin_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f_bin_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function ref_exp_str_Callback(hObject, eventdata, handles)
% hObject    handle to ref_exp_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_exp_str as text
%        str2double(get(hObject,'String')) returns contents of ref_exp_str as a double


% --- Executes during object creation, after setting all properties.
function ref_exp_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_exp_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref_bin_str_Callback(hObject, eventdata, handles)
% hObject    handle to ref_bin_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_bin_str as text
%        str2double(get(hObject,'String')) returns contents of ref_bin_str as a double


% --- Executes during object creation, after setting all properties.
function ref_bin_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_bin_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref_gain_str_Callback(hObject, eventdata, handles)
% hObject    handle to ref_gain_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ref_gain_str as text
%        str2double(get(hObject,'String')) returns contents of ref_gain_str as a double


% --- Executes during object creation, after setting all properties.
function ref_gain_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_gain_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flr_gain_str_Callback(hObject, eventdata, handles)
% hObject    handle to flr_gain_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flr_gain_str as text
%        str2double(get(hObject,'String')) returns contents of flr_gain_str as a double


% --- Executes during object creation, after setting all properties.
function flr_gain_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flr_gain_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flr_bin_str_Callback(hObject, eventdata, handles)
% hObject    handle to flr_bin_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flr_bin_str as text
%        str2double(get(hObject,'String')) returns contents of flr_bin_str as a double


% --- Executes during object creation, after setting all properties.
function flr_bin_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flr_bin_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flr_exp_str_Callback(hObject, eventdata, handles)
% hObject    handle to flr_exp_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flr_exp_str as text
%        str2double(get(hObject,'String')) returns contents of flr_exp_str as a double


% --- Executes during object creation, after setting all properties.
function flr_exp_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flr_exp_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tform2load_str_Callback(hObject, eventdata, handles)
% hObject    handle to tform2load_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tform2load_str as text
%        str2double(get(hObject,'String')) returns contents of tform2load_str as a double


% --- Executes during object creation, after setting all properties.
function tform2load_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tform2load_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on slider movement.
function sld_blr_Callback(hObject, eventdata, handles)
% hObject    handle to sld_blr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sld_blr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_blr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

function next_annotation_str_Callback(hObject, eventdata, handles)
% hObject    handle to next_annotation_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of next_annotation_str as text
%        str2double(get(hObject,'String')) returns contents of next_annotation_str as a double

% --- Executes during object creation, after setting all properties.
function next_annotation_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to next_annotation_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sld_nsig_Callback(hObject, eventdata, handles)
% hObject    handle to sld_nsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sld_nsig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_nsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function used_algorithm_str_Callback(hObject, eventdata, handles)
% hObject    handle to used_algorithm_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of used_algorithm_str as text
%        str2double(get(hObject,'String')) returns contents of used_algorithm_str as a double


% --- Executes during object creation, after setting all properties.
function used_algorithm_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to used_algorithm_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes when uipanel3 is resized.
function uipanel3_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_reg_str.
function save_reg_str_Callback(hObject, eventdata, handles)
% hObject    handle to save_reg_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function aver_dur_str_Callback(hObject, eventdata, handles)
% hObject    handle to aver_dur_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aver_dur_str as text
%        str2double(get(hObject,'String')) returns contents of aver_dur_str as a double


% --- Executes during object creation, after setting all properties.
function aver_dur_str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aver_dur_str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on slider movement.
function sld_minsize_Callback(hObject, eventdata, handles)
% hObject    handle to sld_minsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sld_minsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_minsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
