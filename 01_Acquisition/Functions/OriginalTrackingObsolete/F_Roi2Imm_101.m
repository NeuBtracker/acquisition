function [Im_roi_all] = F_Roi2Imm_101(ROI_pxl,sizex,sizey,pl,n_color)
% This function creates an image starting from the input list of ROIs and
% the size of the image
%
% Input:    ROI_pxl          cell array with the list of pixels defining
%                            each single ROI
%           sizex, sizey     sizes of the output image 
%                            (must be the same of the dataset with which the ROIs have been identified)
%           pl               define type of plot
%             pl=1             white ROIs
%             pl=2             white ROIs with number label
%             pl=3             coloured ROIs
%           n_color          number of colours to use in case pl=3
% Output:   Im_roi           The output data which is masked 
%           Im_roi_sum       define type of plot

    n_roi=length(ROI_pxl);

    if nargin < 5, n_color=n_roi; end
    if nargin < 4, pl=0; end
    n_color=n_color+1;
    
    Im_roi_all=uint8(zeros(sizex,sizey));
    Im_roi_col=Im_roi_all;    
    for r=1:n_roi %over all the ROI    
        Im_roi_all(ROI_pxl{r})=1;
        Im_roi_col(ROI_pxl{r})=mod(r,n_color)+1;
    end

    if (pl==1) || (pl==2)
        figure('name','Roi2Imm')
        imagesc(Im_roi_all)
        colormap('gray')
        title('Single ROIs areas')
        if pl==2
            for r=1:n_roi %over all the ROI
                [px,py]=ind2sub([sizex,sizey],ROI_pxl{r}); 
                text(mean(py)-1,mean(px)+1,num2str(r),'color','r',...
                     'HorizontalAlignment','left','FontSize',10) 
            end  
        end
    end
    
    if pl==3
        figure('name','Roi2Imm')
        imagesc(Im_roi_col)
        colormap(jet(n_color))
        title('All the ROIs label')        
    end

end %end Function F_Roi2Imm


    