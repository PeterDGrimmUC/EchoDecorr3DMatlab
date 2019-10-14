%% Define parameters 
if ~exist('Dm')
    readIQData;
end
Dm.data = Dm.data(:,:,:,1:2)
%user defined
azimuthAngle = pi/2;%90;
rangeAngle = pi/2;
rmin = 0;
cartScalingFactor = 3; % dx/dr
sigma = .1; %cm
frameRate = 20; % hz
%computed from existing parameters/infofile
rmax = (size(Dm.data,1)/Dm.Info.NumSamplesPerMm)/10;
thetamin= -azimuthAngle/2;
thetamax = azimuthAngle/2;
phimin=-rangeAngle/2;
phimax=rangeAngle/2; 

interFrameTime = 1/frameRate;
%% get pre procedure decorrelation for artifactual decorrelation 
usData = USDataClass(Dm.data,Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,interFrameTime);
%% 
tic
usData.scanConvert3DVolume;
toc
tic
usData.compute3DDecorr;
toc
usData.computeDecorrelationAverage('ensemble');
%%
disp('slice method');
tic
usData.scanConvert3DVolume_sliceMethod;
toc
tic
usData.compute3DDecorr_sliceMethod;
toc

%%
% % roi in the center of the volume, 2cm each way
% minX_ROI = preProcedureData.x_range(end/2) -1;
% minY_ROI = preProcedureData.y_range(end/2) -1;
% minZ_ROI = preProcedureData.z_range(end/2) -1;
% maxX_ROI = preProcedureData.x_range(end/2) +1;
% maxY_ROI = preProcedureData.y_range(end/2) +1;
% maxZ_ROI = preProcedureData.z_range(end/2) +1;
% 
% ROI = [minX_ROI,maxX_ROI,minY_ROI,maxY_ROI,minZ_ROI,maxZ_ROI]
% preProcedureData.setROI(ROI)
%%


%% variable phi trilinear 
% for n = 1:size(preProcedureData.rawData_cart,3)
%    figure(1)
%    
%    imagesc(abs(preProcedureData.rawData_cart(:,:,n,1)))
%    title('raw data');
%    figure(2)
%    
%    imagesc(preProcedureData.ibs(:,:,n,1))
%    title('integrated back scatter');
%    figure(3)
%    
%    imagesc(abs(preProcedureData.decorr(:,:,n,1)))
%    title('decorrelation');
%    pause(.1);
%    clf(1)
%    clf(2)
%    clf(3)
% end
%% variable phi trilinear vs bilinear raw data
for n = 1:size(usData.rawData_cart_slicemethod,3)

    figure(1)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],abs(usData.rawData_cart_slicemethod(:,:,n,1)))
    title('raw data 2d slices');
    figure(2)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],abs(usData.rawData_cart(:,:,n,1)))
    title('raw data');
    figure(3)
%     diffMatrix = (abs(usData.rawData_cart(:,:,n,1))-abs(usData.rawData_cart_slicemethod(:,:,n,1)))./abs(usData.rawData_cart(:,:,n,1));
%     %testcorr = xcorr2(abs(preProcedureData.ibs(:,:,n,1)),abs(preProcedureData.ibs_slicemethod(:,:,n,1)));
%     imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],diffMatrix)
%     title('difference raw data');

    pause(.1);
    

end
%% variable theta trilinear vs bilinear raw data
for n = 1:size(usData.rawData_cart_slicemethod,2)

    figure(1)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.rawData_cart_slicemethod(:,n,:,1))))
    title('raw data 2d slices');
    figure(2)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.rawData_cart(:,n,:,1))))
    title('raw data');
    figure(3)
    diffMatrix = (abs(usData.rawData_cart(:,n,:,1))-abs(usData.rawData_cart_slicemethod(:,n,:,1)))./abs(usData.rawData_cart(:,n,:,1));
    %testcorr = xcorr2(squeeze(abs(preProcedureData.ibs(:,n,:,1))),squeeze(abs(preProcedureData.ibs_slicemethod(:,n,:,1))));
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(diffMatrix))
    title('difference raw data');

    pause(.5);
    clf(1)
    clf(2)
    clf(3)

end

