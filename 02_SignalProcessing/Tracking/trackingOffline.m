function trackingOffline(Path_init, dataset, subdataset, showProgress, showImages, recordVideo,...
                    mean_offset, stack_size, ci)
% This function performs tracking of the fish. The images in 'subdataset' folder are
% split into stacks of given size. One suck stack is processed at a time.
% The mean image of the stack is computed as an average image over every
% 'mean_offset'_th in the stack. The black and white output images are
% saved together with the statistics derived from the task.

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g 'CAD_Refl' -> containing 
% reflection images of the experiment) 

% 'showProgress' is a flag (0/1) to activate a progress bar indicating the
% progress of the task

% 'showImages' is a flag (0/1) to plot the images during the progress of the
% task

% 'recordVideo' is a flag (0/1) to create a video of the progress of the task              

% 'mean_offset' is the step used to compute the mean image

% 'stack_size' is the size of the stack being processed

% 'ci' is a vector containing the arena dimensions: ci = [c_x, c_y, r].
% c_x, c_y are the coordinates of the center of the arena, r is the radius 
% of the arena

%% Tracking

Path_root = [Path_init, dataset, subdataset];
out_folder = [Path_root, '_BW/'];
stats_folder = [Path_root, '_Stats/'];

if ~exist(out_folder,'dir')
    mkdir(out_folder)
end

if ~exist(stats_folder,'dir')
    mkdir(stats_folder)
end
    
% loading list of R-frames 
name_str = 'R_r_*';    
if ~exist([Path_root,'/LIST_R.mat'],'file')
    LIST_R = file2List([Path_root, '/'], name_str);
    save([Path_root,'/LIST_R.mat'],'LIST_R')
else
    load([Path_root,'/LIST_R.mat'],'LIST_R')    
end

n_frame = length(LIST_R);    
readImage = @read_binImage;
imagesNames = LIST_R;    
clear LIST_R;

if(showProgress)
    progressbar('Offline tracking')
end

IM = feval(readImage, Path_root, imagesNames, 1);
[m, n] = size(IM);
mean_im = zeros(m, n);

% compute mean over dataset

count = 0;
for i = 1:mean_offset:n_frame
    
    IM = feval(readImage, Path_root, imagesNames, i);
    image = im2double(IM);
    mean_im = mean_im +  image;
    count = count + 1;
   
end
mean_im = mean_im / count;
 
% subtract mean image from all the frames

off_coords = struct('filename',{},'Coord_X',{},'Coord_Y',{},...
'orientation',{},'long_ax',{}, 'short_ax',{});

stack = zeros(m ,n , stack_size);

count = 0;
init_frame = 1;

for i = init_frame:1:n_frame
            
    if(showProgress)
        progressbar(i/n_frame);
    end
    count = count + 1;  
    IM = feval(readImage, Path_root, imagesNames, i);
    image = im2double(IM);
    image = image - mean_im;
    stack(:,:,count) =  image;
    
    if (mod(count, stack_size) == 0 || i == n_frame)
        count = 0;
        [stack_proc, X_Coord, Y_Coord, phi, long_axis, short_axis] = processStack(stack,...
                                mean_im, recordVideo, showImages, ci);
        for j = 1:1:size(stack,3)
            index = i-size(stack,3) + j;
            off_coords(index).filename = imagesNames(index).name;
            if(~isempty(stack_proc(:,:,j)))
                imwrite((stack_proc(:,:,j)), [out_folder, imagesNames(index).name '.png']);
            end
            
            off_coords(index).Coord_X = X_Coord(j);
            off_coords(index).Coord_Y = Y_Coord(j);
            off_coords(index).orientation = phi(j);
            off_coords(index).long_ax = long_axis(j);
            off_coords(index).short_ax = short_axis(j);            
        end
        
        if (n_frame - i > stack_size)
            stack = zeros(m ,n , stack_size);
        else
            stack = zeros(m ,n , n_frame - i);
        end
    end
    
end
File_out = [stats_folder,'/off_coords.mat'];
save (File_out, 'off_coords');