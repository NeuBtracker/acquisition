function [OBJ_out,T] = F_IMregist_manual_102(OBJ,REF,pl,shift,theta,stretch,shear)
%This function allows a manual registration of the input image.
%Different parameters of the registration can be tuned.
%  INPUT: OBJ      image to register
%         REF      reference image
%         pl       plot the results (1 yes, 0 no)
%         shift    translation in pxl along the X and Y directions
%         theta    counterclockwise rotation in degree
%         stretch  stretch factors along the X and Y directions
%         shear    shear factors along the X and Y directions
% OUTPUT: OBJ_out  registered image
%         T        overall transformation matrix

    if nargin<7, shear=[0 0]; end
    if nargin<6, stretch=[1 1]; end
    if nargin<5, theta=0; end
    if nargin<4, shift=[0 0]; end
    if nargin<3, pl=0; end
    if nargin<2, error('Error using F_IMregist_manual: not enough input arguments'); end  
    
    if ~isequal(size(OBJ), size(REF))
        error('Error using F_IMregist_manual: input images must have the same size');
    end

    % Defining transformation =============================================
    % Shift --------------
    Tshi=[zeros(2,3);...
          shift.*[1 -1], 0];
      
    % Rotation -----------
    theta=-theta/(180/pi);
    Rotmat=[cos(theta),  sin(theta);...
            -sin(theta), cos(theta)];
    Trot=[Rotmat,[0;0];...
          ((flip(size(OBJ))/2.0)*(eye(2)-Rotmat)), 1]; 
      
    % Stretch ------------
    Tstr=[diag(stretch),[0;0];...
          (flip(size(OBJ))/2.0).*(1.0-stretch), 1];
    
    % Shear --------------
    Tshe=[eye(2)+fliplr(diag(shear)),[0;0];...
          -((flip(size(OBJ))/2.0)*fliplr(diag(shear))), 1];
    
    % Combining transformations
    T= Tshe * Tstr * Trot + Tshi;
    
    
    % Applying transformation =============================================
    tform = maketform('affine',T);    
    OBJ_out = imtransform(OBJ,tform,'XData',[1 size(OBJ,2)],'YData',[1 size(OBJ,1)]);
  
    Dif=(single(OBJ_out)-single(REF)); 
    d=sum((Dif(:).^2.0))/numel(OBJ);  
    
    
    if pl
        figure('name','F_IMregist_manual')
        subplot(2,3,1)
        imagesc(REF)
        colormap gray
        title('REF')
        
        subplot(2,3,4)
        imagesc(OBJ_out)
        colormap gray
        title('OBJ-out')
        
        subplot(2,3,[2 3 5 6])
        imshowpair(OBJ_out, REF)
        title(['OBJreg vs REF - diff^{2}=',num2str(d)])
        
    end
end

