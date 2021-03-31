function compute3DDecorr_Freq( obj )
    %COMPUTE3DDECORR Summary of this function goes here
    %%
    % *Define Guassian Window* 
    sigx = obj.windowSigma/obj.dx;
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;
 
    % create gaussian kernel out to 3.5 sigma (odd number makes this
    % simpler)
    xLen = (ceil(sigx)*7); xMid = floor(xLen/2)+1;
    yLen = (ceil(sigy)*7); yMid = floor(xLen/2)+1;
    zLen = (ceil(sigz)*7); zMid = floor(xLen/2)+1;
    xmask = 1/(sigx*sqrt(2*pi))*exp(-((((1:xLen)-xMid)/(sigx)).^2)/2);
    ymask = 1/(sigy*sqrt(2*pi))*exp(-((((1:yLen)-yMid)/(sigy)).^2)/2);
    zmask = 1/(sigz*sqrt(2*pi))*exp(-((((1:zLen)-zMid)/(sigz)).^2)/2);
    [z_mask_mat,y_mask_mat,x_mask_mat] = ndgrid(zmask,ymask,xmask); 
    maskfilt = x_mask_mat.*y_mask_mat.*z_mask_mat; 
    volData = obj.rawData_cart;
    % *compute windowed ibs and autocorr01*
    
    obj.ibs = abs(volData).^2;
    obj.autocorr01 = volData(:,:,:,1:(end-1)).*conj(volData(:,:,:,2:end));
    %compute windowed ibs
    for currVolume = 1:size(obj.ibs,4)
      obj.ibs(:,:,:,currVolume) = convn(obj.ibs(:,:,:,currVolume),maskfilt,'same');
    end
    %compute autcorrelation and decorrelation
    for currVolume = 1:(size(obj.ibs,4)-1)
        obj.autocorr01(:,:,:,currVolume) = abs(convn(obj.autocorr01(:,:,:,currVolume),maskfilt,'same'));
    end
    for currVolume = 1:(size(obj.ibs,4)-1)
        R00 = obj.ibs(:,:,:,currVolume);
        R11 = obj.ibs(:,:,:,currVolume+1);
        B2 = R00.*R11;
        R01 = (obj.autocorr01(:,:,:,currVolume)).^2;
        tau = 10^3/(obj.interFrameTime);
        BMean = sum((obj.ROIMap.*B2),'all')/sum(obj.ROIMap(:));
        obj.decorr(:,:,:,currVolume) = 2*(B2-R01)./(B2 + mean(B2(:)))/tau;
    end
    % set values outside of volume to small number 
    obj.autocorr01(find(abs(obj.rawData_cart(:,:,:,1:(end-1))) == 0)) = 0;
    obj.ibs(find(abs(obj.rawData_cart(:,:,:,1:(end-1))) == 0)) = 0;
    obj.decorr(find(abs(obj.rawData_cart(:,:,:,1:(end-1))) == 0)) = 0;
end

