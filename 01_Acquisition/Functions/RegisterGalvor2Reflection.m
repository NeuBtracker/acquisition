%function tform=RegisterGalvor2Reflection
%% XY-callibration function
cd('I:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
cd(path);

%% Initialize galvos
devices = daq.getDevices;s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000;

%% Define fixed points
 figure;
 [F,R]=read_most_recent_fluoroANDreflection();
 
 subplot(1,3,1);imagesc(R);title('Reference Reflection Image'); axis image;     
[x_fp, y_fp] = getpts; hold on;
viscircles([x_fp y_fp],5*(1:length(x_fp)).*ones(1,length(x_fp)));

k=[];
set(gcf,'keypress','k=get(gcf,''currentchar'');');
% 28 => leftArrow 29 => rightArrow 30 => upArrow 31 => downArrow
% 'uparrow','downarrow','leftarrow','riAghtarrow'.
pixel_index=0; xValue=0; yValue=0;
while pixel_index<length(x_fp);
    wd=150;
    subplot(1,3,2);imagesc(imadjust(imcrop(R,...
                            [(x_fp(pixel_index+1)-floor(wd/2)),...
                            (y_fp(pixel_index+1)-floor(wd/2)), wd, wd])));
                        viscircles([floor(wd/2) floor(wd/2)],10);axis image; 
                            title(['Region Around point' num2str(pixel_index+1)]);      
  
   [F,R2]=read_most_recent_fluoroANDreflection();
   subplot(1,3,3);imagesc(imadjust(F));axis image;
   viscircles([floor(size(F,1)/2) floor(size(F,2)/2)],20);
   step=0.1;
   title(['X:' num2str(xValue) ' Y:' num2str(yValue) ' Step:' num2str(step)]);drawnow;
   outputSingleScan(s,[xValue yValue])

   if ~isempty(k)
        if strcmp(k,'d'); yValue = yValue + step;  k=[]; 
        elseif strcmp(k,'a'); yValue = yValue - step;     k=[]; 
        elseif strcmp(k,'w'); xValue = xValue + step;     k=[];
        elseif strcmp(k,'s'); xValue = xValue - step;    k=[]; 
        elseif strcmp(k,'p')
                pixel_index=pixel_index+1;
                CorrenspondingPos(pixel_index,:)=[xValue  yValue];
                 k=[]; 
        end
        xValue=min(xValue,10);xValue=max(xValue,-10);
        yValue=min(yValue,10);yValue=max(yValue,-10);
    end
       
end

xValue=0;
yValue=0;
outputSingleScan(s,[xValue yValue]);

mytform=cp2tform([x_fp y_fp],CorrenspondingPos,'affine');

save('tranforming_RefXY_GalvoXY.mat','mytform');
%save(['D:\ZT_Matlab\tranforming_RefXY_GalvoXY_for' path(2:end) '.mat'],'mytform');
%save('D:\ZT_Matlab\default_tform.mat','tform');



