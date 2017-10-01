%%
clc;clear;close;
addpath(genpath('D:\ZT_Matlab\IndivParts'));
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
%load('K:\NEXT_tform');
cd(path);


[controlNum1, deviceName] = midiid;pause(2);
initialControlValues=[0.5];
midicontrolsObject = midicontrols([controlNum1],initialControlValues,'MIDIDevice',deviceName);

                               
tp=num2str(fix(clock));
err=writeValue4ETL(0);
[~,cmdout] = dos([...
    'python D:\ZT_Matlab\IndivParts\ETL_pythonP\ETL_looped_reading_file.py ' num2str(0) '&']  )

%clc;clear;close;
ref_d=0;
kk=0;
profile clear
profile on;
bestfocus=0.01;
focus_measure=0.001;%Initialized to force original step of 10;

m_pr=midiread(midicontrolsObject);
     
while 1==1;
    
    m_th=midiread(midicontrolsObject);
    if ~(m_th==m_pr) 
        manual_move=(m_th-m_pr).*100
        ref_d=ref_d+ manual_move;
          m_pr=m_th;
        continue;
    end
  
    
    err=writeValue4ETL(ref_d); pause(0.05);
[buf2,~,im_i,~]=read_most_recent_images('f');
focus_measure=fmeasure(imresize(buf2,0.2),'BREN');


%        if (focus_measure>0.9*bestfocus) && kk>1
%            display(['all good' num2str(focus_measure./bestfocus)]);
%            bestfocus=max(bestfocus,focus_measure);
%            continue          
%         end
     

    kk=kk+1;
    Dd=5;%100.*(1-(focus_measure./bestfocus))%10;
    rel_ds=[-Dd:(Dd./3):Dd];
       abs_ds= ref_d+rel_ds; 
      abs_ds(abs_ds<-200)=-200;
      abs_ds(abs_ds>200)=200;
    for i=1:length(rel_ds)
        
        err=writeValue4ETL(abs_ds(i));
        if i==1
            pause(0.1);
        else
        pause(0.05);
        end
        [buf2,~]=read_most_recent_fluoroANDreflection();
        focus_measure=fmeasure(imresize(buf2,0.2),'BREN');
        FMs(i)=focus_measure;        
    end
    %FMs_sm=smooth(FMs)';
    FMs_m=medfilt1(FMs,3);
    p=polyfit(abs_ds,FMs,2);
    if p(1)>0;
        display('Wrong curvature');
       % FMss=medfilt1(FMs,3);    
        [max_focus,max_index]=max((FMs));
        ref_d=round(abs_ds(max_index),0);
        bestfocus=max(bestfocus,max_focus);
        continue;        
    end
    %thsi returns: p1*x^2+p2*x+p3 and the optimium is -p2/(2.*p1)
    Fop=-(p(2)./(2.*p(1)));
   if Fop>ref_d+3*Dd && Fop>0
        Fop=ref_d+2.*Dd;
        display('too out up')
    end
    if Fop<ref_d-3*Dd && Fop<0
        Fop=ref_d-2.*Dd;
        display('too out down')
    end
    ref_d=round(Fop,2);  
     
     err=writeValue4ETL(ref_d);
     pause(0.1);
     [buf2,~,im_i,~]=read_most_recent_images('f');
     focus_measure=fmeasure(imresize(buf2,1),'BREN');
     num2str(focus_measure./bestfocus);
    
 
    subplot(2,2,1);plot(kk,focus_measure,'or');hold on;title(num2str(kk));
    subplot(2,2,1);plot(kk,bestfocus,'og');hold on;title(num2str(kk));
    subplot(2,2,4);plot(kk,ref_d,'o');hold on;title(num2str(kk));
    subplot(2,2,2);
    plot(abs_ds,FMs,'ro');hold on;
    subplot(2,2,2);
    plot(abs_ds,polyval(p,abs_ds),'-k');
    plot(Fop,polyval(p,Fop),'og','MarkerSize',10); hold on;
        
    subplot(2,2,3);
    plot(abs_ds,FMs,'ro');hold on;
    plot(abs_ds,polyval(p,abs_ds),'-r'); hold on;
    plot(Fop,polyval(p,Fop),'og','MarkerSize',10); 
    plot(Fop,focus_measure,'*g','MarkerSize',10);
    try
            plot(abs_dsp,FMsp,'ko'); hold off;
    catch
    end
    drawnow; 
     FMsp=FMs;
     abs_dsp=abs_ds;


