%%

disp('Andor SDK3 Kinetic Series Example');
[rc] = AT_InitialiseLibrary();AT_CheckError(rc);
[rc,hndl] = AT_Open(0);AT_CheckError(rc);
disp('Camera initialized');

[rc]=AT_SetBool(hndl,'SensorCooling', 1); AT_CheckWarning(rc);% Enable cooling


[rc] = AT_SetFloat(hndl,'ExposureTime',0.25);AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'CycleMode','Continuous');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'TriggerMode','Software');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');AT_CheckWarning(rc);
[rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');AT_CheckWarning(rc);
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
path=(['I:\USAF_3D_' namefold_HHMM ])
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

%% Initialize ETL COM port and Focal Power Mode;
addpath(genpath('D:\ZT_Matlab'));
tp=num2str(fix(clock));
err=writeValue4ETL(0);    
[~,cmdout] = dos([...
            'python D:\ZT_Matlab\IndivParts\ETL_pythonP\ETL_looped_reading_file.py ' num2str(0) '&']  )
       

%% SimpleExample
xValue=0;
yValue=0;

% clear z_positions;
 kk=0;
for i=[-25:5:-15 -14:2:-6 -5:0.5:+5 6:2:14 15:5:+25]
    %i=-3:0.5:3
    kk=kk+1
   % z_positions(kk)=real(((0+(i).^1)).^1.2)
    z_positions(kk)=i
    if z_positions(kk)>200; z_positions(kk)=200; end
   if   z_positions(kk)<-200; z_positions(kk)=-200; end
end
plot(z_positions,'o');
%  clear z_positions
%  z_positions=0;
retake=1;
while retake==1;
  retake=0;

   for i_z=1:length(z_positions);
    %outputSingleScan(s,[0 0]);
    subpath_z=['Zpos_' num2str(z_positions(i_z)) ];
    cd(path)
    save('z_positions.mat','z_positions');
   mkdir(subpath_z);
   cd(subpath_z);

  [s_er]=writeValue4ETL( z_positions(i_z)); 
i_z
Stiched_T=[];
kkkk=0; 

        for ix=-4:1:3.5
      % for ix=-10:0.5:10
     % ix
            Stiched_y=[];
           for iy=-3:1:3.5
       %  for iy=-10:0.5:10
                outputSingleScan(s,[ix iy]);
                
                t=t+1;
                [rc] = AT_QueueBuffer(hndl,imagesize);
                [rc] = AT_Command(hndl,'SoftwareTrigger');
                [rc,buf] = AT_WaitBuffer(hndl,300);
                [rc,buf2] = AT_ConvertMono16ToMatrix(buf,height,width,stride);
               %  buf2=imcrop(fliplr(imrotate(uint16(buf2),180)),[640-250,540-250,499,499]);
              %buf2=(buf2(400:end-401,200:end-201));
               buf2=(fliplr(buf2));
               buf2=buf2(30:end-30,30:end-30);
             % buf2=((imrotate(uint16(buf2),-90)));                
                %imagesc(buf2);colorbar; title(num2str(max(buf2(:) ))); drawnow;
               % imwrite(((uint16(buf2))), ['F_x_' num2str(10.*(11+1.*ix),'%02d') '_y_' num2str(10.*(11+(-1.*iy)),'%02d') '.tiff'] );
               kk=kk+1;                
               imwrite(imresize(uint16(buf2),1), ['F_kk_' num2str(kk,'%05d') '.tiff'] );

                Stiched_y=cat(2,Stiched_y,imresize(buf2,0.01)) ;
                
                LOC(kk,:)=[ix iy i_z];
               % scatter3(ix,iy,i_z,'MarkerFaceColor',abs([ix/10 iy/10 i_z/10]));drawnow;hold on;
            end
            Stiched_T=cat(1,Stiched_T,Stiched_y);
              save('LOC.mat','LOC');
        end
        cd(path);
        imwrite(uint16(imresize(Stiched_T,0.5)),['M_F_' num2str(i_z,'%03d') '.tiff' ]);
      
        copyfile('D:\ZT_Matlab\Callibratoin_Charactirazation_2be_Doc\Fast_1plane_RasterScanning.m','Fast_1plane_RasterScanning.m')
        figure;imagesc(Stiched_T);
        
        
    end
    outputSingleScan(s,[0 0]);
    [s_er]=writeValue4ETL( 0); 
 retake = input('Take more photos?[1=yes]');   
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
Exposures=[1000 50000 1000000]
for iexp=1:length(Exposures)
src.ExposureTime=Exposures(iexp);
start(vid);

%start main loop for image acquisition
cd(path);
t=0;
while t<1;
    t=t+1;
    
    R=getdata(vid,1,'uint8');    %get image from camera
    % hvpc.step(imgO);    %see current image in player
    %
    
    
    
    imwrite(R,['R_' num2str(t) '_exp' num2str(src.ExposureTime./1000) '.tiff']);
    %fileID = fopen('Most_Recent_FluoroImag','w'); fwrite(fileID,t); fclose(fileID);
    
end
stop(vid);
end