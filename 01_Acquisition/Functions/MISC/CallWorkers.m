%% LOAD_FUNCTIONS: Makes the folder with all paths is accessible
addpath(genpath('D:\ZT_Matlab'));

%% FOLDER_GENERATION: Makes the folder were images will be saved (and Global Variable to guide
%subfunction there
path_name=['TestFriday_Spheres2' datestr(datetime('now'),30)]; % ________CHANGE THIS LINE___________
cd('I:\');
fileID = fopen('Path2SaveNextExperiment','w');fprintf(fileID,'%s',path_name);fclose(fileID);
mkdir(path_name); cd(path_name);
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(0),'uint8');fclose(fileID);

%% START_IM_AQ:Iniatilize Parallel Scripts (works asycrhonsly in parallel)
j1=batch(parcluster('local1'),'Scrip2Worker_FLUOR');
j2=batch(parcluster('local2'),'Scrip2Worker_REF');
j3=batch(parcluster('local3'),'Scrip2Worker_DeleteOldFiles');

%% FOCUSING: Load Preview window for focusing - give it some time to initialize
Preview_most_recent_images(500,50) %___(X,Y) are upper limits of images

%% GALVO_REGISTRATION:Estimate/load transormation that registers 
%xy-galvo position to reflection image
%(a) Select with mouse 3 points
%(b) Use "wasd" keys (up,left,down,right) for navigation
%       and "p" for the selection of points 

RegisterGalvor2Reflection;
%%%
%%OR 
%load('tranforming_RefXY_GalvoXY_forish_7arena_Fluoro_REF_MicheleProper20150823T165506');
%save('tranforming_RefXY_GalvoXY.mat','mytform');
%%%%

%load('D:\ZT_Matlab\default_tform.mat');

%% Record Background image for Tracking
%(either without fish or with fish swimming around)
duration_of_averaging=25; %sec 
[Background]=get_background_data(duration_of_averaging);
imwrite(Background,'BackgroundImage.tiff');
% or load existing background
%[FileName,PathName] = uigetfile('*.m','Select the MATLAB code file');


%% START_TRACKING:Initiallized tracking worker (works asycrhonsly in parallel)
j4=batch(parcluster('local4'),'Scrip2Worker_GALVOS_AUTOTRACKING');


%%
%Start RECORDING
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(1),'uint8');fclose(fileID);
%Stop RECORDING
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(0),'uint8');fclose(fileID);

