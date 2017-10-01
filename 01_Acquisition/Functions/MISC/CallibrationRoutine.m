%function (TransformationPairs)=
%% XY-callibration function

%% Initialize galvos
devices = daq.getDevices;s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000;

%% Define fixed points
 figure;
 [F,R]=read_most_recent_fluoroANDreflection();
 
 subplot(2,2,1);imagesc(R);title('Reference Reflection Image'); axis image;     
[x_fp, y_fp] = getpts; hold on;
viscircles([x_fp y_fp],5*(1:length(x_fp)).*ones(1,length(x_fp)));

k=[];
set(gcf,'keypress','k=get(gcf,''currentchar'');');
% 28 => leftArrow 29 => rightArrow 30 => upArrow 31 => downArrow
% 'uparrow','downarrow','leftarrow','riAghtarrow'.
pixel_index=0; xValue=0; yValue=0;
while pixel_index<length(x_fp);
    wd=300;
    subplot(2,2,2);imagesc(imadjust(imcrop(R,...
                            [(x_fp(pixel_index+1)-floor(wd/2)),...
                            (y_fp(pixel_index+1)-floor(wd/2)), wd, wd])));...
                            title(['Region Around point' num2str(pixel_index+1)]);      

   [F,R2]=read_most_recent_fluoroANDreflection();
   subplot(2,2,3);imagesc(imadjust(F));axis image;
   title(['X:' num2str(xValue) 'Y:' num2str(yValue)]);drawnow;
   outputSingleScan(s,[xValue yValue])
    if ~isempty(k)
        if strcmp(k,'d'); yValue = yValue + 0.1;  k=[]; 
        elseif strcmp(k,'a'); yValue = yValue - 0.1;     k=[]; 
        elseif strcmp(k,'w'); xValue = xValue + 0.1;     k=[]; %% Fix correspondance xy stages
        elseif strcmp(k,'s'); xValue = xValue - 0.1;    k=[]; 
        elseif strcmp(k,'p')
                pixel_index=pixel_index+1;
                CorrenspondingPos(pixel_index,:)=[xValue  yValue];
                 k=[]; 
        end
        xValue=min(xValue,10);xValue=max(xValue,-10);
        yValue=min(yValue,10);yValue=max(yValue,-10);
    end
end

%%
k=[];
counter=0;
tform=cp2tform([x_fp y_fp],CorrenspondingPos,'affine');

while 1==1;
 counter=counter+1;
[F,R]=read_most_recent_fluoroANDreflection();axis image;
subplot(1,2,1);imagesc(R);title('Reference Reflection Image'); title(['Counter' num2str(counter)]);axis image; 
[xM,yM] = ginput(1);
%[C] = get (gca, 'CurrentPoint');xM=C(1,1);yM=C(1,2);
%[X, Y] = tformfwd(T, U, V) applies the 2D-to-2D spatial transformation defined in T to coordinate arrays U and V, mapping the point [U(k) V(k)] to the point [X(k) Y(k)].
[rX,rY]= tformfwd(tform, xM, yM);
outputSingleScan(s,[rX rY]);
subplot(1,2,2);imagesc(F);axis image;

end


