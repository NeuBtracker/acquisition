%% %autofocus.

%% Initialize COM port and Focal Power Mode;
s = serial('COM32');
set(s,'BaudRate',3840);
set(s,'Databits',8);
set(s,'Stopbits',1);
set(s,'Parity','none');

fopen(s);
fprintf(s,'Start') %Handshake
out = fscanf(s)
pause(0.5);



%%
addpath(genpath('D:\ZT_Matlab'));
cd('I:\');
path=create_saving_directory
%fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
cd(path);
load('Next_Fluoro_Camera_Params');
disp('Andor SDK3 Kinetic Series Example');
[rc] = AT_InitialiseLibrary();AT_CheckError(rc);
[rc,hndl] = AT_Open(0);AT_CheckError(rc);
disp('Camera initialized');
[rc]=AT_SetBool(hndl,'SensorCooling', FcP.Cooling); AT_CheckWarning(rc);% Enable cooling
[rc] = AT_SetFloat(hndl,'ExposureTime',FcP.ExposureTime);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'CycleMode',FcP.CycleMode);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'TriggerMode',FcP.TriggerMode);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelReadoutRate','100 MHz');AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'StaticBlemishCorrection',1);AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'SpuriousNoiseFilter',1);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl',FcP.SimplePreAmpGainControl);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelEncoding',FcP.PixelEncoding);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'AOIBinning',FcP.AOIBinning);AT_CheckWarning(rc);
[rc,imagesize] = AT_GetInt(hndl,'ImageSizeBytes');AT_CheckWarning(rc);
[rc,height] = AT_GetInt(hndl,'AOIHeight');AT_CheckWarning(rc);
[rc,width] = AT_GetInt(hndl,'AOIWidth');AT_CheckWarning(rc);
[rc,stride] = AT_GetInt(hndl,'AOIStride'); AT_CheckWarning(rc);
[rc] = AT_Command(hndl,'AcquisitionStart');AT_CheckWarning(rc);



%% main loop

t=0;
buf2 = zeros(width,height,'uint16');

k1=0;
set_ETL_current(s, 0);
previews_current=0;
direction=1
while 1==1;
    k1=k1+1;
%while t<500  

    t=t+1
    [rc] = AT_QueueBuffer(hndl,imagesize);
    [rc] = AT_Command(hndl,'SoftwareTrigger');
    [rc,buf] = AT_WaitBuffer(hndl,1000);
    [rc,buf2] = AT_ConvertMono12ToMatrix(buf,height,width,stride);
    time_stmp=datestr(datetime('now'),'yymmddHHMMSSFFF');
  %  imagesc((((buf2))));colorbar; title(num2str(max(buf2(:) ))); drawnow; 
  %  imwrite(fliplr((uint16(buf2))), ['F_' num2str(t) '.tiff'] );
  
  if k1>1
      
    DH1 = buf2;
    DV1 = buf2;
    
       
    DH=DH1(1:end-3,1:end-3)-DH1(4:end,1:end-3);
    DV=DV1(1:end-3,1:end-3)-DV1(1:end-3,4:end);
    FM=max(DH,DV);
    focusMeasure = mean(mean((FM)))
    ALL_F_M(k1)=focusMeasure;
     
  
%       if new_current==-250
%           direction=1;
%       elseif new_current==250
%           direction=-1;
%       end
       if focusMeasure>=pr_focs
           direction=1;
       elseif focusMeasure<pr_focs
           direction=-1;
       end

      step=3;
  new_current=previews_current+(step*direction);
  set_ETL_current(s, new_current)
  previews_current=new_current;
  
  All_ETL(k1)=new_current;
    
  pr_fr=buf2;
  pr_focs=(focusMeasure+pr_focs)./2;
  subplot(4,2,1:4);imagesc(buf2);axis image; axis off;
  subplot(4,2,5:6);plot(k1,ALL_F_M(k1),'or');hold on; 
  subplot(4,2,7:8);plot(k1,All_ETL(k1),'og');hold on;
  drawnow;
  end
  

end
  






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



