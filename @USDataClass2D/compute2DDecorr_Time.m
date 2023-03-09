function compute2DDecorr_Time( obj )
    %COMPUTE3DDECORR Summary of this function goes here
    %%
    % *Define Guassian Window* 
    %obj.rawData_cart = 
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;
    zLen = ceil(sigz*10); 
    yLen = ceil(sigy*10); 
    yLen = yLen + mod(yLen-1,2); 
    zLen = zLen + mod(zLen-1,2); 
    yMid = ceil(yLen/2);
    zMid = ceil(zLen/2);
    % create gaussian kernel out to 3.5 sigma (odd number makes this
    % simpler)
    
    ymask = 1/(sigy*sqrt(2*pi))*exp(-((((1:yLen)-yMid)/(sigy)).^2)/2);
    zmask = 1/(sigz*sqrt(2*pi))*exp(-((((1:zLen)-zMid)/(sigz)).^2)/2);
    [z_mask_mat,y_mask_mat] = ndgrid(zmask,ymask); 
    maskfilt = y_mask_mat.*z_mask_mat; 
    % Pad data to be odd in all dims
    
    % *compute windowed ibs and autocorr01*
    %compute ibs and autocorr before windowing
    R = abs(obj.rawData_cart).^2;
    autocorr01 = obj.rawData_cart(:,:,1).*conj(obj.rawData_cart(:,:,2));
    % set NaN values to 0
    R(isnan(R)) = 0;
    autocorr01(isnan(autocorr01)) = 0;
    %compute windowed ibs
    
    for currFrame = 1:size(R,3)
      R(:,:,currFrame) = conv2(R(:,:,currFrame),maskfilt,'same');
    end
    %compute autcorrelation and decorrelation
    for currFrame = 1:(size(R,3)-1)
        autocorr01(:,:,currFrame) = conv2(autocorr01(:,:,currFrame),maskfilt,'same');
    end
   
    obj.R = R; 
    obj.autocorr01= autocorr01; 
    pointsInVol = (squeeze(obj.rawData_cart(:,:,1))~=0);
    obj.decorr = zeros(size(obj.rawData_cart,[1,2]));
    R00 = squeeze(obj.ibs(:,:,1));
    R00 = R00(pointsInVol);
    R11 = squeeze(obj.ibs(:,:,2));
    R11 = R11(pointsInVol); 
    B2 = R00.*R11;
    R01 = abs(obj.autocorr01(:,:)).^2;
    R01 = R01(pointsInVol); 
    tau = 10^3/(obj.interFrameTime);
    obj.decorr(pointsInVol) = 2*(B2-R01)./(B2 + mean(B2))/tau;
end

