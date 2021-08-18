function compute2DDecorr_Freq( obj )
    %COMPUTE3DDECORR Summary of this function goes here
    %%
    % *Define Guassian Window* 
    
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;
 
    % create gaussian kernel out to 3.5 sigma (odd number makes this
    % simpler)
    
     
    % Pad data to be odd in all dims
    pad3Sigma = ceil([3*sigz, 3*sigy]); 
    padToOdd = [mod(size(obj.rawData_cart,[1,2])+pad3Sigma,2),0];
    paddedData = padarray(padarray(obj.rawData_cart,pad3Sigma),padToOdd,'post');
    [zSize, ySize] = size(paddedData,[1,2]); 
    zMid = ceil(zSize/2);
    yMid = ceil(ySize/2);
    ymask = 1/(sigy*sqrt(2*pi))*exp(-((((1:ySize)-yMid)/(sigy)).^2)/2);
    zmask = 1/(sigz*sqrt(2*pi))*exp(-((((1:zSize)-zMid)/(sigz)).^2)/2);
    [z_mask_mat,y_mask_mat] = ndgrid(zmask,ymask); 
    maskfilt = y_mask_mat.*z_mask_mat; 
    kernelFreq = fftn(maskfilt);
    % *compute windowed ibs and autocorr01*
    %compute ibs and autocorr before windowing
    ibsPadded = abs(paddedData).^2;
    autocorr01Padded = paddedData(:,:,1).*conj(paddedData(:,:,2));
    % set NaN values to 0
    ibsPadded(isnan(ibsPadded)) = 0;
    autocorr01Padded(isnan(autocorr01Padded)) = 0;
    %compute windowed ibs
    
    for currVolume = 1:size(ibsPadded,3)
      ibsPadded(:,:,currVolume) = ifftshift(ifftn(fftn(ibsPadded(:,:,currVolume)).*kernelFreq));
    end
    %compute autcorrelation and decorrelation
    for currVolume = 1:(size(ibsPadded,3)-1)
        autocorr01Padded(:,:,currVolume) = abs(ifftshift(ifftn(fftn(autocorr01Padded(:,:,currVolume)).*kernelFreq)));
    end
   
    obj.ibs = ibsPadded(1+pad3Sigma(1):(end-pad3Sigma(1)-padToOdd(1)),1+pad3Sigma(2):(end-pad3Sigma(2)-padToOdd(2)),:);
    obj.autocorr01= autocorr01Padded(1+pad3Sigma(1):(end-pad3Sigma(1)-padToOdd(1)),1+pad3Sigma(2):(end-pad3Sigma(2)-padToOdd(2)),:);
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

