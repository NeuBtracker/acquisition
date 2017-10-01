%% Define Devices.
devices = daq.getDevices
s = daq.createSession('ni')
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000



xValue = 0;
yValues = 0;
outputSingleScan(s,[xValue yValues]);

%% ComplexExample
while 1==1
      direction=-1;  
for i=-10:2:10;
    direction=direction.*(-1)
    for j=-10:2:10;
%outputSingleScan(s,[0 0]);
pause(0.1);
xValue = i;
yValues = direction.*j;
outputSingleScan(s,[xValue yValues]);
%outputSingleScan(s,[yValues xValue]);
%plot(xValue,yValues,'or','MarkerSize',10);xlim([-10 10]);ylim([-10 10]);drawnow;
%pause(0.05);
    end
end
end

%% ComplexExample
while 1==1
      direction=-1;  
for i=-5:1:5
    direction=direction.*(-1)
    for j=-5:1:5;
%outputSingleScan(s,[0 0]);
pause(0.05);
xValue = i;
yValues = direction.*j;
outputSingleScan(s,[xValue yValues]);
%outputSingleScan(s,[yValues xValue]);
%plot(xValue,yValues,'or','MarkerSize',10);xlim([-10 10]);ylim([-10 10]);drawnow;
%pause(0.05);
    end
end
end


%% Also joystic
joy = vrjoystick(1)
while 1==1
[axes, buttons, povs] = read(joy);
xValue = -axes(1)*10;,
yValues = axes(2)*10;
%outputSingleScan(s,[xValue yValues]);
if buttons(1)==1;
   outputSingleScan(s,[xValue yValues]);
   plot(xValue,yValues,'or','MarkerSize',10);xlim([-10 10]);ylim([-10 10]);drawnow;

end
end

% %%Keyboard
% h1=figure;
% k=[];
% set(h1,'keypress','k=get(gcf,''currentchar'');');
% % 28 => leftArrow 29 => rightArrow 30 => upArrow 31 => downArrow
% % 'uparrow','downarrow','leftarrow','riAghtarrow'.
% pixel_index=0; xValue=0; yValue=0;
% while 1==1
%    if ~isempty(k)
%  figure(h1);
%         if strcmp(k,'d'); yValue = yValue + step;  k=[]; 
%         elseif strcmp(k,'a'); yValue = yValue - step;     k=[]; 
%         elseif strcmp(k,'w'); xValue = xValue + step;     k=[];
%         elseif strcmp(k,'s'); xValue = xValue - step;    k=[]; 
%         elseif strcmp(k,'p')
%                 pixel_index=pixel_index+1;
%                 CorrenspondingPos(pixel_index,:)=[xValue  yValue];
%                  k=[]; 
%         end
%         xValue=min(xValue,10);xValue=max(xValue,-10);
%         yValue=min(yValue,10);yValue=max(yValue,-10);
%     end
%        
% end
