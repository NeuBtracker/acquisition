function [Background]=get_background_data(duration_of_averaging)

%% Record a 30 second video
%time=30;
Background_record_time=duration_of_averaging;  %%__CHANGE THIS LINE__(depending how fast the fish is moving)

fileID1 = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID1,uint8(1),'uint8');fclose(fileID1);
StartTime=str2num(datestr(datetime('now'),'yymmddHHMMSSFFF'));
[~,R,~,~]=read_most_recent_fluoroANDreflection();
for i=1:100
%waitbar(i/100,,wb_handle'AcquiringVideoOfSwimmingFish');
pause(double(Background_record_time)./100);
end
StopTime=str2num(datestr(datetime('now'),'yymmddHHMMSSFFF'));
fileID2 = fopen('Recording_ON_OFF_variable','w+');fwrite(fileID2,uint8(0),'uint8');fclose(fileID2);

sizeR_ID = fopen('Size_RefImag','r');sizeR=fread(sizeR_ID,[1,2],'uint16');fclose(sizeR_ID);

%% Load recorded reflection images
k=0;
all_R_r_images=dir('R_r*');
for i=1:length(all_R_r_images)
   All_Ref_ImageTimeStmps(i)=str2num(all_R_r_images(i).name(5:end)); 
end

Indexes=find(All_Ref_ImageTimeStmps>StartTime &  All_Ref_ImageTimeStmps<StopTime);

R_bgr=zeros(size(R,1),size(R,2),length(Indexes),'uint8');
for i=1:length(Indexes)
  %  waitbar(k./length(Indexes),wb_handle,'ProcessingVideo');
    try
    k=k+1;
    imageIDR = fopen(all_R_r_images(Indexes(i)).name,'r');
    if ~(imageIDR==-1);  R=uint8(fread(imageIDR,sizeR,'uint8'));   fclose(imageIDR);
    else R=NaN(size(R,1),size(R,2)); display('oups!');
    end
    if size(R,1)==sizeR(1)
    R_bgr(:,:,k)=R;
    else display([num2str(i) 'is a fluoro image?'])
    end
    catch display( [ 'skipping'  num2str(i) 'frame due to error'] );
    end
end
%delete(wb_handle)  
%% Estimate median as the background
Background=nanmedian(double(R_bgr),3);
cf=pwd;
imwrite(uint8(Background),['Background.tiff']);
%imwrite(uint8(Background),['D:\ZT_Matlab\Backgrounds\BackgroundImage_of_' cf(4:end) '.tiff']);

% %%Check used frames from validation
% figure;
% for i=1:10:size(R_bgr,3);
%    imagesc(R_bgr(:,:,i));title([num2str(i) './' num2str(size(R_bgr,3)) ] )
%    pause(0.001); drawnow;
% end


