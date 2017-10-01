function [Coord] = mask2Cetroid(Mask)
% This function computes the centroid of the input Mask   
            
if sum(Mask(:))~=0
    s = regionprops(Mask,'centroid');
    Coord = s.Centroid;
else
    Coord=[0 0];
end

end