function [status, Coord, IMdif] = F_IMdif2Coord_131(IM, IM_o,ill_type, pl, blur_fact, nsig_bin, npxl_min, npxl_max)
% This function computes the difference between the coordinates of the 
% fish in the two input images. 
% INPUT:  IM              first input image  
%         IM_o            second input image (presumably the previous image)
%         ill_type        type of illumination: 'transmit' or 'reflex'
%         pl              plot option (1>yes, 0>no)
%         blur_fact       blurring factor
%         nsig_bin        number of sigma defining the binary threshold
%         npxl_min        Minimal number of pixels for a valid detection
%                         This is roughtly equal to the area of the fish
%         npxl_max        Maximal number of pixels for a valid detection
%                         This upper limit is usefull in case the whole
%                         arena moves. In case the detected changing are is
%                         bigger, then the status is set to 0
% OUTPUT: status          1: the fish moved, 0: the fish didn't move
%         Coord           coordinates in the image IM
%         IMdif           Difference 


    if nargin<7, npxl_min=200; end
    if nargin<6, nsig_bin=5; end
    if nargin<5, blur_fact=3; end     
    if nargin<4, pl=0; end 
    if nargin<3, ill_type='transmit'; end
    
    status=0;   Coord=[];
    %----------------------------------------------------------------------  
   
    switch ill_type
        case 'transmit'   
        IMdif=(IM_o-IM);
        case 'reflex'
        IMdif=(IM)-(IM_o);
    end    
    
    if blur_fact~=0
        IMdif_blur = F_IMfilt(IMdifX,'gaussian',0,blur_fact*4*[1 1],blur_fact);  
    else
        IMdif_blur=IMdif;
    end       
    
    dif_thr = nsig_bin * std(IMdif_blur(:));    
    IMdif_pos=uint8((IMdif_blur>dif_thr));    
    IMdif_pos_big = bwareaopen(IMdif_pos,npxl_min);  
    if sum(IMdif_pos_big(:))>npxl_min  &&  sum(IMdif_pos_big(:))<npxl_max
        status=1;
        Coord = F_Mask2Cetroid(IMdif_pos_big,0);        
    end
    
    %======================================================================
    if pl
        figure
        colormap gray
        ax(1)=subplot(2,3,1);
        imagesc(IM) 
        title('IM   status=0')        
        ax(2)=subplot(2,3,2);
        imagesc(IM_o) 
        title('IMo') 
        ax(3)=subplot(2,3,3);
        imshowpair(IM_o,IM)
        title('Comparison')
        
        ax(6)=subplot(2,3,6);
        imagesc(IMdif)   
        title('IM dif')  
        ax(5)=subplot(2,3,5);
        imagesc(IMdif_pos) 
        title('IMdif pos')
        ax(4)=subplot(2,3,4);
        imagesc(IMdif_pos_big) 
        title('IMdif pos big')   
        linkaxes(ax,'xy')
        
        if status
            subplot(2,3,1)
            hold on        
            plot(Coord(1),Coord(2),'.r');
            plot(Coord(1),Coord(2),'or');
            title('IM   status=1')        
        end
        
    end    
end


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