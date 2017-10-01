function [Mask,Outline,IM_perim] = F_IM2Mask_101(IM_in,pl,frac_bin,np_blur)
% This function estimates a binary mask of the fish in the input image.
% The contour of the mask is also estimated and overimpose to the input
% image
% INPUT:  IM_in      input image
%         pl         plot option
%         frac_bin   binarization threshold
%         np_blur    gaussian bluring size
% OUTPUT: Mask       mask of the fish
%         Outline    logical image of the contour of the mask
%         IM_perim   Input image with overimpose the contour of the mask

    if nargin<4, np_blur=4; end
    if nargin<3, frac_bin=0.1; end
    if nargin<2, pl=0; end
   
    
    IM_in=single(IM_in);
    % blurring image
    if np_blur>0
        IM_blur=F_IMfilt(IM_in,'gaussian',0,4*np_blur,np_blur); 
    else
        IM_blur=IM_in;
    end
    
    %binarizing image
    max_threshold = max(IM_blur(:));
    min_threshold = min(IM_blur(:)) + (max_threshold-min(IM_blur(:)))*frac_bin;
    IM_bin= uint8(zeros(size(IM_in)));
    IM_bin(IM_blur>=min_threshold)=1;    
    
    %detecting clumps
    cc = bwconncomp(IM_bin, 8); 
    %selecting the biggest clumps
    ROI_all=cc.PixelIdxList';
    L=[];
    for r=1:length(ROI_all)
        L=[L;length(ROI_all{r})];
    end
    %creating the final mask image
    Mask = F_Roi2Imm_101(ROI_all(L==max(L)),size(IM_in,1),size(IM_in,2));
    
    %computing border of the mask
    Outline = bwperim(Mask);
    IM_perim = IM_in .* cast(Mask,'like',IM_in);
    IM_perim(Outline) = max(IM_in(:));  
    
    if pl
        figure('name','F_IM2Mask')
        colormap gray
        subplot(2,2,1)
        imagesc(IM_in); title('Input image')
        subplot(2,2,2)
        imagesc(IM_blur); title('Blurred')
        subplot(2,2,3)
        imagesc(IM_bin); title('Thresholded')
        subplot(2,2,4)
        imagesc(Mask); title('FINAL MASK')
    end
    
end

