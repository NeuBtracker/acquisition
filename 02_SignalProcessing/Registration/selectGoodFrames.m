function selectGoodFrames(Path_init, Path_back, dataset, subdataset, showProgress, showImages,...
                            countTreshMin, countTreshMax, medFiltSize) 
% This function saves the index of the images showing a number of SURF features between
% 'countTreshMin' and 'countTreshMax'.

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g 'CAD_Fluor' -> containing 
% fluorescence images of the experiment) 

% showProgress is a flag (0/1) to activate a progress bar indicating the
% progress of the task

% showImages is a flag (0/1) to plot the images during the progress of the
% task

% 'medFiltSize' is the size of the median filter applied to the images
% before the feature extraction

% read file names                        
Path_root = [Path_init, dataset, subdataset];
cd(Path_root); 
ALL_Files = dir('*.tif');

for i = 1:length(ALL_Files)
    NamesList{i} = ALL_Files(i).name;
end

cd(Path_back);
[NamesList, ~] = sort_nat(NamesList);

n_frame = size(NamesList,2);
readImage = @read_tiffImage;
imagesNames = NamesList;  


if(showImages)
    figure; colormap gray;
end
good_fr = zeros(n_frame, 1);

if(showProgress)
    progressbar('Selecting good frames')
end

points_count = zeros(n_frame,1);

for  i = 1:1:n_frame

    IM = feval(readImage, Path_root, imagesNames, i);  
    IM_init = IM;
    IM = medfilt2(IM, [medFiltSize medFiltSize]);
    IM = imadjust(IM);

    points = detectSURFFeatures(IM);
    points_count(i) = points.Count;
    
    if ( (points.Count < countTreshMin) || (points.Count > countTreshMax)) 
        if(showImages)
            subplot(1,2,2)
            cla
            imagesc(IM_init); title(['Eliminated frame.'])
        end

    else
        if(showImages)
            subplot(1,2,1)
            cla
            imagesc(IM_init); title(['Current frame. #features ',num2str(points.Count)]); hold on;
            plot(points.selectStrongest(10));
        end
        good_fr(i) = 1;
        
    end
    if(showImages)
        pause(.1)
    end
    
    if(showProgress)
        progressbar(i/n_frame);
    end

end

% save the output stats
good_index = find(good_fr == 1);
File_out = [Path_root, '/index.mat'];
save (File_out, 'good_index');
File_out = [Path_root, '/good_fr.mat'];
save (File_out, 'good_fr');
File_out = [Path_root, '/points_count.mat'];
save (File_out, 'points_count');

