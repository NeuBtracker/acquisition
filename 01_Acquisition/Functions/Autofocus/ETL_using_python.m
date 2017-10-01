%% Autofocus stand-alone worker using images spooled to disk and ETL-voltage
% feeded to a Python programm as global variable


% Greating path
clc;clear;close;
addpath(genpath('D:\ZT_Matlab\'));
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
%load('K:\NEXT_tform');
cd(path);
tp=num2str(fix(clock));
% Initiliazing the python software running in the background, which
% reads a txt file and applies the voltage to the etl
err=writeValue4ETL(0);
[~,cmdout] = dos([...
    'python D:\ZT_Matlab\IndivParts\ETL_pythonP\ETL_looped_reading_file.py ' num2str(0) '&']  )

  err=writeValue4ETL(0);
  %while 1==1
 
%   iii=0;    
% for i=-20:0.5:20
%     ref_d=i;
%     iii=iii+1;
%         err=writeValue4ETL(ref_d);
%           Zscan(iii,1)=ref_d;
%           Zscan(iii,2)=now;
%       pause(0.05);
% end 
%   end

% end
% 
% for i=-20:0.005:20
%     ref_d=i;
%         err=writeValue4ETL(ref_d);
%         pause(0.05);
% end


%Initialization of varibles
clc;clear;close;
ref_d=0;
kk=0;
profile clear
profile on;
bestfocus=0.0000001;
focus_measure=0.001;%Initialized to force original step of 10;
profile on
jj=0;
%% Main loop 
%hile kk<1000;
while 1==1;
    jj=jj+1;
    AFp2s{jj,1}=now;
     AFp2s{jj,13}=ref_d;
    %% Check focus
    % Apply voltage and wait for the ETL to stabiliz
    err=writeValue4ETL(ref_d); pause(0.005);
    %Read most recent fluorecent image
[buf2,~,im_i,~]=read_most_recent_images('f');
    %Estimate focus measure
    buf2(buf2<300)=0;
focus_measure=fmeasure(imresize(buf2,0.25),'BREN');
    AFp2s{jj,2}=focus_measure;
    %% If the focus measure is "good enough" just continue
        if (focus_measure>0.85*bestfocus) && kk>1
           display(['all good' num2str(focus_measure./bestfocus)]);  
           bestfocus=max(bestfocus,0.9.*focus_measure); 
           continue          
        end
             AFp2s{jj,13}=(focus_measure>0.85*bestfocus);
            AFp2s{jj,3}=bestfocus; 
    %% If the focus is not good we acquire several images around current    
    kk=kk+1; %counter of when we enter the autofocus routine
    AFp2s{jj,4}=kk;
    % Define range (in Amps) for around which we look for the best position
    Dd=10;  
    %Dd=100.*(1-(focus_measure./bestfocus))%10; -> to make it dynamic
    %based on how bad is the current focus
    Number_of_Position_to_test=5;
    rel_ds=[-Dd:(Dd./ Number_of_Position_to_test):Dd]; %Relative position
    abs_ds= ref_d+rel_ds; %Absolute posisition (relatives, around current)
      abs_ds(abs_ds<-200)=-200;
      abs_ds(abs_ds>200)=200;
    for i=1:length(rel_ds)
        
        err=writeValue4ETL(abs_ds(i)); %apply voltage
        if i==1   %wait depend on if the movement is smooth or not
                  %due to inertia phenoma in ELT
            pause(0.1); 
        else
            pause(0.05);
        end
        [buf2,~,im_i,~]=read_most_recent_images('f');
        focus_measure=fmeasure(imresize(buf2,1),'BREN');
        FMs(i)=focus_measure;        
    end
    AFp2s{jj,5,:}=FMs;
    AFp2s{jj,6,:}=rel_ds;
    AFp2s{jj,7,:}=abs_ds;
    AFp2s{jj,8}=ref_d;
   
    %FMs_sm=smooth(FMs)';
    %FMs_m=medfilt1(FMs,2); % We smooth the focus vs. ETL_pos 
                           % to reduce noise
      FMs_m=FMs;                     
    p=polyfit(abs_ds,FMs,2); %We fit a 2end degree polyonimal
      AFp2s{jj,9,:}=FMs_m;
       AFp2s{jj,10,:}=p;
    %?????: Easy+fast way to force proper fittin and avoid next step?
    
    %% Problematic Fitting
    if p(1)>0;  %If the curvature is not the expected(down,up,down)
                %we do not trust it and we just move to the position with
                %the best focus (among the ones we last tested)
        display('Wrong curvature');
       % FMss=medfilt1(FMs,3);    
        [max_focus,max_index]=max((FMs));
        ref_d=round(abs_ds(max_index),0);
        bestfocus=max(bestfocus,max_focus); %Update best focus
        continue;   %sorry for the "continue" but its easier that keepin
                    %track of the elseif during development:(    
    end
    AFp2s{jj,11}=p(1)>0;

    %% Trustworthy fitting
    
    %the polyfit returns: p1*x^2+p2*x+p3 and the optimium is -p2/(2.*p1)
    Fop=-(p(2)./(2.*p(1))); %Estimated the best optimal
    %If the predicted optimal is too much away from tested values, force
    % it to be closer.
   if Fop>ref_d+3*Dd && Fop>0
        Fop=ref_d+2.*Dd;
        display('too out up')
    end
    if Fop<ref_d-3*Dd && Fop<0
        Fop=ref_d-2.*Dd;
        display('too out down')
    end
    ref_d=round(Fop,2);  % just rounding for 
    AFp2s{jj,12}=ref_d;
%%  Same as first step of the LOOP, reduntant.   
% %      err=writeValue4ETL(ref_d); % saving it to the global variable
% %      pause(0.005);
% %      [buf2,~,im_i,~]=read_most_recent_images('f');
% %      focus_measure=fmeasure(imresize(buf2,1),'BREN');
% %      num2str(focus_measure./bestfocus);
    
 

%% Some plotting to confirm if it make sense and for documenation.
% if mod(kk,100)==0;
%    close all;figure;
% end
%     subplot(2,2,1);plot(kk,focus_measure,'or');hold on;title(num2str(kk));
%     subplot(2,2,1);plot(kk,bestfocus,'og');hold on;title(num2str(kk));
%     subplot(2,2,4);plot(kk,ref_d,'o');hold on;title(num2str(kk));
%     subplot(2,2,2);
%     plot(abs_ds,FMs,'ro');hold on;
%     subplot(2,2,2);
%     plot(abs_ds,polyval(p,abs_ds),'-k');
%     plot(Fop,polyval(p,Fop),'og','MarkerSize',10); hold on;
%         
%     subplot(2,2,3);
%     plot(abs_ds,FMs,'ro');hold on;
%     plot(abs_ds,polyval(p,abs_ds),'-r'); hold on;
%     plot(Fop,polyval(p,Fop),'og','MarkerSize',10); 
%     plot(Fop,focus_measure,'*g','MarkerSize',10);
%     try
%             plot(abs_dsp,FMsp,'ko'); hold off;
%     catch
%     end
%     drawnow; 
     FMsp=FMs;
     abs_dsp=abs_ds;

 
end



% % IGNORE
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


