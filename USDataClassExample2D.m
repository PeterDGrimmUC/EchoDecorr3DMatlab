% Example usage of USDataClass object 
% requires compiled c MEX files 
%fileName = mfilename('fullpath');
%            addpath(genpath(fileName(1:end-length(mfilename('class')))));
%thisFileDir = uigetdir(); % point this towards the target data directory
%thisFileName = fullfile(thisFileDir,'bufApl0Out_0x0_0x0.data.dm.pmcr');
targetDir = '/Volumes/DATA 2/datadump07142021/AllBufferDump/IQDATA_Date_07-14-2021_Time_14-41-24-30/';
targetFile = 'bufApl4Out_0x1_0x0.data.dm.part';

thisFileName = fullfile(targetDir,targetFile);

Dm = read_lbdump(thisFileName2); % call memory mapped read function (requires MEX function)

%%
% get radius information
rmin = 0;
rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
frameRate = 87;
thetaRange = 90;
thetamax = pi/360*thetaRange;
thetamin = -thetamax;

cartScalingFactor = 2.4268;
sigma = 3;
% create USDataClass object
Dm.startTime = datetime;
outDataSet2D = USDataClass2D(Dm.data,Dm.startTime,Dm.Info,rmin,rmax,thetamin,thetamax,cartScalingFactor,sigma,frameRate);
%%
outDataSet2D.scanConvert2D;
%%
outDataSet2D.compute2DDecorr_Time;