
%% Record a 30 second video
Background_record_time=120;  %%__CHANGE THIS LINE__(depending how fast the fish is moving)

fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(1),'uint8');fclose(fileID);
[~,R,~,RnumStart]=read_most_recent_fluoroANDreflection();
pause(Background_record_time);
[~,~,~,RnumEnd]=read_most_recent_fluoroANDreflection();
fileID = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID,uint8(0),'uint8');fclose(fileID);

sizeR_ID = fopen('Size_RefImag','r');sizeR=fread(sizeR_ID,[1,2],'uint16');fclose(sizeR_ID);

%% Load recorded reflection images
k=0;
R_bgr=zeros(size(R,1),size(R,2),RnumEnd-RnumStart,'uint8');
for i=RnumStart:RnumEnd
    k=k+1;
    imageIDR = fopen(['R_r_' num2str(i,'%09d')],'r');
    if ~(imageIDR==-1);  R=uint8(fread(imageIDR,sizeR,'uint8'));   fclose(imageIDR);
    else R=NaN; display('oups!');
    end
    R_bgr(:,:,k)=R;
end

%% Estimate median as the background
R_bgr_med=nanmedian(R_bgr,3);


