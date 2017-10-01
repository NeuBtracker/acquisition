function [stack_proc, X_Coord, Y_Coord, phi, long_axis, short_axis]= processStack(stack,...
                        mean_im, recordVideo, plot_flag, ci)
% This function processes the 'stack' of images in order to track the head 
% of the fish in every frame. 
 
%% Input:

% 'stack' is a matrix of size [im_row, im_col, stack_size] containing
% stack_size 'im_row x im_col' images. 

% 'mean_im' is the averaged image over the stack

% 'recordVideo' is a flag (0/1) to create a video of the progress of the task   

% 'plot_flag' is a flag (0/1) to plot the images during the progress of the
% task

% 'ci' is a vector containing the arena dimensions: ci = [c_x, c_y, r].
% c_x, c_y are the coordinates of the center of the arena, r is the radius 
% of the arena

%% Output:

% 'stack_proc' is the obtained black&white version of the input 'stack'

% 'X_Coord' is a vector containing the x coordinates of the center of the
% detected blob, for all the images in the stack

% 'Y_Coord' is a vector containing the y coordinates of the center of the
% detected blob, for all the images in the stack

% 'phi' is a vector contaning the orientation of the fish in every frame

% 'long_axis'/'short_axis' are the axis of the ellipsoid fitted to the
% detected blob

%% Process stack

stack_filtered = imboxfilt3(stack, [1, 1, 5], 'Padding', 'replicate'); 
stack_proc = zeros(size(stack_filtered));

if(plot_flag)
    figure; colormap gray
end

if(recordVideo)
    v = VideoWriter([ 'tracking.avi']);
    v.FrameRate = 20;
    v.Quality = 50;
    open(v);
end

count = 0;
X_Coord = zeros(1,size(stack,3)); 
Y_Coord = zeros(1,size(stack,3));
phi = zeros(1,size(stack,3));
long_axis = zeros(1,size(stack,3));
short_axis = zeros(1,size(stack,3));
for i = 1:size(stack,3)
    count = count + 1;
    
    [im, band_im] = butterworthbpf(stack_filtered(:,:,i),2,50,4);
    if(plot_flag)
        subplot(2,2,1)
        imagesc(stack(:,:,i) + mean_im ); title(['original']); colormap gray
        
        subplot(2,2,2)
        imagesc(stack(:,:,i)); title(['after mean subtraction and z filtered ']); colormap gray

        subplot(2,2,3)
        imagesc(band_im); title(['band filtered']); colormap gray
    end
    im = cropArena(im, ci);

    stack_proc(:,:,i) = im;
    Coord = mask2Cetroid(im);
    x = Coord(1);
    y = Coord(2);
    X_Coord(i) = x;
    Y_Coord(i) = y;
    
    [points_x, points_y] = find(im == 1);
    
    if(plot_flag)
        subplot(2,2,4)
        imagesc(im); colormap gray
        hold on
        
        plot(x, y, '*');
        hold on
        ellipse_t = fit_ellipse( points_y, points_x, gca);
        title(['detected blob']); 
        pause(.1);
    else
        ellipse_t = fit_ellipse( points_y, points_x);
    end
    
    if(strcmp(ellipse_t.status, ''))
        angle = atand(sin(ellipse_t.phi)/cos(ellipse_t.phi)); 
        long_a = ellipse_t.long_axis;
        short_a = ellipse_t.short_axis;
    else
        angle = NaN;
        long_a = NaN;
        short_a = NaN;
    end
    
    phi(i) = angle;
    long_axis(i) = long_a;
    short_axis(i) = short_a;
    
    if (recordVideo)
        set(gcf, 'Position', get(0,'Screensize'));
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
   
end
if (recordVideo)
    close(v);
end
