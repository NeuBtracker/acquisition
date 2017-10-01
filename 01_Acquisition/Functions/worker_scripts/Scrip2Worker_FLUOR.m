addpath(genpath('D:\ZT_Matlab'));
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
cd(path);
load('Next_Fluoro_Camera_Params');


disp('Andor SDK3 Kinetic Series Example');
[rc] = AT_InitialiseLibrary();AT_CheckError(rc);
[rc,hndl] = AT_Open(0);AT_CheckError(rc);
disp('Camera initialized');

%%
[rc]=AT_SetBool(hndl,'SensorCooling', FcP.Cooling); AT_CheckWarning(rc);% Enable cooling
[rc] = AT_SetFloat(hndl,'ExposureTime',FcP.ExposureTime);AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'CycleMode',FcP.CycleMode);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'CycleMode','Continuous');AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'TriggerMode',FcP.TriggerMode);AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'TriggerMode','Software');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'TriggerMode','Internal');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelReadoutRate','280 MHz');AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'StaticBlemishCorrection',1);AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'SpuriousNoiseFilter',1);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl',FcP.SimplePreAmpGainControl);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','12-bit (low noise)');AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'PixelEncoding',FcP.PixelEncoding);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'AOIBinning',FcP.AOIBinning);AT_CheckWarning(rc);
[rc,imagesize] = AT_GetInt(hndl,'ImageSizeBytes');AT_CheckWarning(rc);
[rc,height] = AT_GetInt(hndl,'AOIHeight');AT_CheckWarning(rc);
[rc,width] = AT_GetInt(hndl,'AOIWidth');AT_CheckWarning(rc);
[rc,stride] = AT_GetInt(hndl,'AOIStride'); AT_CheckWarning(rc);
[rc] = AT_Command(hndl,'AcquisitionStart');AT_CheckWarning(rc);




%fileID = fopen('Most_Recent_FluoroImag','w');fclose(fileID);
t=0;
buf2 = zeros(width,height,'uint16');
%profile on;
%
while 1==1;
%while t<500  
%tic
    t=t+1;
    [rc] = AT_QueueBuffer(hndl,imagesize);    
    %[rc] = AT_Command(hndl,'SoftwareTrigger');
    [rc,buf] = AT_WaitBuffer(hndl,300); %FcP.ExposureTime.*1000*1.5
    [rc,buf2] = AT_ConvertMono12PackedToMatrix(buf,height,width,stride);
    time_stmp=datestr(datetime('now'),'yymmddHHMMSSFFF');
  %  imagesc((((fliplr(imrotate(uint16(buf2),180))))));colorbar; title(num2str(max(buf2(:) ))); drawnow;  axis image;    
  %  imwrite(fliplr((uint16(buf2))), ['F_' num2str(t) '.tiff'] );
    
   fileID = fopen('Recording_ON_OFF_variable','r');REC_var=fread(fileID,1,'uint8');fclose(fileID);
   
   if REC_var==0;
   imageID = fopen(['F_' time_stmp],'w+');
   elseif REC_var==1;
       imageID = fopen(['F_r_' time_stmp],'w+');
   end
   fwrite((imageID),fliplr(imrotate(uint16(buf2),180)),'uint16');fclose(imageID);
   
   if t==1;
       fileID = fopen('Size_FluoroImag','w');fwrite(fileID,uint16(size(buf2)),'uint16');fclose(fileID);
   end
    
fileID = fopen('Most_Recent_FluoroImag','w'); fwrite(fileID,uint32(time_stmp),'uint32'); fclose(fileID);
%fileID = fopen('Most_Recent_FluoroImag','w'); fwrite(fileID,(str2num(time_stmp)),'double'); fclose(fileID);

%E(t)=toc;
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