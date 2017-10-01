function IM = read_tiffImage(Path_root, NamesList, i)
%This function reads the image with index 'i' from the list of 
%names specified by 'NamesList' in the folder specified by 'Path'. 

IM = imread([[Path_root,'/'] NamesList{i}]); 