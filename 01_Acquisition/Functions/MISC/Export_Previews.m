cd('I:\20151211\1810\RAW');
mkdir('Z:\NEUROBEHAVIORAL_IMAGING\ZebraTracker\DATA_as_we_go\20151211\1810\Previews');
sizeR=fread(fopen('Size_RefImag'),[1 2],'uint16');
sizeF=fread(fopen('Size_FluoroImag'),[1 2],'uint16');

All_refl_imag=dir('R_*');
All_fluoro_imag=dir('F_*');

frames=length(All_fluoro_imag);
%
h=figure('units','normalized','outerposition',[0 0 1 1])
k=0;
for i=1:1:frames
    k=k+1;
    display(i./frames)
    i_f=round((length(All_fluoro_imag)*i./frames));
    i_r=round((length(All_refl_imag)*i./frames));
    
    %waitbar(i./length(All_refl_imag),'ConvertingReflection') 
  %  try
        
        Rfile=fopen(All_refl_imag(i_r).name);Rimage=fread(Rfile,sizeR,'uint8');fclose(Rfile);
        Ffile=fopen(All_fluoro_imag(i_f).name);Fimage=fread(Ffile,sizeF,'uint16');fclose(Ffile);
        %Fall(:,:,i)=imresize(Fimage,0.25);
subplot(1,2,1);imagesc(Rimage,[0 50]);colormap(gray); title([num2str(i_r) '  ' All_refl_imag(i_r).date(end-4:end) ]);axis image; axis off
subplot(1,2,2);imagesc(fliplr(Fimage));colormap(gray);title([num2str(i_f) '  ' All_fluoro_imag(i_f).date(end-4:end)]);axis image; axis off; colorbar;
 %title(All_fluoro_imag(i_f).date(end-9:end));
 drawnow;
% %AAAA(:,:,i)=getframe;
AAAA=getframe(h);
% imwrite(mean(AAAA.cdata,3),['X:\20151114\1710\Preview_Flipped\Ind_Files' num2str(i) '.tiff'])
imwrite((AAAA.cdata),['Z:\NEUROBEHAVIORAL_IMAGING\ZebraTracker\DATA_as_we_go\20151211\1810\Previews\7F_n_R_preview' '.tiff'],'writemode', 'append')
clear AAAA Rimage Fimage;
pack;
% %     catch
% %         display('fuck!')
% %     end
end

