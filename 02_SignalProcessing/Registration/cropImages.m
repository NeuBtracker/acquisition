function cropImages(Path_init, Path_back, dataset, subdataset, saveImages, width, len)
% This function crops [len x width] pixels of the images in 'subdataset' folders, around a manual input point 

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset/subdataset/'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g
% 'CAD_Bathches/' -> containing subsequent batches obtained from
% registrationSURF routine

% 'saveImages' is a flag (0/1) to save the cropped images in corresponding
% batch folders

% 'width' is the width of the images after cropping

% 'len' is the length of the images after cropping

%% crop images:

readImage = @read_tiffImage;
Path_root = [Path_init, dataset, subdataset];
Path_back_from_folder = ['../',Path_back];

cd(Path_root);
ALL_Folders = dir([ subdataset(1:3),'*']);
cd(Path_back);

for i = 1:length(ALL_Folders)
    FolderNames{i} = ALL_Folders(i).name;
end
[FolderNames, ~] = sort_nat(FolderNames);

for i = 1:length(FolderNames)
    
    figure; colormap gray;
    NamesList1 = get_frames_names(Path_root, Path_back_from_folder, FolderNames, i);
    
    saveDir = [Path_init, dataset, subdataset, 'Cropped_' ,FolderNames{i}];
    if ~exist(saveDir,'dir')
        mkdir(saveDir)
    end
    
    IM = feval(readImage, [Path_root, FolderNames{i}], NamesList1, 1);
    imagesc(IM);
    [minx, miny] = ginput(1);
    
    rect = [minx miny width len];

%     figure; colormap gray
    IM_cropped = imcrop(IM, rect);
    
%     imagesc(IM_cropped);
    
    for k = 1:size(NamesList1,2)

        IM_o = feval(readImage, [Path_root, FolderNames{i}], NamesList1, k);
        IM_cropped = imcrop(IM_o, rect);
        image_cropped = zeros(len + 1, width + 1);
        image_cropped(1:size(IM_cropped,1), 1:size(IM_cropped,2)) = IM_cropped;
        
        
        if(saveImages)
            imwrite(uint16(image_cropped), [saveDir, '/', NamesList1{k}]);
        end
        
    end
    
end


