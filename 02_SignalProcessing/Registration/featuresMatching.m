function [tform, status, ptsOriginal, ptsDistorted, matchedPtsOriginal, matchedPtsDistorted, ssd_metric] = featuresMatching(IM, IM_o)
% This function provides the geometric tranformation between the input images 'IM' and 'IM_o'

%% Input:

% 'IM' is the reference image (template)

% 'IM_o' is the image to be registered

%% Output:

% 'tform' is the geometric transformation between IM and IM_o

% status is the output of Matlab built-in 'estimateGeometricTransform', and
% indicates if IM_o could be trasformed to match IM, considering their
% matched points.

% 'ptsOriginal' is a struct containg SUFR feature points description of
% 'IM', as obtained from Matlab built-in 'detectSURFFeatures'

% 'ptsDistorted' is a struct containg SUFR feature points description of
% 'IM_o', as obtained from Matlab built-in 'detectSURFFeatures'

% 'matchedPtsOriginal' is a struct containing information on the matched
% feature poins of 'IM', as obtained from Matlab built-in 'matchFeatures'

% 'matchedPtsDistorted' is a struct containing information on the matched
% feature poins of 'IM_o', as obtained from Matlab built-in 'matchFeatures'

%% Estimate transformation

ptsOriginal  = detectSURFFeatures(mat2gray(IM));
ptsDistorted = detectSURFFeatures(mat2gray(IM_o));

[featuresOriginal,validPtsOriginal] = ...
    extractFeatures(IM,ptsOriginal);
[featuresDistorted,validPtsDistorted] = ...
    extractFeatures(IM_o,ptsDistorted);

[index_pairs ssd_metric] = matchFeatures(featuresOriginal, featuresDistorted,...
    'MaxRatio', .8, 'MatchThreshold', 40);

matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1));
matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));

[tform, ~, ~, status] = ...
    estimateGeometricTransform(matchedPtsDistorted, matchedPtsOriginal,'similarity');