end


% % 
% % clc;clear;close;
% % close all; figure;
% % ref_d=0;
% % kk=0;
% % profile clear
% % profile on;
% % err=writeValue4ETL(0);
% % bestfocus=0.01;
% % focus_measure=0.001; %Initialized to force original step of 10;
% % while 1==1;
% % kk=kk+1;
% % if mod(kk,50)==1
% %     err=writeValue4ETL(0);
% % 
% % end
% %     Dd=20;%.*(1-(focus_measure./bestfocus))%10;
% %     rel_ds=[-Dd:(Dd./5):Dd];
% %       
% %     [buf2,~,im_i,~]=read_most_recent_images('f');
% %      focus_measure=fmeasure(imresize(buf2,1),'GLLV');
% %      num2str(focus_measure./bestfocus)
% %         if (focus_measure>0.8*bestfocus) && kk>1
% %            ref_d=round(abs_ds(max_index),0);            
% %            display(['all good' num2str(focus_measure./bestfocus)]);
% %            bestfocus=max(bestfocus,focus_measure);
% %            continue          
% %         end
% %      
% %       Dd=10;%.*(1-(focus_measure./bestfocus))%10;
% %       rel_ds=[-Dd:(Dd./5):Dd];  
% %       abs_ds= ref_d+rel_ds; 
% %       abs_ds(abs_ds<-200)=-200;
% %       abs_ds(abs_ds>200)=200;
% % 
% %     for i=1:length(rel_ds)
% %     
% %         err=writeValue4ETL(abs_ds(i));
% %         if i==1
% %         pause(0.2);
% %         else
% %         pause(0.01);
% %         end
% %         [buf2,~,im_i,~]=read_most_recent_images('f');
% %         im_i_a(i)=str2double(im_i);
% %         focus_measure=fmeasure(imresize(buf2,1),'BREN');
% %         num2str(focus_measure./bestfocus)
% %         FMs(i)=focus_measure;
% %         
% %     end
% %     
% %     FMss=medfilt1(FMs,3);    
% %     [max_focus,max_index]=max((FMss));
% %     ref_d=round(abs_ds(max_index),0);
% %     bestfocus=max(bestfocus,max_focus);
% % 
% %     
% %         if isnan(ref_d); ref_d=0;    end
% %   %  if ref_d>200;    ref_d=150; display('limit'); end
% %   %  if ref_d<-200;   ref_d=-150; display('limit'); end
% %     
% %     subplot(2,2,1);plot(kk,max_focus,'or');hold on;title(num2str(kk));
% %     subplot(2,2,1);plot(kk,bestfocus,'og');hold on;title(num2str(kk));
% %     %subplot(2,2,4);plot(ref_d,max_focus,'o');hold on;title(num2str(kk));
% %     
% %     subplot(2,2,4);plot(rel_ds,im_i_a,'o');hold off;title(num2str(kk));
% %     
% % 
% %     subplot(2,2,2); 
% %         if mod(kk,20)==0; hold off;end
% %         plot(abs_ds,FMs,'o',...
% %         'color',[mod(kk,20)./20 0 1-mod(kk,20)./20]);hold on;
% %     subplot(2,2,3);    plot(abs_ds,FMs,'ro');hold on;
% %     subplot(2,2,3);    plot(abs_ds(max_index),max_focus,'go');hold on;
% %     if kk>1
% %     subplot(2,2,3);    plot(abs_dsp,FMsp,'ko');hold off;
% %     end
% %     drawnow;
% %     
% %     FMsp=FMs;
% %     abs_dsp=abs_ds;
% % end


