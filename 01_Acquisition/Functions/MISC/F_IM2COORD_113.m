function [Coord] = F_IM2COORD_113(IM,BKGR,MASK,reb_fact,myfilter)
    
    % REBIN / BKGR-subtr. / MASK / SMOOTH --------------------------------
    IM_smooth = imfilter( ((imresize(IM, reb_fact) - BKGR).*MASK), myfilter, 'replicate');
            
    % Integrating over the 2 dimensions
    u1=sum(IM_smooth,1); u2=sum(IM_smooth,2);
  
    % Computing Coordinates
    Coord=[mean(find(u2>=max(u2)/2)) mean(find(u1>=max(u1)/2))]/reb_fact;       

end

