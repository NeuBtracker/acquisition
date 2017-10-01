%% %autofocus.

%% Initialize COM port and Focal Power Mode;
instrhwinfo('serial')
s = serial('COM32');
set(s,'BaudRate',3840);
set(s,'Databits',8);
set(s,'Stopbits',1);
set(s,'Parity','none');

fopen(s);
fprintf(s,'Start') %Handshake
out = fscanf(s)
set(s,'Timeout',0.01);
pause(0.5);
warning off MATLAB:serial:fread:unsuccessfulRead

addpath(genpath('D:\ZT_Matlab\IndivParts\Autofocus'));
%% Initialize MIDI controller.
[controlNum1, deviceName] = midiid;pause(2);
[controlNum2, deviceName] = midiid;pause(2);
[controlNum3, deviceName] = midiid;pause(2);
[controlNum4, deviceName] = midiid;pause(2);

initialControlValues=[0 0 0 0];
midicontrolsObject = midicontrols([controlNum1,controlNum2,...
                                   controlNum3,controlNum4],initialControlValues,'MIDIDevice',deviceName);

                               
                               
%% Go to proper path
cd('I:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
load('I:\NEXT_tform');
cd(path);
tp=num2str(fix(clock));
                               
%% Manual focus.
controlValue=[0 0 0 0];
l_rFFC=0;
l_f2g=0;
kk=0;
s_er=[];
while 1==1
    tic
    kk=kk+1;
   controlValue = midiread(midicontrolsObject);
   aFRC=(controlValue(2)-0.5).*400;
   aFFC=(controlValue(3)-0.5).*40;
   rFFC=(controlValue(4)-0.5).*40;
 
   %Exp with Focal Power
%   aFRC=(controlValue(2)-0.5).*10;   aFFC=(controlValue(3)-0.5).*0.1;   rFFC=(controlValue(4)-0.5).*0.1;
   
   
   if ~(rFFC==l_rFFC) && kk>1
     f2g=aFRC+aFFC+(rFFC-l_rFFC);
    %   display(['Moved Relativly:' num2str(f2g)])
   else f2g=aFRC+aFFC;
    %   display(['Moved To Absoluted:' num2str(f2g)])
   end
   
   if ~(f2g==l_f2g) && kk>1
   [s_er]=set_ETL_current(s, f2g,0); 
  %[s_er]=set_ETL_current(s, f2g,1); 
   end
     
   l_f2g=f2g;
   l_rFFC=rFFC;
   T(kk)=toc;
   
       if mod(kk,50)==0
        fprintf(s,'Start') ;%Handshake
        out = fscanf(s);
    end
end


%% Scanning all Z-for testing
profile clear;
profile on;
kk=0;
fprintf(s,'Start') %Handshake
out = fscanf(s)
clear Er;
all_possible_fmeasures{1}='ACMO';
all_possible_fmeasures{2}='BREN';
all_possible_fmeasures{3}='BREN';
%all_possible_fmeasures{3}='CONT';
all_possible_fmeasures{4}='CURV';
all_possible_fmeasures{5}='CURV';
all_possible_fmeasures{6}='CURV';
%all_possible_fmeasures{5}='DCTE';
%all_possible_fmeasures{6}='DCTR';
all_possible_fmeasures{7}='GDER';
all_possible_fmeasures{8}='GLVA';
all_possible_fmeasures{9}='GLLV';
all_possible_fmeasures{10}='GLVN';
all_possible_fmeasures{11}='GRAE';
all_possible_fmeasures{12}='GRAT';
all_possible_fmeasures{13}='GRAS';
all_possible_fmeasures{14}='HELM';
all_possible_fmeasures{15}='HISE';
all_possible_fmeasures{16}='HISR';
all_possible_fmeasures{17}='LAPE';
all_possible_fmeasures{18}='LAPM';
all_possible_fmeasures{19}='LAPV';
all_possible_fmeasures{20}='LAPD';
all_possible_fmeasures{21}='SFIL';
all_possible_fmeasures{22}='SFRQ';
all_possible_fmeasures{23}='TENG';
all_possible_fmeasures{24}='TENV';
all_possible_fmeasures{25}='VOLA';
all_possible_fmeasures{26}='WAVS';
all_possible_fmeasures{27}='WAVV';
all_possible_fmeasures{28}='WAVR';
kk=0;
  [s_er]=set_ETL_current(s,0,0); 
for f2g=[-200:1:200]
    
    kk=kk+1;
    [s_er]=set_ETL_current(s,f2g,0); 
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    ZSTACK(:,:,kk)=buf2;
      
    for im=1:28
        tic
        AFM(kk,im)=fmeasure(buf2,all_possible_fmeasures{im});
        TM(kk,im)=toc;
    end
    
    
    if mod(kk,30)==0
        fprintf(s,'Start') %Handshake
        out = fscanf(s)
    end
           

% Message=['Ar' char(bin2dec('00000000')) char(bin2dec('00000000')) ];
% fprintf(s,char([Message crc4Optotune(uint16(Message))]));
% out=fscanf(s)
% k=strfind(out,'A');
% try
% D1(kk)=uint16(out(k+1));
% D2(kk)=uint16(out(k+2));
% catch
% end

end
beep
profile viewer
                              
                             clear AFMn;
for im=1:28
   AFMs=medfilt2(AFM,[100,1]); 
   AFMsn(:,im)=(AFMs(:,im)-min(AFMs(:,im)));%./(max(AFMs(:,im))-min(AFMs(:,im)));
   AFMn(:,im)=(AFM(:,im)-min(AFM(:,im)));%./(max(AFM(:,im))-min(AFM(:,im)));
   subplot(5,6,im);plot(AFMn(:,im),'r'); hold on;plot(  AFMsn(:,im),'k');title(all_possible_fmeasures{im});
end

plot(medfilt2(AFMn,[100,1]),'DisplayName','AFMn')


                        
for i=1:5:size(ZSTACK,3)
    imagesc(ZSTACK(:,:,i));drawnow;pause(0.001);
end

%% Autofocus based on Rudnaya 2012 using TENV
%% Grouped

% 
% load('D:\ZT_Matlab\ELT_LUT.mat');
% for i=-200:1:200;
%     i
% f2g=i;
% temp2find_ETL_Pos=(f2g-ETL_Positions);
% [~,mes_index]=min(abs(temp2find_ETL_Pos));
% fprintf(s,ETL_Messages(mes_index,:));
% error_message = fscanf(s)
% pause(0.01);
% flushoutput(s);
% flushinput(s);
% end


f2g=0;
temp2find_ETL_Pos=(f2g-ETL_Positions);
[~,mes_index]=min(abs(temp2find_ETL_Pos));
fprintf(s,ETL_Messages(mes_index,:));

 ref_d=0;
 kk=0;
while 1==1;    
    kk=kk+1;
    Dd=10;
   % rel_ds=[-2.*Dd -Dd 0 1.*Dd +2.*Dd]
    rel_ds=[-30:5:30];
    for i=1:length(rel_ds)
    abs_ds(i)= ref_d+rel_ds(i);
    
    temp2find_ETL_Pos=(abs_ds(i)-ETL_Positions);
[~,mes_index]=min(abs(temp2find_ETL_Pos));
fprintf(s,ETL_Messages(mes_index,:));
flushoutput(s);
flushinput(s);

    [buf2,~]=read_most_recent_fluoroANDreflection();
    focus_measure=fmeasure(buf2,'TENV');
    FMs(i)=focus_measure;
    end
    c=polyfit(abs_ds,FMs,3);     
    Fop=(c(2)./(2.*c(3)));
    ref_d=Fop;
    
    temp2find_ETL_Pos=(ref_d-ETL_Positions);
[~,mes_index]=min(abs(temp2find_ETL_Pos));
fprintf(s,ETL_Messages(mes_index,:)); 

    [buf2,~]=read_most_recent_fluoroANDreflection();
    focus_measure=fmeasure(buf2,'TENV');
    
    subplot(2,1,1);plot(kk,focus_measure,'o');hold on;
    subplot(2,1,2);
    plot(abs_ds,FMs,'ro');hold on;
    plot(abs_ds,polyval(c,FMs),'k');
    drawnow;
    
        if mod(kk,30)==0
        fprintf(s,'Start') %Handshake
        out = fscanf(s)
    end
end





%% Autofocus

profile clear;
profile on;
kk=0;
fprintf(s,'Start') %Handshake
out = fscanf(s)
clear Er;
close all;
% Manually Define optimal focus once;
%   [buf2,~]=read_most_recent_fluoroANDreflection();%M
%     buf2=imresize(buf2,0.1);
%     focus_measure=fmeasure(buf2,'TENV');
%  best_focus=   focus_measure;
%  
[s_er]=set_ETL_current(s,0,0);
f2g=0;
addpath('D:\ZT_Matlab\IndivParts\Autofocus');
while 1==1 
    kk=kk+1
    [s_er]=set_ETL_current(s,f2g,0); 
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    focus_measure=fmeasure(buf2,'TENV');
    focus_level=focus_measure./best_focus;
        
    if 1==1%focus_level<0.9
       %FP2test=[-10 -5 -2.5 2.5 5 10];
      % FP2test=[-20:3:20];
     %  FP2test=[-10 -5 -2.5 -1 -0.5 -0 0.5 1 2.5 5 10].*(1-focus_level).*100;%(focusMeasure./best_focus).*5;
      FP2test=[-5:1:5].*(1-focus_level).*10;%(focusMeasure./best_focus).*5;
      FP2test(FP2test>200)=200;FP2test(FP2test<-200)=-200;
     for ft=1:length(FP2test);
    [s_er]=set_ETL_current(s,FP2test(ft)+f2g,0); 
    error_message = fscanf(s);
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    tested_focuses(ft)= fmeasure(buf2,'TENV');

       end
       FP2testsss=FP2test+f2g;
       smth_tested_focuses=(tested_focuses);
      % smth_tested_focuses=smooth(tested_focuses);
      % plot(FP2test,smth_tested_focuses);drawnow;
    end
    
   [max_focus,max_focus_i]= max(smth_tested_focuses(:));
   f2g=f2g+FP2test(max_focus_i);
   if best_focus<max_focus
       best_focus=max_focus;
   end
   subplot(2,2,1);plot(kk,f2g,'o');hold on;
   subplot(2,2,2);plot(kk,focus_measure,'o');hold on;
   subplot(2,2,3);plot(kk,focus_level,'o');hold on;
   subplot(2,2,4);plot(FP2testsss,smth_tested_focuses);hold on;
   drawnow;
   
       if mod(kk,10)==0
        fprintf(s,'Start') %Handshake
        out = fscanf(s)
    end
end

    
    
%% Mode 2
kk=0;
    kk=kk+1
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    focus_measure_p=fmeasure(buf2,'TENV');
    focus_direction=1;
    focus_step=1;
      best_focus=0;
    close all;
    f2g=0;
while 1==1 
    kk=kk+1
    f2g=f2g;%+focus_direction*focus_step;
    if f2g>200; f2g=200;end
    if f2g<-200; f2g=-200;end
    [s_er]=set_ETL_current(s,f2g,0); 
        [s_er]=set_ETL_current(s,f2g,0); 
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    focus_measure=fmeasure(buf2,'TENV');
    f2g0=f2g;
    for i=1:5;
        f2g0=f2g0+focus_direction*focus_step*i;
    if f2g0>200; f2g0=200;end
    if f2g0<-200; f2g0=-200;end
    [s_er]=set_ETL_current(s,f2g0,0); 
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,0.2);
    afocus_measure(i)=fmeasure(buf2,'TENV');
    af2g(i)=f2g0;
    end
    [~,imax]=max(afocus_measure);
    f2g=af2g(imax);
    pA=polyfit(af2g,afocus_measure,1);
    p=pA(1);
    focus_measure=mean(afocus_measure);
    
    if p<0 || f2g==200 || f2g==-200 %focus_measure<focus_measure_p
       display('change_of_direction');
       focus_direction=focus_direction.*(-1); 
       focus_step=5;%abs(p)%.*(1-focus_measure./best_focus);
       best_focus=max(best_focus,focus_measure);
    end
    
       subplot(2,2,1);plot(kk,f2g,'o');hold on;
   subplot(2,2,2);plot(kk,focus_direction,'o');hold on;
   subplot(2,2,3);plot(kk,p,'o');hold on;
   subplot(2,2,4);plot(kk,focus_measure,'o');hold on;
   drawnow;
   focus_measure_p=focus_measure;
   
   
          if mod(kk,10)==0
        fprintf(s,'Start') %Handshake
        out = fscanf(s)
          end
    
