%
load('D:\ZT_Matlab\tform_example2.mat')
devices = daq.getDevices;s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
addAnalogOutputChannel(s,'Dev1',2,'Voltage');
s.Rate = 8000;
outputSingleScan(s,[0 0]);

k=[];
counter=0;
while 1==1;
 counter=counter+1;
[F,R]=read_most_recent_fluoroANDreflection();axis image;
subplot(1,2,1);h_withcross=plot(1:5000,1:5000);xlim([1 size(R,1)]);ylim([1 size(R,2)]);
imagesc(R);title('Reference Reflection Image'); title(['Counter' num2str(counter)]);
[xM,yM] = ginput(1);

%[xM,yM]=gpos(h_withcross);
%[C] = get (gca, 'CurrentPoint');xM=C(1,1);yM=C(1,2);
%[X, Y] = tformfwd(T, U, V) applies the 2D-to-2D spatial transformation defined in T to coordinate arrays U and V, mapping the point [U(k) V(k)] to the point [X(k) Y(k)].
[rX,rY]= tformfwd(tform, xM, yM);
xValue=rX;yValue=rY;
        xValue=min(xValue,10);xValue=max(xValue,-10);
        yValue=min(yValue,10);yValue=max(yValue,-10);

outputSingleScan(s,[xValue yValue]);
subplot(1,2,2);imagesc(F);axis image;
end
