%%

disp('Andor SDK3 Kinetic Series Example');
[rc] = AT_InitialiseLibrary();AT_CheckError(rc);
[rc,hndl] = AT_Open(0);AT_CheckError(rc);
disp('Camera initialized');

[rc]=AT_SetBool(hndl,'SensorCooling', 1); AT_CheckWarning(rc);% Enable cooling


[rc] = AT_SetFloat(hndl,'ExposureTime',0.2);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'CycleMode','Continuous');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'TriggerMode','Software');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'AOIBinning','2x2');AT_CheckWarning(rc);

[rc,imagesize] = AT_GetInt(hndl,'ImageSizeBytes');AT_CheckWarning(rc);
[rc,height] = AT_GetInt(hndl,'AOIHeight');AT_CheckWarning(rc);
[rc,width] = AT_GetInt(hndl,'AOIWidth');AT_CheckWarning(rc);
[rc,stride] = AT_GetInt(hndl,'AOIStride'); AT_CheckWarning(rc);
[rc] = AT_Command(hndl,'AcquisitionStart');AT_CheckWarning(rc);

t=fix(clock); 
namefold_YYYYMMDD=[num2str(t(1),'%04i'), num2str(t(2),'%02i'), num2str(t(3),'%02i')];
namefold_HHMM=[num2str(t(4),'%02i'), num2str(t(5),'%02i')];
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path=(['I:\Raster_Scanning_Fine_q_' namefold_HHMM ])
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(path);
cd(path);

fileID = fopen('Most_Recent_FluoroImag','w');fclose(fileID);
t=0;
buf2 = zeros(width,height);


%% Define Devices.
devices = daq.getDevices
s = daq.createSession('ni')
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000

%% SimpleExample
xValue=0;
yValue=0;



for ix=-9:1:9
    ix
for iy=-9:1:9
    outputSingleScan(s,[ix iy]);

        t=t+1;
    [rc] = AT_QueueBuffer(hndl,imagesize);
    [rc] = AT_Command(hndl,'SoftwareTrigger');
    [rc,buf] = AT_WaitBuffer(hndl,5000);
    [rc,buf2] = AT_ConvertMono16ToMatrix(buf,height,width,stride);
    buf2=imcrop(buf2,[640-250,540-250,499,499]);
    %imagesc(log10(double((buf2))),[2.5 3]);colorbar; title(num2str(max(buf2(:) ))); drawnow; 
    imwrite(((uint16(buf2))), ['F_x_' num2str(-ix,'%02d') '_y_' num2str(-iy,'%02d') '.tiff'] );
%     
%    fileID = fopen('Recording_ON_OFF_variable','r');REC_var=fread(fileID,1,'uint8');fclose(fileID);
%    
%    if REC_var==0;
%    imageID = fopen(['F_x' num2str(ix) '_y_' num2str(iy)],'w+');
%    elseif REC_var==1;
%        imageID = fopen(['F_r_' num2str(t,'%09d')],'w+');
%    end
%    fwrite((imageID),fliplr(uint16(buf2)),'uint16');fclose(imageID);
%    
%    if t==1;
%        fileID = fopen('Size_FluoroImag','w');fwrite(fileID,uint16(size(buf2)),'uint16');fclose(fileID);
%    end
%     
% fileID = fopen('Most_Recent_FluoroImag','w'); fwrite(fileID,uint32(t),'uint32'); fclose(fileID);
%     
%     
end
end
display('ready')
    outputSingleScan(s,[0 0]);

disp('Acquisition complete');
[rc] = AT_Command(hndl,'AcquisitionStop');
AT_CheckWarning(rc);
[rc] = AT_Flush(hndl);
AT_CheckWarning(rc);
[rc] = AT_Close(hndl);
AT_CheckWarning(rc);
[rc] = AT_FinaliseLibrary();
AT_CheckWarning(rc);
disp('Camera shutdown');

%%imaqhwinfo;
vid = videoinput('gentl', 1, 'Mono8'); %select input device
%hvpc = vision.VideoPlayer;   %create video player object

src = getselectedsource(vid);
vid.FramesPerTrigger =1;
vid.TriggerRepeat = Inf;
src.ExposureTime=10000;
start(vid);

%start main loop for image acquisition
cd(path);
t=0;
while t<1;
    t=t+1;
    
  R=getdata(vid,1,'uint8');    %get image from camera
 % hvpc.step(imgO);    %see current image in player
 % 
  
  
            
 imwrite(R,['R_' num2str(t) '.tiff']);  
%fileID = fopen('Most_Recent_FluoroImag','w'); fwrite(fileID,t); fclose(fileID); 

end
stop(vid);