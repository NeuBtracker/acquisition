function mergeBatches(Path_init, Path_back, dataset, subdataset, saveImages)

% This function performes mutual information based registration. The images in the 
% fine batch folders obtained with registrationMI routine, are registered to the global template. 

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset/subdataset/'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g
% 'CAD_Bathches/' -> containing subsequent batches obtained from
% registrationTemplates routine

% 'saveImages' is a flag (0/1) to merge the previously registered images
% (in batch folders) into a 'Final_Reg' folder.

%% merge the batches 

readImage = @read_tiffImage;
Path_root = [Path_init, dataset, subdataset];
Path_back_from_folder = ['../', Path_back];

cd(Path_root);
ALL_Folders = dir(['Fine*']);
cd(Path_back);

for i = 1:length(ALL_Folders)
    FolderNames{i} = ALL_Folders(i).name;
end

[FolderNames, ~] = sort_nat(FolderNames);
saveDir = [Path_init, dataset, 'FinalReg','/'];

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

for i = 1:length(FolderNames)

    NamesList1 = get_frames_names(Path_root, Path_back_from_folder, FolderNames, i);
    
    for k = 1:size(NamesList1,2)

        image = feval(readImage, [Path_root, FolderNames{i}], NamesList1, k);
        if(saveImages)
            imwrite(uint16(image), [saveDir, NamesList1{k}]);
        end
        
    end   
    
end