function registrationDFT(Path_init, Path_back, dataset, subdataset, saveImages, showProgress, usfac)
% This function performes crosscorrelation based registration. The images 
% in 'Path_init/dataset/FinalReg/' are registered to the global template.
% The transformed images together with the derived statistics are stored.

%% Input:

% 'Path_init' is the path to the folder containing the dataset (e.g. 'path_2_data/Data/')

% 'Path_back is the path to the script location relative to 'Path_init/dataset'

% 'dataset' is the folder name of the data set of interest (e.g.'CAD/' ->  a data set for cadaverine experiment)

% 'subdataset' is the sub-folder of interest inside 'dataset' (e.g 'CAD_Fluor' -> containing 
% fluorescence images of the experiment) 

% 'saveImages' is a flag (0/1) to save the transformed images

% 'showProgress' is a flag (0/1) to activate a progress bar indicating the
% progress of the task

% 'usfac' is the upsampling factor required in dftregistration routine.

readImage = @read_tiffImage;
Path_root = [Path_init, dataset];
folder = [Path_root, 'FinalReg/'];

cd(folder); 
ALL_Files = dir('*.tiff');

for i = 1:length(ALL_Files);
    NamesList{i} = ALL_Files(i).name;
end
cd(Path_back); 

err = struct('filename',{},'error',{});

if(showProgress)
    progressbar('Fine registration -> DFT')
end

% pick template
template = feval(readImage, folder, NamesList, 1);

saveDir  = folder;
saveDir_error  = [Path_root, subdataset, '_Stats/'];
if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

for j = 1:size(NamesList,2)

     IM_o_init = feval(readImage, folder, NamesList, j);
     [output, image_transformed] = dftregistration(fft2(im2double(template)),fft2(im2double(IM_o_init)),usfac);

     err(j).filename = NamesList{j};
     err(j).error = output(1);

    if(saveImages)
        A = (abs(ifft2(image_transformed)));
        imwrite(im2uint16(A), [saveDir, NamesList{j}]);
    end
    
    if(showProgress)
        progressbar(j/size(NamesList,2));
    end

end
File_out = [saveDir_error,'/err_dft.mat'];
save (File_out, 'err');

