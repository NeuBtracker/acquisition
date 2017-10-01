function registerTemplates(Path_init, Path_back, dataset, subdataset, saveImages, max_it)
% This function performes mutual information based registration. The images in the 
% fine batch folders obtained with registrationMI routine, are registered to the global template. 

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset/subdataset/'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g
% 'CAD_Bathches/' -> containing subsequent batches obtained from
% registrationMI routine

% 'saveImages' is a flag (0/1) to save the transformed images in corresponding batch
% folders

% 'max_it' is the number of iterations the optimizer of Matlab built-in
% imregconfig takes

%% MI registration to global template

readImage = @read_tiffImage;
Path_root = [Path_init, dataset, subdataset];
Path_back_from_folder = ['../', Path_back];

cd(Path_root);
ALL_Folders = dir(['Fine*']);
cd(Path_back);


for i = 1:length(ALL_Folders);
    FolderNames{i} = ALL_Folders(i).name;
end

[FolderNames, ~] = sort_nat(FolderNames);


[optimizer, metric] = imregconfig('multimodal');
       optimizer.InitialRadius = 0.0007;
       optimizer.Epsilon = 1.5e-4;
       optimizer.GrowthFactor = 1.01;
       optimizer.MaximumIterations = max_it;
       metric.NumberOfSpatialSamples = 2000;
       
% pick the template of the first batch as global template       
NamesList1 = get_frames_names(Path_root, Path_back_from_folder, FolderNames,1);
IM = feval(readImage, [Path_root, FolderNames{1}], NamesList1, 1);

      
%% register
for i = 1:length(FolderNames);
    
    NamesList2 = get_frames_names(Path_root, Path_back_from_folder, FolderNames, i);
    IM_o = feval(readImage, [Path_root, FolderNames{i}], NamesList2, 1);

    [~, ~, tform] = imregister2(IM_o, IM, 'rigid', optimizer,metric);

    if(saveImages)
        for k = 1:size(NamesList2,2)

            image = feval(readImage, [Path_root, FolderNames{i}], NamesList2, k);
            image_transformed = imwarp(image, tform, 'OutputView', imref2d(size(image)));
            imwrite(uint16(image_transformed), [Path_root, FolderNames{i}, '/', NamesList2{k}]);
        end
    end
    
end



