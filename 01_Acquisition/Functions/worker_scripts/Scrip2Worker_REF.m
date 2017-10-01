%% Access saving directory and load_camera_parameters
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
cd(path);
load('Next_Ref_Camera_Params');

imaqhwinfo;
vid = videoinput('gentl', 1, 'Mono8'); %select input device
%hvpc = vision.VideoPlayer;   %create video player object

% RcP.FramesPerTrigger=1;
% RcP.TrigerRepeat= Inf;
% RcP.ExposureTime=200*1000;
% RcP.Gain=5;
% RcP.BadPixelCorrection='True';
% RcP.BinningHorizontal=4;
% RcP.BinningVertical=4;
% % save('D:\ZT_Matlab\Default_REF_camera_Params','RcP');

src = getselectedsource(vid);
vid.FramesPerTrigger =RcP.FramesPerTrigger;
vid.TriggerRepeat = RcP.TrigerRepeat;
src.ExposureTime=RcP.ExposureTime; %In microseconds
src.Gain = RcP.Gain;
src.BadpixelCorrection = RcP.BadPixelCorrection;
src.BinningHorizontal = RcP.BinningHorizontal;
src.BinningVertical = RcP.BinningHorizontal; %%allow only symmetrical binning
start(vid);

%start main loop for image acquisition

fileID = fopen('Most_Recent_RefImag','w');fclose(fileID);
t=0;

while 1==1;
%while t<1000    
    t=t+1;
  imgO=getdata(vid,1,'uint8');    %get image from camera
  img1=imgO;%(50:end-50,50:end-70);
 % hvpc.step(imgO);    %see current image in player
 % imwrite(imgO,['R_' num2str(t) '.tiff']);  
  %5imagesc(imgO); drawnow
      time_stmp=datestr(datetime('now'),'yymmddHHMMSSFFF');

  fileID = fopen('Recording_ON_OFF_variable','r');REC_var=fread(fileID,1,'uint8');fclose(fileID);
  if REC_var==0;
   imageID = fopen(['R_' time_stmp],'w+');
  elseif REC_var==1;
   imageID = fopen(['R_r_' time_stmp],'w+');   
  end
  fwrite(imageID,(uint8(img1)),'uint8');fclose(imageID);
  
  if t==1
       fileID = fopen('Size_RefImag','w');fwrite(fileID,uint16(size(img1)),'uint16');fclose(fileID);
  end
  fileID = fopen('Most_Recent_RefImag','w'); fwrite(fileID,uint32(time_stmp),'uint32'); fclose(fileID); 
  %fileID = fopen('Most_Recent_RefImag','w'); fwrite(fileID,(str2num(time_stmp)),'double'); fclose(fileID); 

  
end
