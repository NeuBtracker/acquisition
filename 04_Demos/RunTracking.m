%%%%%%%%%%%%%%%%%%%%% Run Tracking Pipeline %%%%%%%%%%%%%%%%%%%%%

% path to helper functions
addpath(genpath('../'));

% path to data set
Path_init = '../../Data/';
dataset  = 'CAD/';
subdataset = 'CAD_Refl';

% display options
showProgress = 0;
showImages = 1;
recordVideo = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% perform tracking
% arena properties 
ci = [223, 310, 135];     % center and radius of the arena ([c_row, c_col, r])
mean_offset = 20;         % every mean_offset'th image is used to compute the average of the stack  
stack_size = 500;         % size of the stack to be processed

trackingOffline(Path_init, dataset, subdataset, showProgress, showImages, recordVideo,...
                    mean_offset, stack_size, ci);
