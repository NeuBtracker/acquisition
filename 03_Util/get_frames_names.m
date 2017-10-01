function NamesList = get_frames_names(Path_init, Path_back_from_folder, FolderNames, i)
% This function retrieves the list of images names in the folder
% 'Path_init/FolderNames{i}/', where 'FolderNames' is the list of
% sub-folders of 'Path_init' and 'i' is the index of the sub-folder of
% interest

cd([Path_init, FolderNames{i}]);
ALL_Files = dir('*.tiff');
cd(Path_back_from_folder);

for k = 1:length(ALL_Files)
    NamesList{k} = ALL_Files(k).name;
end

[NamesList, ~] = sort_nat(NamesList);
end