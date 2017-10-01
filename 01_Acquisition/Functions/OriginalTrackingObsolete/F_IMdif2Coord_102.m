function [Coord_diff,Coord_f,Coord_i,IMdif] = F_IMdif2Coord_102(IM, IM_o, pl, blur_fact, nsig_bin, npxl_min, ill_type)
% This function computes the difference between the coordinates of the 
% fish in the two input images. 
% INPUT:  IM              first input image  
%         IM_o            second input image (presumably the previous image)
%         pl              plot option (1>yes, 0>no)
%         blur_fact       blurring factor
%         nsig_bin        number of sigma defining the binary threshold
%         npxl_min        minimal number of pixels for a detected feature
%         ill_type        type of illumination: 'trasmit' or 'reflex'
% OUTPUT: Coord_diff      difference coordinates 
%         Coord_f         coordinates in the image IM
%         Coord_i         coordinates in the image IM_o
%         IMdif           Difference 

    if nargin<7, ill_type='trasmit'; end
    if nargin<6, npxl_min=60; end
    if nargin<5, nsig_bin=6; end
    if nargin<4, blur_fact=0; end     
    if nargin<3, pl=0; end 
    
    switch ill_type
        case 'trasmit'   
        IMdif=single(IM_o)-single(IM);
        case 'reflex'
        IMdif=single(IM)-single(IM_o);
    end
    
    IMdif_pos=IMdif; IMdif_pos(IMdif<0)=0; 
    if blur_fact~=0
        IMdif_pos_blur = F_IMfilt(IMdif_pos,'gaussian',0,blur_fact*4*[1 1],blur_fact);  
    else
        IMdif_pos_blur=IMdif_pos;
    end
    
    IMdif_pos_grad = imgradient(IMdif_pos_blur);       
    dif_thr = nsig_bin * std(IMdif_pos_grad(:));
    IMdif_pos_bin=uint8((IMdif_pos_grad>dif_thr));
    IMdif_pos_big = uint8(bwareaopen(IMdif_pos_bin,npxl_min));
    if sum(IMdif_pos_big(:))==0
        IMdif_pos_fill = IMdif_pos_big;
    else
        IMdif_pos_fill = imfill(IMdif_pos_big);
    end    
    
    IMdif_neg=IMdif; IMdif_neg(IMdif>0)=0; IMdif_neg=-IMdif_neg; 
    if blur_fact~=0
        IMdif_neg_blur = F_IMfilt(IMdif_neg,'gaussian',0,blur_fact*4*[1 1],blur_fact); 
    else
        IMdif_neg_blur=IMdif_neg;
    end
    IMdif_neg_grad = imgradient(IMdif_neg_blur);       
    dif_thr = nsig_bin * std(IMdif_neg_grad(:));
    IMdif_neg_bin=uint8((IMdif_neg_grad>dif_thr));
    IMdif_neg_big = uint8(bwareaopen(IMdif_neg_bin,npxl_min));
    if sum(IMdif_neg_big(:))==0
        IMdif_neg_fill = IMdif_neg_big;
    else
        IMdif_neg_fill = imfill(IMdif_neg_big);
    end    
        
    
    Coord_diff=[0 0]; Coord_f=[0 0]; Coord_i=[0 0]; a=0; b=0;
    if (sum(IMdif_pos_fill(:))~=0)
        Coord_f = F_Mask2Cetroid(IMdif_pos_fill); 
        a=1;
    end
    if (sum(IMdif_neg_fill(:))~=0)
        Coord_i = F_Mask2Cetroid(IMdif_neg_fill);
        b=1;
    end
    if a==1 && b==1
        Coord_diff=Coord_f-Coord_i; 
    end
    
    if pl
        figure
        colormap gray
        ax(1)=subplot(3,3,1);
        imagesc(IM) 
        hold on        
        plot(Coord_f(1),Coord_f(2),'.b');
        plot(Coord_f(1),Coord_f(2),'ob');
        title('IM')        
        ax(2)=subplot(3,3,2);
        imagesc(IM_o) 
        hold on
        plot(Coord_i(1),Coord_i(2),'.r');
        plot(Coord_i(1),Coord_i(2),'or');
        title('IM-o') 
        ax(3)=subplot(3,3,3);
        imshowpair(IM_o,IM) 
        
        ax(6)=subplot(3,3,6);
        imagesc(IMdif)   
        title('IM dif')        
        ax(4)=subplot(3,3,4);
        imagesc(IMdif_pos_grad) 
        title('IMdif-grad POS')
        ax(5)=subplot(3,3,5);
        imagesc(IMdif_neg_grad) 
        title('IMdif-grad NEG')   
        linkaxes(ax,'xy')
        
        
        ax(7)=subplot(3,3,7);
        imagesc(IMdif_pos_fill) 
        title('IMdif-fill POS')
        ax(8)=subplot(3,3,8);
        imagesc(IMdif_neg_fill) 
        title('IMdif-fill NEG')   
        linkaxes(ax,'xy')
    end    
end

