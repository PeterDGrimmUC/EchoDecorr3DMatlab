%% Example usage of USDataClass object 
% requires compiled c MEX files 
fileName = mfilename('fullpath');
            addpath(genpath(fileName(1:end-length(mfilename('class')))));
thisFileDir = uigetdir(); % point this towards the target data directory
thisFileName = fullfile(thisFileDir,'bufApl0Out_0x0_0x0.data.dm.pmcr'); % this is the buffer used for 3D data, 2D/biplane have a different name
Dm = EchoDecorrPkg.Utils.read_lbdump_wrapc(thisFileName); % read in the data
%% Create a USDataClass object 
% The constructor takes the following arguments:
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
% Instantiate with EchoDecorrPkgs.USDataClass(args)
outDataSet = EchoDecorrPkg.USDataClass(Dm.data,Dm.startTime, Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,frameRate);
% Set IBS bounds, if unset it will process all voxels within the frustum
% e.g: assume no bounds
outDataSet.setIBSParam(0,40,-30,30,-30,30);
% generate lookup table for scan conversion (MEX function), only needs to
% be generated once per a given geometry 
scanConvLookup = outDataSet.scanConv_Generate_c(); 
% use lookup table to scan convert the BMode data
outDataSet.scanConv_apply_c(scanConvLookup);

%%
structIn=struct('global',true, 'local', true);
outDataSet.getFormattedDec(structIn);