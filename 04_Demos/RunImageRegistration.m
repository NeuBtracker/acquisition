%%%%%%%%%%%%%%%%%%%%% Run Image Registration Pipeline %%%%%%%%%%%%%%%%%%%%%

% path to helper functions
addpath(genpath('../'));

% path to data set
Path_init = '../../Data/';
Path_back = '../../../Code/Demos';
dataset  = 'CAD/';
subdataset = 'CAD_Fluor';

% display options
showProgress = 1;
showImages = 0;

% save options
saveImages = 1;
saveStats = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% first quality check step -> discard images with too low/high SURF features detected

medFiltSize = 7;        % size of the median filter 
countTreshMin = 30;     % lower threshold for the number of detected features
countTreshMax = 140;    % upper threshold for the number of detected features

selectGoodFrames(Path_init, Path_back, dataset, subdataset, showProgress, showImages,...
                            countTreshMin, countTreshMax, medFiltSize);
close all;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% second quality check -> split data set into batches and perform feature 
%% matching based registration to batch template

medFiltSize = 5;        % size of the median filter 
batchSize = 100;        % size of the batches
firstbatchSize = 50;    % size of the first batch

registrationSURF(Path_init, Path_back, dataset, subdataset, showProgress, showImages,...
                            saveImages, saveStats, medFiltSize, batchSize, firstbatchSize)
close all;                        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% crop images around the head in every batch obtained in the step above

subdataset = 'CAD_Fluor_Batches/';  % folder containing the batch sub-folders
width = 200;                        % the width of the cropped area
len = 280;                          % the length of the cropped area

cropImages(Path_init, Path_back, dataset, subdataset, saveImages, width, len);
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mutual information based registration -> inside every batch to the batch template

showProgress = 1;       % flag to display a bar indicating the progress of the task 
max_it = 100;           % maximum iterations used in the oprimization

registrationMI(Path_init, Path_back, dataset, subdataset, showProgress, saveImages, max_it);
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mutual information based registration -> every batch template to the global
%% template and propagation inside the batches

registerTemplates(Path_init, Path_back, dataset, subdataset, saveImages, max_it);

%% merge batches into 'FinalReg' folder

mergeBatches(Path_init, Path_back, dataset, subdataset, saveImages);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% final registration step -> crosscorrelation based registration to global template

subdataset = 'CAD_Fluor';   % folder contaninig the 'FinalReg' sub-folder
usfac = 100;                % upsampling factor
registrationDFT(Path_init, Path_back, dataset, subdataset, saveImages, showProgress, usfac);
