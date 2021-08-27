%% Example usage of USDataClass object for biplane data 
% set target directory to an individual data file of the form
% 'IQData_Date...'
targetDir = '/Volumes/DATA 2/datadump07142021/AllBufferDump/IQDATA_Date_07-14-2021_Time_14-41-24-30/';
% specify buffers
targetFileAz = 'bufApl4Out_0x0_0x0.data.dm.part'; % azimuth buffer
targetFileEl = 'bufApl4Out_0x1_0x0.data.dm.part'; % elevation buffer
% load the data 
thisFileNameAz = fullfile(targetDir,targetFileAz); % location of elevation buffer
thisFileNameEl = fullfile(targetDir,targetFileEl); % location of azimuth buffer
DmEl = read_lbdump(thisFileNameEl); % read elevation file
DmAz = read_lbdump(thisFileNameAz); % read azimuth file
mode = 'biplane';
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
outDataSetBiplane = USDataClass2D({DmAz.data,DmEl.data},DmEl.startTime,{DmAz.Info,DmEl.Info},rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,frameRate,mode);
%%
outDataSetBiplane.scanConvertBiplane;
%%
outDataSetBiplane.computeBiplaneDecorr_Freq;