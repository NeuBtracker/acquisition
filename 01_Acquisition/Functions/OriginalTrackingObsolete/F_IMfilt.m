function [IM_out] = F_IMfilt(IM_in,filt_type,pl,param1,param2)
%This function smooth the input image with the specified type of filter.
% INPUT:  IM_in       input image to smooth
%         filt_type   type of filter (see below the list)
%         param1
%         param2
% OUTPUT: IM_out      output smoothed image 

    switch nargin
        case 2
            myfilter = fspecial(filt_type); pl=0;
        case 3
            myfilter = fspecial(filt_type);
        case 4
            myfilter = fspecial(filt_type,param1);  
        case 5
            myfilter = fspecial(filt_type,param1,param2);  
    end    
    IM_out=imfilter(IM_in, myfilter, 'replicate');
    
    if pl
        figure
        imshowpair(IM_in,IM_out,'montage')
    end
end


% The following list shows the syntax for each filter type. 
% h = fspecial('average', hsize) 
%     returns an averaging filter h of size hsize. 
%     The argument hsize can be a vector specifying the number of rows and 
%     columns in h, or it can be a scalar, in which case h is a square matrix. 
%     The default value for hsize is [3 3].
% 
% h = fspecial('disk', radius) 
%     returns a circular averaging filter (pillbox) within the square matrix 
%     of size 2*radius+1. The default radius is 5.
% 
% h = fspecial('gaussian', hsize, sigma) 
%     returns a rotationally symmetric Gaussian lowpass filter of size hsize 
%     with standard deviation sigma (positive). hsize can be a vector specifying 
%     the number of rows and columns in h, or it can be a scalar, in which 
%     case h is a square matrix. The default value for hsize is [3 3]; 
%     the default value for sigma is 0.5. Not recommended. Use imgaussfilt 
%     or imgaussfilt3 instead.
% 
% h = fspecial('laplacian', alpha) 
%     returns a 3-by-3 filter approximating the shape of the two-dimensional 
%     Laplacian operator. The parameter alpha controls the shape of the Laplacian 
%     and must be in the range 0.0 to 1.0. The default value for alpha is 0.2.
% 
% h = fspecial('log', hsize, sigma) 
%     returns a rotationally symmetric Laplacian of Gaussian filter of size 
%     hsize with standard deviation sigma (positive). hsize can be a vector 
%     specifying the number of rows and columns in h, or it can be a scalar, 
%     in which case h is a square matrix. The default value for hsize is [5 5] 
%     and 0.5 for sigma.
% 
% h = fspecial('motion', len, theta) 
%     returns a filter to approximate, once convolved with an image, 
%     the linear motion of a camera by len pixels, with an angle of theta 
%     degrees in a counterclockwise direction. The filter becomes a vector 
%     for horizontal and vertical motions. The default len is 9 and the default 
%     theta is 0, which corresponds to a horizontal motion of nine pixels.
% 
% h = fspecial('prewitt') 
%     returns the 3-by-3 filter h (shown below) that emphasizes horizontal 
%     edges by approximating a vertical gradient. If you need to emphasize 
%     vertical edges, transpose the filter h'.
%     [ 1  1  1 
%      0  0  0 
%     -1 -1 -1 ]
%     To find vertical edges, or for x-derivatives, use h'.
% 
% h = fspecial('sobel') 
%     returns a 3-by-3 filter h (shown below) that emphasizes horizontal 
%     edges using the smoothing effect by approximating a vertical gradient. 
%     If you need to emphasize vertical edges, transpose the filter h'.
%     [ 1  2  1 
%      0  0  0 
%     -1 -2 -1 ]

