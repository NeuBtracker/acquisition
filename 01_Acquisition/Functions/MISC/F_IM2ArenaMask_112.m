function [Mask_logic] = F_IM2ArenaMask_112(IM,pl,arena_type)
% This function define a logical mask of the imaged arena.
% The illumination of the arena must be from the bottom.
% The arena is expected to be an ELLIPSE with one big SEPARATOR.
% Small deviations from such model are corrected.
% INPUT:  IM              input image
%         pl              plot option (1>yes, 0>no)
%         arena_type      modelling of the arena
%                         'ellipse' only elliptical shape
%                         'ell_sep' elliptical shape with a separator
% OUTPUT: Mask_logic      logical array defining the mask of the arena

    if nargin<3, arena_type='ellipse'; end
    if nargin<2, pl=0; end

    % raw-splitting of the background (black) and arena (white)
    max_IM=single(max(IM(:)));
    
    [~,~,~,sep] = F_SplitPopulation(IM,0,0:max_IM);
    frac_bin=sep/max_IM;    
    Mask_bw = F_IM2Mask_101(IM,0,frac_bin,0); 
    % smoothing borders and filling holes
    Mask_sm = imfill(F_IM2Mask_101(Mask_bw,0,0.5,5)); 
    % defining border of the arena
    Mask_perim = imgradient(Mask_sm);

    % sampling border of the arena
    Pts=[];
    for i=1:20:size(IM,1)
        id=find(Mask_perim(i,:)~=0);
        if ~isempty(id)
            Pts=[Pts;[id(1)   i]];
            Pts=[Pts;[id(end) i]];
        end    
    end
    % fitting the border of the arena with an ellipse
    ellipse_t = fit_ellipse(Pts(:,1),Pts(:,2));
    
    % creating the elliptical mask of the arena
    [x, y] = meshgrid(1:size(IM,2),1:size(IM,1));
    el=((x-size(IM,2)/2)/ellipse_t.a).^2+((y-size(IM,1)/2)/ellipse_t.b).^2<=1;
    el_rot= F_IMregist_manual_102(el,el,0,[-(size(IM,2)/2-ellipse_t.X0_in), size(IM,1)/2-ellipse_t.Y0_in],180*ellipse_t.phi/pi);
    el_rot=cast(el_rot,'like',IM);
    
    % detecting separator in the arena
    switch arena_type
        case 'ellipse'
            Sep_mask=cast(zeros(size(IM)),'like',IM);
        case 'ell_sep'
            Diff=el_rot-Mask_sm;
            Sep_mask=F_IM2Mask_101(Diff,0,0.99,0); 
    end
    
    Mask_arena = el_rot - Sep_mask; 
    Mask_logic = (Mask_arena~=0);
    
    if pl
        figure
        colormap gray
        subplot(2,3,1)
        imagesc(IM); title('Input image + mask')
        subplot(2,3,2)
        F_SplitPopulation(IM,1,0:single(max(IM(:))));
        xlim([0 max_IM])
        title('Binarization')  
        subplot(2,3,3)
        imagesc(Mask_perim)
        title('Raw arena borders')  
        h=subplot(2,3,6);
        plot(Pts(:,1),Pts(:,2),'ok')
        xlim([1 size(IM,2)]); ylim([1 size(IM,1)])
        set(gca,'Ydir','reverse')
        ellipse_t = fit_ellipse(Pts(:,1),Pts(:,2),h);  
        title('Ellipse fit')   
        subplot(2,3,5)
        imagesc(Sep_mask) 
        title('Mask of the separator') 
        subplot(2,3,4)
        imagesc(Mask_arena) 
        title('Final mask')
        subplot(2,3,1)
        hold on        
        b = bwboundaries(Mask_arena);
        hold on
        for k = 1:numel(b)
            plot(b{k}(:,2), b{k}(:,1), 'r', 'Linewidth', 1)
        end
    end
end

