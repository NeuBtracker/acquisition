function registrationMI(Path_init, Path_back, dataset, subdataset, showProgress, saveImages, max_it)
% This function performes mutual information based registration. The images in the 
% cropped batch folders obtained with cropImages routine, are registered to the batch template. 

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset/subdataset/'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g
% 'CAD_Bathches/' -> containing subsequent batches obtained from
% cropImages routine

% 'showProgress' is a flag (0/1) to activate a progress bar indicating the
% progress of the task

% 'saveImages' is a flag (0/1) to save the transformed images in corresponding batch
% folders

% 'max_it' is the number of iterations the optimizer of Matlab built-in
% imregconfig takes

%% MI registration 

readImage = @read_tiffImage;
Path_root = [Path_init, dataset, subdataset];
Path_back_from_folder = ['../',Path_back];

cd(Path_root);
ALL_Folders = dir(['Cropped*']);
cd(Path_back);

for i = 1:length(ALL_Folders)
    FolderNames{i} = ALL_Folders(i).name;
end

[FolderNames, ~] = sort_nat(FolderNames);

[optimizer, metric] = imregconfig('multimodal');
       optimizer.InitialRadius = 0.0007;
       optimizer.Epsilon = 1.5e-4;
       optimizer.GrowthFactor = 1.01;
       optimizer.MaximumIterations = max_it;
       
if(showProgress)
    progressbar('MI intra-batch registration')
end

for i = 1:length(FolderNames)

    saveDir  = [Path_root, 'Fine_',FolderNames{i}, '/'];   
    NamesList1 = get_frames_names(Path_root, Path_back_from_folder, FolderNames, i);
    IM = feval(readImage, [Path_root, FolderNames{i}], NamesList1, 1);

    for k = 1:size(NamesList1,2)
 
        IM_o = feval(readImage, [Path_root, FolderNames{i}], NamesList1, k);
        IM_o_init = IM_o;

        [~, ~, tform] = imregister2(IM_o,IM,'rigid',optimizer,metric);
        image_transformed = imwarp(IM_o_init, tform,'OutputView', imref2d(size(IM_o_init)));

        if(saveImages)
            if ~exist(saveDir,'dir')
                mkdir(saveDir)
            end
            imwrite(uint16(image_transformed), [saveDir, NamesList1{k}]);
        end   
        
    end
    if(showProgress)
            progressbar(i/length(FolderNames));
    end
    
end
