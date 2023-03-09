% Example usage of USDataClass object 
% requires compiled c MEX files 
fileName = mfilename('fullpath');
            addpath(genpath(fileName(1:end-length(mfilename('class')))));
thisFileDir = uigetdir(); % point this towards the target data directory
thisFileName = fullfile(thisFileDir,'bufApl0Out_0x0_0x0.data.dm.pmcr');
tic;
%
Dm = read_lbdump_wrapc(thisFileName); % call memory mapped read function (requires MEX function)
toc;
%%
% get radius information
rmin = 0;
rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
frameRate = Dm.Info.framerate;
phiRange = Dm.Info.phiRange;
thetaRange = Dm.Info.thetaRange;
thetamax = pi/360*thetaRange;
thetamin = -thetamax;
phimax = pi/360*phiRange;
phimin = -phimax;
cartScalingFactor = 1;
sigma = 3;
% create USDataClass object
outDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,frameRate);
outDataSet.setIBSParam(0,40,-30,30,-30,30);
% generate lookup table for scan conversion (MEX function), only needs to
% be generated once per a given geometry 

scanConvLookup = outDataSet.scanConv_Generate_c(); 
% use lookup table to scan convert the BMode data
outDataSet.scanConv_apply_c(scanConvLookup);
% Create ROI
[zGrid,yGrid,xGrid] = ndgrid(outDataSet.z_range,outDataSet.y_range,outDataSet.x_range);
ROIMask = zeros(size(zGrid)); 
zMid = 15; 
xMid = 0; 
yMid = 0; 
r = 10; 
validPts = (zGrid -zMid).^2 +(yGrid -yMid).^2 +(xGrid -xMid).^2  < r^2;
ROIMask(validPts) = 1; 
% set ROI in the object
outDataSet.ROIMap = ROIMask; 
%%
%outDataSet.setIBSParam(5,50);
% compute decorrelation
%%
structIn=struct('time',true, 'global',true, 'local', true);

outDataSet.compute3DDecorr_arg(structIn);