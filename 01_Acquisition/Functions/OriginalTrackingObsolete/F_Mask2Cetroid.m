function [Coord] = F_Mask2Cetroid(Mask,pl)
% This function computes the centroid of the input Mask    
    if nargin<2, pl=0; end 
    
    if sum(Mask(:))~=0
        X=(1:size(Mask,2))'; Y=(1:size(Mask,1))';
        Ix=sum(Mask,1)'; Iy=sum(Mask,2);    
        Coord=[sum(X.*Ix)/sum(Ix), sum(Y.*Iy)/sum(Iy)];
    else
        Coord=[0 0];
    end
    
    if pl
        figure
        colormap gray
        imagesc(Mask)
        hold on
        plot(Coord(1),Coord(2),'.r')
        plot(Coord(1),Coord(2),'ob')
        title(['Coord=[',num2str(Coord(1),'%.2f'),',',num2str(Coord(2),'%.2f'),']'])
    end
end

