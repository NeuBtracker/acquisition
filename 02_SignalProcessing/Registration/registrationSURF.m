function registrationSURF(Path_init, Path_back, dataset, subdataset, showProgress, showImages,...
                            saveImages, saveStats, medFiltSize, batchSize, firstbatchSize)
% This function splits the 'subdataset' into several batches. In every batch the images are 
% registered (using SURF features matching) to the batch template. The batch template is the first
% image of the batch folder. A new batch is formed when the size of the previous one was exceeded 
% (batchSize) and an image with high number of features makes for the
% template.

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g 'CAD_Fluor' -> containing 
% fluorescence images of the experiment) 

% 'showProgress' is a flag (0/1) to activate a progress bar indicating the
% progress of the task

% 'showImages' is a flag (0/1) to plot the images during the progress of the
% task

% 'saveImages' is a flag (0/1) to save the transformed images in batch
% folders

% 'saveStats' is a flag (0/1) to save the statistics derived from the task 

% 'medFiltSize' is the size of the median filter applied to the images
% before the feature extraction   

% 'batchSize' is the size of the batches 

% 'firstbatchSize' is the size of the first batch, ususally smaller
% then 'batchSize', if the first batch template is the first image in the dataset 

%% SURF Registration

Path_root = [Path_init, dataset, subdataset];
initFrame = 1;

% stats
stats = struct('filename',{},'feat_detected',{},'reg_status',{},'feat_matched',{},...
    'scale',{},'rot',{},'trans_X',{},'trans_Y',{},'used',{},'SSD',{},...
    'focus',{},'coord_x',{},'coord_y',{}, 'speed',{},'istemplate',{});
         
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

File_out = [Path_root, '/index.mat'];
load(File_out);

if(showImages)
    figure; colormap gray;
end

IM = feval(readImage, Path_root, imagesNames, good_index(initFrame));
IM_init = IM;

IM = imadjust(IM);
IM = medfilt2(IM, [medFiltSize medFiltSize]);
   
sumFeatures = 0;
it = 0;
saveDir = [Path_init, dataset, subdataset,'_Batches/', subdataset, '_',num2str(initFrame)];

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

if(showProgress)
    progressbar('1st Quality check + Computing Stats')
end

for k = initFrame:1:length(good_index)-1

    it = it + 1;
    if(showProgress)
        progressbar((k - initFrame + 1)/length(good_index));
    end
    
    IM_o = feval(readImage, Path_root, imagesNames, good_index(k));
    IM_o_init = IM_o;
 
    IM_o = medfilt2(IM_o, [medFiltSize medFiltSize]);
    IM_o = imadjust(IM_o);

    if(((it > firstbatchSize)) && ptsDistorted.Count > meanNoFeatures ) 
        firstbatchSize = batchSize;
       
        IM = IM_transformed;
        IM_init = IM;
        IM = imadjust(IM);
        IM = medfilt2(IM, [medFiltSize medFiltSize]);
        
        saveDir = [Path_init, dataset, subdataset,'_Batches/', subdataset, '_',num2str(k)];
        if ~exist(saveDir,'dir')
                mkdir(saveDir)
        end
        
        stats(k - initFrame + 1).istemplate = 1;
        it = 0;
        sumFeatures = 0;
     
    end 
    
    f_measure = fmeasure(IM_o, 'BREN');
    stats(k - initFrame + 1).focus = f_measure;
    stats(k - initFrame + 1).istemplate = 0;
    if(k == initFrame)
        stats(k - initFrame + 1).istemplate = 1;
    end

    [tform, status, ptsOriginal, ptsDistorted, matchedPtsOriginal, matchedPtsDistorted, ssd_metric]...
                                 = featuresMatching(IM, IM_o);
    
    if(k == 1)
        IM_transformed = IM_init;
    end

    
    stats(k - initFrame + 1).reg_status = status;
    stats(k - initFrame + 1).filename = imagesNames{good_index(k)}(1:19);
    stats(k - initFrame + 1).feat_detected = ptsDistorted.Count;
    stats(k - initFrame + 1).feat_matched = matchedPtsDistorted.Count;
    stats(k - initFrame + 1).SSD = mean(ssd_metric)/4;
    
    if(status == 1 || status == 2)
        
        stats(k - initFrame + 1).scale = 0;
        stats(k - initFrame + 1).used = 0;
        stats(k - initFrame + 1).rot = 0;
        stats(k - initFrame + 1).trans_X = 0;
        stats(k - initFrame + 1).trans_Y = 0;
    end
    
    
    if(status == 0)
        
        sx = norm(tform.T(1:2,1));
        sy = norm(tform.T(1:2,2));            
        stats(k - initFrame + 1).scale = sx;
        
        trans_noScale = tform.T;
        trans_noScale(1:2,1) = trans_noScale(1:2,1)/sx;
        trans_noScale(1:2,2) = trans_noScale(1:2,2)/sy;
        tform.T = trans_noScale;
        
        rot = rad2deg(atan2(tform.T(2,1),tform.T(1,1)));
        trans_X = tform.T(3,1);
        trans_Y = tform.T(3,2);
       
        stats(k - initFrame + 1).rot = rot;
        stats(k - initFrame + 1).trans_X = trans_X;
        stats(k - initFrame + 1).trans_Y = trans_Y;        
        stats(k - initFrame + 1).used = 1;
               
        if(abs(1-sx) > 0.1)
            stats(k - initFrame + 1).used = 0;
            continue
        end
               
        IM_transformed = imwarp(IM_o_init,tform, 'OutputView', imref2d(size(IM_o_init)));
        
    % plot results
    if(showImages)
        plotRegStatus(IM_init, IM_o_init, IM_transformed, ptsOriginal, ptsDistorted, matchedPtsOriginal,...
            matchedPtsDistorted, status);     
    end
          
        if(saveImages)
            if ~exist(saveDir,'dir')
                mkdir(saveDir)
            end            
            imwrite(uint16(IM_transformed), [saveDir,'/' imagesNames{good_index(k)}(1:19) '.tiff']);
        end

    end
   
    % update reference image
    sumFeatures = sumFeatures + ptsDistorted.Count;
    meanNoFeatures = sumFeatures / it;

end

if(saveStats)
    if ~exist([Path_init, dataset, subdataset,'_Stats'],'dir')
        mkdir([Path_init, dataset, subdataset,'_Stats'])
    end
    File_out = [Path_init, dataset, subdataset,'_Stats/stats.mat'];
    save (File_out, 'stats');
end
