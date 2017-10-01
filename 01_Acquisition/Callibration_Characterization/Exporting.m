%% Preparing Stiching4Publication
cd('Z:\NEUROBEHAVIORAL_IMAGING\ZebraTracker\DATA_as_we_go\Characterization25Mai2016\DotsbyRaytrixTilted1436');
all_paths=dir('Z_pos');
for i_path=1:length(all_paths);
    cd(['Z:\NEUROBEHAVIORAL_IMAGING\ZebraTracker\DATA_as_we_go\Characterization25Mai2016\DotsbyRaytrixTilted1436\' all_paths(i_path).name]);
% imwrite(((uint16(buf2))), ['F_x_' num2str(-ix,'%02d') '_y_' num2str(iy,'%02d') '.tiff'] );
All_imag=dir('F*.tiff')
k=0;
mkdir('Export4Imagej1')
 % F=imread( ['F_x_' num2str(0,'%02d') '_y_' num2str(0,'%02d') '.tiff'] );
 % figure;axis image;
 % [~,croprect]=imcrop(imagesc(F));
 
for iy=-5:1:5
                      for ix=-5:1:5
                          k=k+1;
               F=imread( ['F_x_' num2str(-iy,'%02d') '_y_' num2str(ix,'%02d') '.tiff'] );
               A=F(round(size(F,1)./2)-250:round(size(F,1)./2)+250,round(size(F,1)./2)-250:round(size(F,1)./2)+250);
          % A=imcrop(F,croprect;
            %   imwrite(uint8(256.*(double(A)./5000)),['Export4Imagej7\F_' num2str(k,'%04d') '.tiff'])
               imwrite(uint16(A),['Z:\NEUROBEHAVIORAL_IMAGING\ZebraTracker\DATA_as_we_go\Characterization25Mai2016\DotsbyRaytrixTilted1436\Export4Imagej1\Z_' num2str(i_path)  'F_' num2str(k,'%04d') '.tiff'])
                      end
end
end