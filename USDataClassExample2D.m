%% Example usage of USDataClass object for 2d data 
% set target directory to an individual data file of the form
% 'IQData_Date...'
targetDir = '/Volumes/DATA 2/datadump07142021/AllBufferDump/IQDATA_Date_07-14-2021_Time_14-41-24-30/';
% specify buffers
targetFileAz = 'bufApl4Out_0x0_0x0.data.dm.part'; % azimuth buffer
% load the data 
thisFileNameAz = fullfile(targetDir,targetFileAz); % location of elevation buffer
DmAz = read_lbdump(thisFileNameAz); % read azimuth file
mode = '2D';
%%
% get radius information
rmin = 0;
rmax = (1/DmEl.Info.NumSamplesPerMm)* DmEl.Info.NumRangeSamples;
frameRate = 70;
thetaRange = 90;
thetamax = pi/360*thetaRange;
thetamin = -thetamax;
phiRange = 90;
phimax = pi/360*phiRange;
phimin = -phimax;
cartScalingFactor = DmEl.Info.NumSamplesPerMm/2;
sigma = 3;
%% create USDataClass object
DmEl.startTime = datetime;
outDataSetBiplane = USDataClass2D(DmAz.data,DmEl.startTime,DmAz.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,frameRate,mode);
%%
outDataSetBiplane.scanConvert2D;
%%
outDataSetBiplane.compute2DDecorr_Freq;