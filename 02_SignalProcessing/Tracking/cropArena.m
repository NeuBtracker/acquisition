function croppedImage =  cropArena(IM, ci)
% This function crops the arena from the input image IM. 
%'ci' is a vector containing the arena dimensions: ci = [c_x, c_y, r].
% c_x, c_y are the coordinates of the center of the arena, r is the radius 
% of the arena
    
imageSize = size(IM);
croppedImage = IM;
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
croppedImage(find(mask==0)) = min(IM(:)); 