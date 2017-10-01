%%
clc;clear;close;
addpath(genpath('D:\ZT_Matlab\IndivParts'));
cd('K:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
%load('I:\NEXT_tform');
cd(path);

tp=num2str(fix(clock));
err=writeValue4ETL(0);   
[~,cmdout] = dos([...
            'python D:\ZT_Matlab\IndivParts\ETL_pythonP\ETL_looped_reading_file.py ' num2str(0) '&']  )
       
close all; figure;
ref_d=0;
kk=0;
profile clear
profile on;


profile clear;
profile on;
kk=0;
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
      [s_er]=writeValue4ETL(0); 
      kk=0;
for f2g=[-200:1:200]
    
    kk=kk+1;
    [s_er]=writeValue4ETL(f2g); 
    pause(0.05);
    [buf2,~]=read_most_recent_fluoroANDreflection();%M
    buf2=imresize(buf2,1);
    ZSTACK(:,:,kk)=buf2;
      
    for im=1:28
        tic
        AFM(kk,im)=fmeasure(buf2,all_possible_fmeasures{im});
        TM(kk,im)=toc;
    end
    
    

end
beep
profile viewer
                              
   close all                         
for im=1:28
   AFMs=medfilt2(AFM,[100,1]); 
  AFMsn(:,im)=(AFMs(:,im)-min(AFMs(:,im)))./(max(AFMs(:,im))-min(AFMs(:,im)));
   AFMn(:,im)=(AFM(:,im)-min(AFM(:,im)))./(max(AFM(:,im))-min(AFM(:,im)));
   subplot(5,6,im);plot(AFM(:,im),'r'); 
   hold on;plot(  AFMsn(:,im),'k');
   title(all_possible_fmeasures{im});
end

figure;
for im=1:28
   AFMs=medfilt2(AFM,[100,1]); 
   AFMsn(:,im)=(AFMs(:,im)-min(AFMs(:,im)))%./(max(AFMs(:,im))-min(AFMs(:,im)));
   %./(max(AFM(:,im))-min(AFM(:,im)));
   subplot(5,6,im);plot(diff(AFMn(:,im)),'r'); 
  hold on;plot(  AFMsn(:,im),'k');title(all_possible_fmeasures{im});
end
