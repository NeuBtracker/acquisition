function [Coord] = F_IM2COORD_200(IM,pl,MASK,blur_fact)
% This function computes the coordinates of the fish in the input image.
% The input image is masked accordingly to the arena dimensions and shape.
% The illumination of the arena must be from the bottom.
% INPUT:  IM              input images of the arena with the fish     
%         pl              plot option (1>yes, 0>no)
%         MASK            mask defining the arena
%         blur_fact       bluring factor of the input image
% OUTPUT: Coord           coordinates of the fish in the arena

    if nargin<4, blur_fact=1; end
    if nargin<3, MASK=ones(size(IM)); end       
    if nargin<2, pl=0; end 
    
    % blurring image   
    myfilter = fspecial('gaussian',blur_fact*4*[1 1], blur_fact); 
    IM_blur = imfilter(IM, myfilter, 'replicate');
    
    % masking the arena
    IM_mask=IM_blur.*cast(MASK,'like',IM_blur);
    
    % finding fish where the minima are
    [ym,xm]=find(IM_mask==min(IM_blur(MASK==1)));    
    
    % Computing Coordinates 
    Coord=[mean(xm),mean(ym)];
    
    
    if pl
        figure('name','F_IM2COORD')
        colormap gray
        subplot(2,2,1)
        imagesc(IM)       
        hold on
        plot(Coord(1),Coord(2),'.r')
        title('Input image')
        
        subplot(2,2,2)
        imagesc(IM_blur)
        title('Blurred image')
        
        MASK_bord = bwboundaries(MASK); MASK_bord=MASK_bord{1};
        subplot(2,2,4)
        imagesc(IM_mask)
        hold on
        plot(MASK_bord(:,2), MASK_bord(:,1), 'r', 'Linewidth', 1)
        title('Masked image')
                
        subplot(2,2,3)
        imagesc(MASK)
        hold on
        plot(xm,ym,'.r') 
        plot(Coord(1),Coord(2),'ob')
        title(['Coordinates = [',num2str(Coord(1),'%.2f'),',',num2str(Coord(2),'%.2f'),']'])        
    end    
end

