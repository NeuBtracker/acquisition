function void=Preview_most_recent_images(Fluoro_Lim,Refl_Lim)
% Fluoro_Lim=10000;Refl_Lim=100;
h1=figure;axis image;
%set(h1,'doublebuffer','off','color','black')
fi_flag=0;
t_pr=0;
while 1==1
    try
        t_pr=t_pr+1;
        
        [F,R,Fnum,Rnum]=read_most_recent_fluoroANDreflection();
         
        if (exist('F','var')==1) && (exist('R','var')==1);
            if fi_flag==0;
                figure(h1);hh1=subplot(1,2,1);hhh1=imshow(F,[0 Fluoro_Lim]);
                figure(h1);hh2=subplot(1,2,2);hhh2=imshow(R,[0 Refl_Lim]);
                fi_flag=1;
                drawnow;
            else
                set(hhh1,'CData',F);title(hh1,['F' num2str(Fnum)]);
                set(hhh2,'CData',R);title(hh2,['R' num2str(Rnum)]);
                drawnow
            end
        end
             
    catch
        display('aoutch!!!');
    end
end
end