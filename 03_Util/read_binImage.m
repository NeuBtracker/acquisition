function IM = read_binImage(Path_root, LIST_R, i)
%This function reads the image with index 'i' from the list of 
%names specified by 'LIST_R' in the folder specified by 'Path'. 

im_size=[1024 1280]/2;
im_class='uint8';
name=fullfile(Path_root, LIST_R(i).name);
fileID = fopen(name);   
IM = cast(fread(fileID,im_size,im_class),im_class);
fclose(fileID);