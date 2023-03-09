function computeDecorrTerms( obj)
    %% COMPUTE3DDECORR Summary of this function goes here
    validPts=obj.rawData_cart(:,:,:,1)~=0;
    obj.frustumPts=validPts;
    if ~isempty(obj.IBSrMin) && ~isempty(obj.IBSrMax)        
        validPts=validPts&...
             ndgrid(obj.z_range>obj.IBSrMin&obj.z_range<obj.IBSrMax,...
                    obj.y_range>obj.IBSAzMin&obj.y_range<obj.IBSAzMax,...
                    obj.x_range>obj.IBSElMin&obj.x_range<obj.IBSElMax);
    end
    % *Define Guassian Window* 
    sigx = obj.windowSigma/obj.dx;
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;
    % create gaussian kernel out to 3.5 sigma (odd number makes this
    % simpler)
    xLen = (ceil(sigx)*7)+~mod((ceil(sigx)*7),2); xMid = floor(xLen/2)+1;
    yLen = (ceil(sigy)*7)+~mod((ceil(sigy)*7),2); yMid = floor(xLen/2)+1;
    zLen = (ceil(sigz)*7)+~mod((ceil(sigz)*7),2); zMid = floor(xLen/2)+1;
    xmask = 1/(sigx*sqrt(2*pi))*exp(-((((1:xLen)-xMid)/(sigx)).^2)/2);
    ymask = 1/(sigy*sqrt(2*pi))*exp(-((((1:yLen)-yMid)/(sigy)).^2)/2);
    zmask = 1/(sigz*sqrt(2*pi))*exp(-((((1:zLen)-zMid)/(sigz)).^2)/2);
    [z_mask_mat,y_mask_mat,x_mask_mat] = ndgrid(zmask,ymask,xmask); 
    maskfilt = x_mask_mat.*y_mask_mat.*z_mask_mat; 
    % Pad data to be odd in all dims
    padToOdd = double(~mod(size(obj.rawData_cart),2));
    volData = zeros(size(obj.rawData_cart)+padToOdd.*[1,1,1,0]);
    padToOdd = padToOdd(1:3);
    for currVol = 1:size(obj.rawData_cart,4)
        volData(:,:,:,currVol) = padarray(obj.rawData_cart(:,:,:,currVol),padToOdd,'post');
    end
    % Pad for FFT convolution
    padImArr = ceil(size(maskfilt)/2);
    padKernelArr = ceil(size(volData)/2);
    padKernelArr = padKernelArr(1:3);
    kernelPadded = (padarray(maskfilt,padKernelArr,'both'));
    kernelFreq = fftn(kernelPadded);
    for currVol = 1:size(obj.rawData_cart,4)
        paddedData(:,:,:,currVol) = padarray(volData(:,:,:,currVol),padImArr,'both');
    end
    % *compute windowed ibs and autocorr01*
    %compute ibs and autocorr before windowing
    ibsPadded = abs(paddedData).^2;
    autocorr01Padded = paddedData(:,:,:,1:(end-1)).*conj(paddedData(:,:,:,2:end));
    % set NaN values to 0
    ibsPadded(find(isnan(ibsPadded))) = 0;
    autocorr01Padded(find(isnan(autocorr01Padded))) = 0;
    %compute windowed ibs
    for currVolume = 1:size(ibsPadded,4)
      ibsPadded(:,:,:,currVolume) = (ifftshift(ifftn(fftn(ibsPadded(:,:,:,currVolume)).*kernelFreq)));
    end
    %compute autcorrelation and decorrelation
    for currVolume = 1:(size(ibsPadded,4)-1)
        autocorr01Padded(:,:,:,currVolume) = abs(ifftshift(ifftn(fftn(autocorr01Padded(:,:,:,currVolume)).*kernelFreq)));
    end
    obj.ibs = ibsPadded(1+padImArr(1):end-padImArr(1)-padToOdd(1),1+padImArr(2):end-padImArr(2)-padToOdd(2),1+padImArr(3):end-padImArr(3)-padToOdd(3),:);
    obj.autocorr01= autocorr01Padded(1+padImArr(1):end-padImArr(1)-padToOdd(1),1+padImArr(2):end-padImArr(2)-padToOdd(2),1+padImArr(3):end-padImArr(3)-padToOdd(3),:);
    obj.tau = 10^3*(obj.interFrameTime);
    for currVolume = 1:(size(obj.ibs,4)-1)
        R00 = obj.ibs(:,:,:,currVolume);
        R11 = obj.ibs(:,:,:,currVolume+1);
        obj.B2 = R00.*R11;
        B2ValidIBS = obj.B2(validPts);
        obj.B2_avg = mean(B2ValidIBS(:));
        obj.R01 = (obj.autocorr01(:,:,:,currVolume)).^2;
        obj.R01(~obj.frustumPts)=realmin;
        obj.B2(~obj.frustumPts)=realmin;
    end
end