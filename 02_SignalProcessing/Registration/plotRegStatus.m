function plotRegStatus(IM, IM_o, IM_transformed, ptsOriginal, ptsDistorted, matchedPtsOriginal, matchedPtsDistorted, status)
% This function plots the results of feature matching based registration 

%% Input:

% 'IM' is the reference image (template)

% 'IM_o' is the image to be registered

% 'IM_transformed' is the transformed version of 'IM_o' in order to match 'IM' 

% 'ptsOriginal' is a struct containg SUFR feature points description of
% 'IM', as obtained from Matlab built-in 'detectSURFFeatures'

% 'ptsDistorted' is a struct containg SUFR feature points description of
% 'IM_o', as obtained from Matlab built-in 'detectSURFFeatures'

% 'matchedPtsOriginal' is a struct containing information on the matched
% feature poins of 'IM', as obtained from Matlab built-in 'matchFeatures'

% 'matchedPtsDistorted' is a struct containing information on the matched
% feature poins of 'IM_o', as obtained from Matlab built-in 'matchFeatures'

% status is the output of Matlab built-in 'estimateGeometricTransform', and
% indicates if IM_o could be trasformed to match IM, considering their
% matched points.

%% Plot:

subplot(2,2,1)
cla
imagesc(IM); title(['Reference Image']); hold on;
if ptsOriginal.Count > 0
    plot(ptsOriginal.selectStrongest(10));
end
set(gca, 'XTick', []);
set(gca, 'YTick', []);

subplot(2,2,2)
cla
imagesc(IM_o); title(['Destorted Image']); hold on;
if ptsDistorted.Count > 0 
    plot(ptsDistorted.selectStrongest(10));
end
set(gca, 'XTick', []);
set(gca, 'YTick', []);

subplot(2,2,3)

showMatchedFeatures(IM,IM_o,matchedPtsOriginal,matchedPtsDistorted, 'montage');

if(status == 0)
    subplot(2,2,4)
    cla
    imagesc(IM_transformed); title(['Recovered Image']);
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);        
end        

