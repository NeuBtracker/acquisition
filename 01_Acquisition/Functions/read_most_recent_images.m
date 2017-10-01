function [F,R,mrFnumber,mrRnumber]=read_most_recent_images(imagetype)
% imagetype:
%'r': reflection
%'f': fluorescence
%'b': both


F=666; R=666;
mrFnumber=666;mrRnumber=666;
try
    
    
    if strcmp(imagetype,'f') ||  strcomp(imagetype,'b')
        try
            mrF=fopen('Most_Recent_FluoroImag','r');mrFnumber=char(fread(mrF,15,'uint32'))';fclose(mrF);
            sizeF_ID = fopen('Size_FluoroImag','r');sizeF=fread(sizeF_ID,[1,2],'uint16');fclose(sizeF_ID);
            imageIDF = fopen(['F_' (mrFnumber)],'r');
            if (imageIDF==-1);  imageIDF = fopen(['F_r_' num2str(mrFnumber)],'r'); end
            if ~(imageIDF==-1); F=uint16(fread(imageIDF,sizeF,'uint16'));  fclose(imageIDF);
            else   F=666*zeros(sizeF,'uint16');
            end
        catch
            display('Fluorescence image not read')
        end
    end
    
    
    if strcmp(imagetype,'r') ||  strcmp(imagetype,'b')
        try
            mrR=fopen('Most_Recent_RefImag','r');mrRnumber=char(fread(mrR,15,'uint32'))';fclose(mrR);
            sizeR_ID = fopen('Size_RefImag','r');sizeR=fread(sizeR_ID,[1,2],'uint16');fclose(sizeR_ID);
            imageIDR = fopen(['R_' (mrRnumber)],'r');
            if (imageIDR==-1); imageIDR = fopen(['R_r_' num2str(mrRnumber)],'r'); end
            if ~(imageIDR==-1);  R=uint8(fread(imageIDR,sizeR,'uint8'));   fclose(imageIDR);
            else R=66.*ones(sizeF,'uint16');
            end
        catch
            display('Reflection image not read')
        end
    end
    
    
end
