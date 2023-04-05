function compute3DDecorr( obj )
%COMPUTE3DDECORR Summary of this function goes here
%   Detailed explanation goes here

% COMPUTE3DDECORR Summary of this function goes here
%   Detailed explanation goes here

%
%%
%     % *Define Guassian Window*
disp('Computing decorrelations ...')
x_range_length = size(obj.x_range,2);
y_range_length = size(obj.y_range,2);
z_range_length = size(obj.z_range,2);
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

rawData_cart = obj.rawData_cart;
obj.ibs = abs(rawData_cart).^2;
obj.autocorr01 = rawData_cart(:,:,:,1:(end-1)).*conj(rawData_cart(:,:,:,2:end));

% set NaN values to small number
obj.autocorr01(find(isnan(obj.autocorr01))) = realmin('double');
obj.ibs(find(isnan(obj.ibs))) = realmin('double');
% compute windowed ibs
for currVolume = 1:size(obj.ibs,4)
    obj.ibs(:,:,:,currVolume) = abs(ifftn(fftn(obj.ibs(:,:,:,currVolume)).*maskfilt));  %IBS Term
end
%compute windowed autcorrelation and decorrelation
for currVolume = 1:(size(obj.ibs,4)-1)
    obj.autocorr01(:,:,:,currVolume) = abs(ifftn(fftn(obj.autocorr01(:,:,:,currVolume)).*maskfilt)); %R01
end

for currVolume = 1:(size(obj.ibs,4)-1)
    %obj.decorr(:,:,:,currVolume) = (1 - abs(obj.autocorr01(:,:,:,currVolume)).^2./(obj.ibs(:,:,:,currVolume).*obj.ibs(:,:,:,currVolume+1)))./obj.interFrameTime;
    R00 = obj.ibs(:,:,:,currVolume);
    R11 = obj.ibs(:,:,:,currVolume+1);
    B2 = R00.*R11; %beta^2
    R01 = abs(obj.autocorr01(:,:,:,currVolume)).^2; %|R01|^2
    tau = obj.interFrameTime*1000; %ms

    % Decorrelation computation inside echo volume
    indInsideDecorrBounds = find(obj(1).rawData_cart(:,:,:,1)~=0);
    B2meanInsideDecorrROI = sum(B2(indInsideDecorrBounds))/nnz(indInsideDecorrBounds);
    
    B2insideDecorrROI = zeros(size(obj(1).rawData_cart(:,:,:,1)));
    B2insideDecorrROI(indInsideDecorrBounds) = B2(indInsideDecorrBounds);
    
    R01insideEcho = zeros(size(obj(1).rawData_cart(:,:,:,1)));
    R01insideEcho(indInsideDecorrBounds) = R01(indInsideDecorrBounds);

    obj.decorr_combined(:,:,:,currVolume) = 2*(B2insideDecorrROI-R01insideEcho)./...
        (B2insideDecorrROI + B2meanInsideDecorrROI)/tau;
    
    obj.decorr_local(:,:,:,currVolume) = (B2insideDecorrROI-R01insideEcho)...
        ./B2insideDecorrROI/tau;
    
    obj.decorr_global(:,:,:,currVolume) = (B2insideDecorrROI-R01insideEcho)...
        ./B2meanInsideDecorrROI/tau;
    
    obj.B = squeeze((B2insideDecorrROI+B2meanInsideDecorrROI) / 2 ./ B2insideDecorrROI);
    
end

% set values outside of volume to small number
obj.autocorr01(find(isnan(obj.rawData_cart(:,:,:,1:(end-1))))) = realmin('double');
obj.ibs(find(isnan(obj.rawData_cart))) = realmin('double');
obj.decorr_combined(find(isnan(obj.rawData_cart(:,:,:,1:(end-1))))) = realmin('double');
disp('Finished computing decorrelations.')

end

