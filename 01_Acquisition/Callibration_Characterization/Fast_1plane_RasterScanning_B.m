%%

disp('Andor SDK3 Kinetic Series Example');
[rc] = AT_InitialiseLibrary();AT_CheckError(rc);
[rc,hndl] = AT_Open(0);AT_CheckError(rc);
disp('Camera initialized');

[rc]=AT_SetBool(hndl,'SensorCooling', 1); AT_CheckWarning(rc);% Enable cooling

[rc]=AT_SetBool(hndl,'SensorCooling', 1); AT_CheckWarning(rc);% Enable cooling
[rc] = AT_SetFloat(hndl,'ExposureTime',0.02);AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'CycleMode',FcP.CycleMode);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'CycleMode','Continuous');AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'TriggerMode',FcP.TriggerMode);AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'TriggerMode','Software');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'TriggerMode','Internal');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelReadoutRate','280 MHz');AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'StaticBlemishCorrection',1);AT_CheckWarning(rc);
[rc] = AT_SetBool(hndl,'SpuriousNoiseFilter',1);AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl',FcP.SimplePreAmpGainControl);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','12-bit (low noise)');AT_CheckWarning(rc);
%[rc] = AT_SetEnumString(hndl,'PixelEncoding',FcP.PixelEncoding);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'AOIBinning','4x4');AT_CheckWarning(rc);
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
path=(['I:\XXX_X1' namefold_HHMM ])
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


            outputSingleScan(s,[0 0]);
%% SimpleExample
xValue=0;
yValue=0;

z_positions=20%10:20:190;
retake=1;
while retake==1;
    Stiched_T=[];
     figure;
    for i_z=1
       kkkk=0;
        for ix=7:-0.5:-7
            ix
            kkkk./(length((8:-0.2:-8))).^2
            Stiched_y=[];
             for iy=7:-0.5:-7
                kkkk=kkkk+1;
                outputSingleScan(s,[-ix -iy]);
                
                t=t+1;
                [rc] = AT_QueueBuffer(hndl,imagesize);
                [rc] = AT_Command(hndl,'SoftwareTrigger');
                [rc,buf] = AT_WaitBuffer(hndl,300);
                [rc,buf2] = AT_ConvertMono16ToMatrix(buf,height,width,stride);
                % buf2=imcrop(fliplr(imrotate(uint16(buf2),180)),[640-250,540-250,499,499]);
               % buf2=((imrotate(uint16(buf2),180)));    
                
              %  buf3=buf2(size(buf2,1)./2-150:size(buf2,1)./2+150,size(buf2,2)./2-150:size(buf2,2)./2+150);
                
                imagesc(buf2);colorbar; title(num2str(max(buf2(:) ))); drawnow;
                
             %  imwrite(((uint16(buf3))), ['F_x_' num2str(-ix*10,'%04d') '_y_' num2str(iy*10,'%04d') '.tiff'] );
               %imwrite(((uint16(buf2))), ['B_' num2str(kkkk,'%04i') '.tiff'] );
              F(:,:,kkkk)=buf2;
              X(:,:,kkkk)=ix;
              Y(:,:,kkkk)=iy;
              TST(:,:,kkkk)=now;
              %  Stiched_y=cat(2,Stiched_y,buf3) ;
               % scatter3(ix,iy,i_z,'MarkerFaceColor',abs([ix/10 iy/10 i_z/10]));drawnow;hold on;
            end
            %Stiched_T=cat(1,Stiched_T,Stiched_y);
        end
        cd(path);
      %  imwrite(uint16(Stiched_T),['M_F_' num2str(i_z,'%03d') '.tiff' ]);
        %figure;imagesc(Stiched_T);
        
    end
    outputSingleScan(s,[0 0]);
 pause;% input('Take more photos?[1=yes]');   
end

%%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%


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
src.ExposureTime=1000000;0
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