function [Data1,Data2,fh,sep] = F_SplitPopulation(Datai,pl,xbin)
% This function split the input sample in two sub samples in case two
% gaussian distribution can fit the distribution histogram.
 

    Datai=single(Datai(:));
    if nargin<3, xbin=min(Datai(:)):max(Datai(:)); end
    if nargin<2, pl=0; end
  
    %creating histogram
    [yfr,xbin] = hist(Datai,xbin);
        
    %fitting histogram with 2 gaussians
    warning off   
    fh = fit(xbin',yfr','gauss2');
    
    %finding separation between the 2 fitted gaussians
    a = (1/fh.c1^2) - (1/fh.c2^2);
    b = 2 * ( (fh.b2/fh.c2^2) - (fh.b1/fh.c1^2) );
    c = (fh.b1/fh.c1)^2 - (fh.b2/fh.c2)^2 - log(fh.a1/fh.a2);
    xmin = roots([a b c]);
    
    %selecting only valid solution between gaussian peaks
    if fh.b1<fh.b2, a=fh.b1; b=fh.b2; else a=fh.b2; b=fh.b1; end
    if (xmin(1)>a) && (xmin(1)<b), sep=xmin(1); else sep=xmin(2); end

    %splitting data 
    Data1=Datai(Datai>sep); 
    Data2=Datai(Datai<=sep);
    
    if pl
        %figure('name','F_SplitPopulation')
        hist(Datai,xbin); 
        hold on
        plot(fh,xbin,yfr); 
        plot(sep*[1 1],[0 max(yfr)],':r','linewidth',2)
        legend('Histogram','Data','2Gauss fit','Separator')
    end
    
end

