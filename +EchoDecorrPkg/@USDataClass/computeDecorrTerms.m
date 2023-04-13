function computeDecorrTerms( obj)
    %% COMPUTE3DDECORR Summary of this function goes here
    validPts=obj.rawData_cart(:,:,:,1)~=0;
    obj.frustumPts=validPts;
    if ~isempty(obj.IBSrMin) && ~isempty(obj.IBSrMax)        
        validPts=validPts&...
             ndgrid(obj.z_range>=obj.IBSrMin&obj.z_range<=obj.IBSrMax,...
                    obj.y_range>=obj.IBSAzMin&obj.y_range<=obj.IBSAzMax,...
                    obj.x_range>=obj.IBSElMin&obj.x_range<=obj.IBSElMax);
    end
    padAmt = 0;%obj.windowSigma*4;
    %padToOdd = double(~mod(size(obj.rawData_cart),2)).*[1,1,1,0];
    padDatSize=size(obj.rawData_cart)+2*padAmt;
    padDatSize=padDatSize(1:3);
    paddedData = zeros(padDatSize);
    for currVol = 1:size(obj.rawData_cart,4)
        paddedData(:,:,:,currVol) = padarray(obj.rawData_cart(:,:,:,currVol),[padAmt,padAmt,padAmt],'both');
    end
    % *Define Guassian Window* 
    x_range_length = size(obj.x_range,2)+2*padAmt;
    y_range_length = size(obj.y_range,2)+2*padAmt;
    z_range_length = size(obj.z_range,2)+2*padAmt;
    sigx = obj.windowSigma/obj.dx;
    sigy = obj.windowSigma/obj.dy;
    sigz = obj.windowSigma/obj.dz;

    x_mid = ceil(x_range_length/2+1);
    y_mid = ceil(y_range_length/2+1);
    z_mid = ceil(z_range_length/2+1);

    sigfel = x_range_length/(2*pi*sigx);
    sigfaz = y_range_length/(2*pi*sigy);
    sigfra = z_range_length/(2*pi*sigz);

    xmask = exp(-(((1:x_range_length)-x_mid).^2)/2/sigfel^2);
    ymask = exp(-(((1:y_range_length)-y_mid).^2)/2/sigfaz^2);
    zmask = exp(-(((1:z_range_length)-z_mid).^2)/2/sigfra^2);
    [z_mask_mat,y_mask_mat,x_mask_mat] = ndgrid(zmask,ymask,xmask);
    maskfilt = (fftshift(z_mask_mat.*y_mask_mat.*x_mask_mat));
    % *compute windowed ibs and autocorr01*
    %compute ibs and autocorr before windowing
    ibsPadded = abs(paddedData).^2;
    autocorr01Padded = paddedData(:,:,:,1:(end-1)).*conj(paddedData(:,:,:,2:end));
    % set NaN values to 0
    ibsPadded(find(isnan(ibsPadded))) = 0;
    autocorr01Padded(find(isnan(autocorr01Padded))) = 0;
    %compute windowed ibs
    for currVolume = 1:size(ibsPadded,4)
      ibsPadded(:,:,:,currVolume) = abs((ifftn(fftn(ibsPadded(:,:,:,currVolume)).*maskfilt)));
    end
    %compute autcorrelation and decorrelation
    for currVolume = 1:(size(ibsPadded,4)-1)
        autocorr01Padded(:,:,:,currVolume) = abs((ifftn(fftn(autocorr01Padded(:,:,:,currVolume)).*maskfilt)));
    end
    obj.ibs =              ibsPadded(padAmt+1:end-padAmt,padAmt+1:end-padAmt,padAmt+1:end-padAmt,:);
    obj.autocorr01= autocorr01Padded(padAmt+1:end-padAmt,padAmt+1:end-padAmt,padAmt+1:end-padAmt,:);
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