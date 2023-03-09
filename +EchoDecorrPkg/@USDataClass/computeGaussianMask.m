function  computeGaussianMask( obj )
%COMPUTEGAUSSIANMASK: Computes a Gaussian mask for spatial filtering 
%   Computes a 3-D gaussian mask using 1-D gaussians 
    % get size of volume
    x_range_length = size(obj.x_range,2);
    y_range_length = size(obj.y_range,2);
    z_range_length = size(obj.z_range,2);
    % convert sigma value from mm to pixels 
    obj.sigx = obj.windowSigma/obj.dx;
    obj.sigy = obj.windowSigma/obj.dy;
    obj.sigz = obj.windowSigma/obj.dz;
    % find midpoints 
    x_mid = ceil(x_range_length/2);
    y_mid = ceil(y_range_length/2);
    z_mid = ceil(z_range_length/2);
    % define sigma 
    sigfaz = x_range_length/(2*pi*sigx);
    sigfra = x_range_length/(2*pi*sigy);
    sigfel = x_range_length/(2*pi*sigz); 
    % create 1-D gaussians 
    xmask = exp(-(((1:x_range_length)-x_mid).^2)/2/sigfaz^2);
    ymask = exp(-(((1:y_range_length)-y_mid).^2)/2/sigfra^2);
    zmask = exp(-(((1:z_range_length)-z_mid).^2)/2/sigfel^2); 
    % create grid of gaussian data
    [x_mask_mat,y_mask_mat,z_mask_mat] = ndgrid(zmask,xmask,ymask); 
    % create 3-D gaussian mask
    maskfilt = (fftshift(x_mask_mat.*y_mask_mat.*z_mask_mat)); 
    maskfilt = maskfilt/sum(maskfilt(:));
    % set object maskfilt property
    obj.maskfilt = maskfilt;
end

