cd('I:\');
fileID = fopen('Path2SaveNextExperiment','r');path=fscanf(fileID,'%s');fclose(fileID);
load('I:\NEXT_tform');
cd(path);
tp=num2str(fix(clock));
save(['XYtransformMatrix'  num2str(tp)],'mytform')
joy = vrjoystick(1);


%% Initialiye Galvos
devices = daq.getDevices;galvo_handle = daq.createSession('ni');
addAnalogOutputChannel(galvo_handle,'Dev1',0,'Voltage');
addAnalogOutputChannel(galvo_handle,'Dev1',2,'Voltage');
galvo_handle.Rate = 8000;

[~,IM1]=read_most_recent_fluoroANDreflection();%M
size_R=size(IM1);%
try
    ROI=imread('CurrentROI.jpg');
catch
    ROI=ones(size_R);
end
IM1=double(IM1);%.*double(ROI);


%[Mask_logic]=F_IM2ArnaMask_112(IM,0,'ell_sep');
%handles.Mask=Mask_logic;

% Hint: get(hObject,'Value') returns toggle state of Tracking_Preview_tbtn
k=0;COORD=[];
Xg=0;Yg=0;
display('Tracking Started')
%profile on
while 1==1

    %% Mouse Clicking Override
    m_o_ex=0;
    try        
        fileID = fopen('MouseOveride','r');MouseCord=fread(fileID,[2,3],'uint16');fclose(fileID);
                movefile('MouseOveride',['MouseOveride_' datestr(datetime('now'),'yymmddHHMMSSFFF')])

        m_o_ex=1;
    catch
    end
    if m_o_ex==1;
        yA=MouseCord(1,2);xA=MouseCord(1,1);
        [Xm, Ym]= tformfwd(mytform, xA, yA); %%
        if Ym>10; Ym=10; end
        if Xm>10; Xm=10; end
        if Ym<-10; Ym=-10; end
        if Xm<-10; Xm=-10; end
        outputSingleScan(galvo_handle,[Xm Ym]);
        display(['Mouse' datestr(datetime('now'))]);
       % display('overide!')
        continue
    end
    
    %% Joystic_Overide (Button1 must stay pressed)
    [axes, buttons, povs] = read(joy);
    if buttons(1)==1
        xValue = +axes(2)*10;
        yValues = -axes(1)*10;
        outputSingleScan(galvo_handle,[xValue yValues]);
        %display(['Joystick' datestr(datetime('now'))]);
        continue
    end
    
    %% Image Difference Based Tracking
    k=k+1;
    [~,IM2]=read_most_recent_fluoroANDreflection();%M
    IM2=double(IM2);%.*double(ROI);
    
    if ~(size(IM1)==size(IM2));
        continue;
    end
    size_R=size(IM2);%M
    
    ill_type='trasmit';    %ill_type='reflex';
    npxl_min=60;
    nsig_bin=6;
    blur_fact=2;
    pl=0;
    [Coord_diff,Coord_f,Coord_i,Imdif] =...
        F_IMdif2Coord_102(IM1, IM2, pl, blur_fact, nsig_bin, npxl_min, ill_type);
    Coord=Coord_i;
    % COORD=[COORD;Coord];  %M
    
    xA=Coord(2);
    yA=Coord(1);
    
    %         imagesc(Imdif);colorbar;hold on;
    %     plot(yA,xA,'-or','MarkerSize',10);drawnow;
    
    [Xt, Yt]= tformfwd(mytform, yA, xA); %%
    
    
    fileID = fopen('TrackingXYimage_current','w');fwrite(fileID,uint16([yA xA]),'uint16');fclose(fileID);
    
    plot(Coord_diff(1),Coord_diff(2),'o');xlim([-10 10]);
    ylim([-10 10]);hold on; drawnow;
    if (abs(Xt-Xg)>0.05 || abs(Yt-Yg)>0.05) & ~(Coord_diff==([0,0])) %If tracked (XY) away from galvo move galvos to new position
        Xg=Xt; Yg=Yt;
        if Yg>10; Yg=10; end
        if Xg>10; Xg=10; end
        if Yg<-10; Yg=-10; end
        if Xg<-10; Xg=-10; end
        %%
        outputSingleScan(galvo_handle,[Xg Yg]);
        
        
           fileID = fopen('GalvoXYpos','a');
    fprintf(fileID,'%.1f \t %.1f \t %.3f \t %.3f \t %.3f \t %.3f \t %4.0f \t %2.0f \t %2.0f \t %2.0f \t %2.0f \t %2.6f\n',[yA xA Xt Yt Xg Yg clock]);
    fclose(fileID);
        
        [Xgi, Ygi]= tforminv(mytform, Xg, Yg);
        %tic
        fileID = fopen('TrackingXYgalvo','w');fwrite(fileID,uint16([Xgi Ygi]),'uint16');fclose(fileID);
        %toc
        
        %display(['Xt:' num2str(Xt,4) 'Y:' num2str(Yt,4) ...
        %        'Xg:' num2str(Xg,4) 'Yg:' num2str(Yg,4)  'Time:' datestr(datetime('now')) '\n']);
        
    end
    IM1=IM2;
end
clear galvo_handle