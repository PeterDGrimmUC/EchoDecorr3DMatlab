function computeBiplaneDecorr_Freq( obj )
    %COMPUTE3DDECORR Summary of this function goes here
    %%
    % *Define Guassian Window* 
    obj.decorr = {};
for i = 1:length(obj.rawData)
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;
    
    % create gaussian kernel out to 3.5 sigma (odd number makes this
    % simpler)
    tau = 10^3/(obj.interFrameTime);
    % Pad data to be odd in all dims
    pad3Sigma = ceil([3*sigz, 3*sigy]); 
    padToOdd = [mod(size(obj.rawData_cart{i},[1,2])+pad3Sigma,2),0];
    paddedData = padarray(padarray(obj.rawData_cart{i},pad3Sigma),padToOdd,'post');
    [zSize, ySize] = size(paddedData,[1,2]); 
    zMid = ceil(zSize/2);
    yMid = ceil(ySize/2);
    ymask = 1/(sigy*sqrt(2*pi))*exp(-((((1:ySize)-yMid)/(sigy)).^2)/2);
    zmask = 1/(sigz*sqrt(2*pi))*exp(-((((1:zSize)-zMid)/(sigz)).^2)/2);
    [z_mask_mat,y_mask_mat] = ndgrid(zmask,ymask); 
    maskfilt = y_mask_mat.*z_mask_mat; 
    kernelFreq = fftn(maskfilt);
    % *compute windowed R and autocorr01*
    %compute R and autocorr before windowing
    RPadded = abs(paddedData).^2;
    autocorr01Padded = paddedData(:,:,1).*conj(paddedData(:,:,2));
    % set NaN values to 0
    RPadded(isnan(RPadded)) = 0;
    autocorr01Padded(isnan(autocorr01Padded)) = 0;
    %compute windowed R
    
    for currVolume = 1:size(RPadded,3)
        RPadded(:,:,currVolume) = ifftshift(ifft2(fft2(RPadded(:,:,currVolume)).*kernelFreq));
    end
    %compute autcorrelation and decorrelation
    for currVolume = 1:(size(RPadded,3)-1)
        autocorr01Padded(:,:,currVolume) = (ifftshift(ifft2(fft2(autocorr01Padded(:,:,currVolume)).*kernelFreq)));
    end
   
    obj.R = RPadded(1+pad3Sigma(1):(end-pad3Sigma(1)-padToOdd(1)),1+pad3Sigma(2):(end-pad3Sigma(2)-padToOdd(2)),:);
    obj.autocorr01= autocorr01Padded(1+pad3Sigma(1):(end-pad3Sigma(1)-padToOdd(1)),1+pad3Sigma(2):(end-pad3Sigma(2)-padToOdd(2)));
    tempDat = obj.rawData_cart{i}; 
    pointsInVol = (squeeze(tempDat(:,:,1))~=0);
    pointsNotInVol = (squeeze(tempDat(:,:,1))==0);
    R00 = squeeze(obj.R(:,:,1));
    R11 = squeeze(obj.R(:,:,2));
    B2 = (R00.*R11);
    R01 = abs(obj.autocorr01(:,:)).^2;
    
    temp = 2*(B2-R01)./(B2 + mean(B2(pointsInVol)))/tau;
    %temp = 2*(B2-R01)./(B2 + mean(B2(:)))/tau;
    temp(pointsNotInVol) = 0; 
    obj.decorr{i} = temp; 
end
end