end
    


    
    
                               
%%
clearvars -except s
[s_er]=set_ETL_current(s,0,0); 
kk=0;
g2f=0;
while 1==1 
   kk=kk+1;
   nn=0;
    for i=-20:1:20
        nn=nn+1;
        [s_er]=set_ETL_current(s,g2f+i,0); 
        display(num2str(g2f+i));
        n_fp(nn)=g2f+i;
     %   pause(0.1);
        [buf2,~]=read_most_recent_fluoroANDreflection();%M
        buf2=imcrop(buf2,[100 100 400 400]);
        buf2(buf2<200)=0;
        buf2=imresize(buf2,0.5);
       %buf2=medfilt2(buf2,[2 2]);
        n_fm(nn)=fmeasure(buf2,'TENV');
    end
   n_fm=ordfilt2(n_fm,1,ones(3,1)');
    [a,imax]=max(n_fm);
    g2f=n_fp(imax);
    
      if mod(kk,5)==0
        fprintf(s,'Start') %Handshake
        out = fscanf(s)
     %   g2f=0;
      end
      
      if g2f<-200; g2f=-150; end
      if g2f>200; g2f=150; end
          
      subplot(1,2,1);plot(kk,g2f,'o');hold on;
      subplot(1,2,2);plot(n_fp,n_fm,'o');drawnow; hold on;
end
       
        
        
        
    
    


%%
while 1==1
    tic
kkk=kkk+1;
    %% Mouse Clicking Override
    %tic
    m_o_ex=0;
    try        
        fileID = fopen('MouseOveride','r');MouseCord=fread(fileID,[2,3],'uint16');fclose(fileID);             
        m_o_ex=1;
    catch
    end
   %E(1,kkk)=toc;
   %tic
    if m_o_ex==1;
        
    end
%        %E(2,kkk)=toc;

% %     %% Joys%tic_Overide (Button1 must stay pressed),
% %     %tic
% %     [axes, buttons, povs] = read(joy);
% %     if buttons(1)==1
% %         xValue = +axes(2)*10;
% %         yValues = -axes(1)*10;
% %         outputSingleScan(galvo_handle,[xValue yValues]);
% %         %display(['Joys%tick' datestr(datetime('now'))]);
% %         continue
% %     end
% %      %E(3,kkk)=toc;
% %     %% Image Difference Based Tracking
% %     %tic
    k=k+1;
    [~,IM2]=read_most_recent_fluoroANDreflection();

%% main loop

t=0;
buf2 = zeros(width,height,'uint16');

k1=0;
set_ETL_current(s, 0);
previews_current=0;
direction=1
while 1==1;
    k1=k1+1;
%while t<500  

    t=t+1
    [rc] = AT_QueueBuffer(hndl,imagesize);
    [rc] = AT_Command(hndl,'SoftwareTrigger');
    [rc,buf] = AT_WaitBuffer(hndl,1000);
    [rc,buf2] = AT_ConvertMono12ToMatrix(buf,height,width,stride);
    time_stmp=datestr(datetime('now'),'yymmddHHMMSSFFF');
  %  imagesc((((buf2))));colorbar; title(num2str(max(buf2(:) ))); drawnow; 
  %  imwrite(fliplr((uint16(buf2))), ['F_' num2str(t) '.tiff'] );
  
  if k1>1
      
    DH1 = buf2;
    DV1 = buf2;
    
       
    DH=DH1(1:end-3,1:end-3)-DH1(4:end,1:end-3);
    DV=DV1(1:end-3,1:end-3)-DV1(1:end-3,4:end);
    FM=max(DH,DV);
    focusMeasure = mean(mean((FM)))
    ALL_F_M(k1)=focusMeasure;
     
  
       if new_current==-250
           direction=1;
       elseif new_current==250
           direction=-1;
       end
       if focusMeasure>=pr_focs
           direction=1;
       elseif focusMeasure<pr_focs
           direction=-1;
       end

      step=3;
  new_current=previews_current+(step*direction);
  set_ETL_current(s, new_current)
  previews_current=new_current;
  
  All_ETL(k1)=new_current;
    
  pr_fr=buf2;
  pr_focs=(focusMeasure+pr_focs)./2;
  subplot(4,2,1:4);imagesc(buf2);axis image; axis off;
  subplot(4,2,5:6);plot(k1,ALL_F_M(k1),'or');hold on; 
  subplot(4,2,7:8);plot(k1,All_ETL(k1),'og');hold on;
  drawnow;
  end
  

end
  






disp('Acquisition complete');
[rc] = AT_Command(hndl,'AcquisitionStop');
AT_CheckWarning(rc);
[rc] = AT_Flush(hndl);
AT_CheckWarning(rc);
[rc] = AT_Close(hndl);
AT_CheckWarning(rc);
[rc] = AT_FinaliseLibrary();
AT_CheckWarning(rc);
disp('Camera shutdown');