%% variable phi trilinear vs bilinear convolved with gaussian
for n = 1:size(usData.rawData_cart_slicemethod,2)
    figure(1)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.ibs_slicemethod(:,n,:,1))))
    title('raw data 2d slices');
    figure(2)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.ibs(:,n,:,1))))
    title('raw data');
    figure(3)
    %diffMatrix = abs((abs(usData.ibs(:,n,:,1))-abs(usData.ibs_slicemethod(:,n,:,1)))./abs(usData.ibs(:,n,:,1)));
    %diffMatrix(find(abs(diffMatrix) > 10)) = 0;
    %testcorr = xcorr2(squeeze(abs(usData.ibs(:,n,:,1))),squeeze(abs(usData.ibs_slicemethod(:,n,:,1))));
    %imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(diffMatrix))
    title('difference raw data');

    pause(.5);
    clf(1)
    clf(2)
    clf(3)

end
%% variable theta trilinear vs bilinear convolved with gaussian
for n = 1:size(usData.rawData_cart_slicemethod,2)

    figure(1)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.ibs_slicemethod(:,n,:,1))))
    title('raw data 2d slices');
    figure(2)
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(abs(usData.ibs(:,n,:,1))))
    title('raw data');
    figure(3)
    diffMatrix = abs((abs(usData.ibs(:,n,:,1))-abs(usData.ibs_slicemethod(:,n,:,1)))./abs(usData.ibs(:,n,:,1)));
    diffMatrix(find(abs(diffMatrix) > 10)) = 0;
    testcorr = xcorr2(squeeze(abs(usData.ibs(:,n,:,1))),squeeze(abs(usData.ibs_slicemethod(:,n,:,1))));
    imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],squeeze(diffMatrix))
    title('difference raw data');

    pause(.5);
    clf(1)
    clf(2)
    clf(3)

end

%%

for n = 1:size(usData.rawData_cart_slicemethod,3)
   figure(1)
   
   imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],abs(usData.rawData_cart_slicemethod(:,:,n,1)))
   title('raw data');
   figure(2)
   
   imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],usData.autocorr01_slicemethod(:,:,n,1))
   title('integrated back scatter');
   figure(3)
   
   imagesc([usData.yMin,usData.yMax],[usData.xMin,usData.xMax],abs(usData.decorr_slicemethod(:,:,n,1)))
   title('decorrelation');
   pause(.1);
   clf(1)
   clf(2)
   clf(3)
end
%%
for n = 1:size(usData.rawData_cart_slicemethod,2)
   figure(1)
   
   imagesc(squeeze(abs(usData.rawData_cart(:,n,:,1))))
   title('raw data');
   figure(2)
   imagesc(squeeze(abs(usData.rawData_cart_slicemethod(:,n,:,1))))
   title('raw data slice method');
   figure(2)
   
   imagesc(usData.ibs_slicemethod(:,:,n,1))
   title('integrated back scatter');
   figure(3)
   
   imagesc(abs(usData.decorr_slicemethod(:,:,n,1)))
   title('decorrelation');
   pause(.1);
   clf(1)
   clf(2)
   clf(3)
end
%%
for n = 1:size(usData.rawData_cart_slicemethod,3)
   figure(1)
   
   imagesc(squeeze(abs(usData.ibs(:,:,n,1))))
   title('raw data');
   figure(2)
   imagesc(squeeze(abs(usData.ibs_slicemethod(:,:,n,1))))
   title('raw data slice method');
   figure(2)
   
   imagesc(usData.ibs_slicemethod(:,:,n,1))
   title('integrated back scatter');
   figure(3)
   
   imagesc(abs(usData.decorr_slicemethod(:,:,n,1)))
   title('decorrelation');
   pause(.1);
   clf(1)
   clf(2)
   clf(3)
end
%%
normalIbs = abs(usData.ibs)/ sum(abs(usData.ibs(:)));
normalIbs_slices = (abs(usData.ibs_slicemethod))/(sum(abs(usData.ibs_slicemethod(:))));
%errormatrix = (abs(preProcedureData.ibs)/(sum(abs(preProcedureData.ibs(:)))) - (abs(preProcedureData.ibs_slicemethod))/(sum(abs(preProcedureData.ibs_slicemethod(:))))) ./((sum(abs(preProcedureData.ibs_slicemethod(:)))));
errormatrix = (normalIbs -normalIbs_slices)./normalIbs;
errormatrix(find(abs(errormatrix) > 1)) = 1;
imagesc(abs(errormatrix(:,:,45,1)))