%% Example usage of USDataClass object for 2d data 
% set target directory to an individual data file of the form
% 'IQData_Date...'
targetDir = '/Volumes/Data3/Collected Data/2021-8-18_experiment_6/IQDATA_Date_08-18-2021_Time_17-36-47-29';
% specify buffers
targetFileAz = 'bufApl4Out_0x0_0x0.data.dm.pmcr'; % azimuth buffer
% load the data 
thisFileNameAz = fullfile(targetDir,targetFileAz); % location of elevation buffer
DmAz = read_lbdump(thisFileNameAz); % read azimuth file
mode = '2D';
%%
% get radius information
rmin = 0;
rmax = (1/DmAz.Info.NumSamplesPerMm)* DmAz.Info.NumRangeSamples;
frameRate = 70;
thetaRange = 90;
thetamax = pi/360*thetaRange;
thetamin = -thetamax;
phiRange = 90;
phimax = pi/360*phiRange;
phimin = -phimax;
cartScalingFactor1 = DmAz.Info.NumSamplesPerMm/2;
cartScalingFactor2 = DmAz.Info.NumSamplesPerMm;
cartScalingFactor3 = DmAz.Info.NumSamplesPerMm/4;
sigma = 3;
%% create USDataClass object
DmEl.startTime = datetime;
outDataSet2D1 = USDataClass2D(DmAz.data,date,DmAz.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor1,sigma,frameRate,mode);
outDataSet2D2 = USDataClass2D(DmAz.data,date,DmAz.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor2,sigma,frameRate,mode);
outDataSet2D3 = USDataClass2D(DmAz.data,date,DmAz.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor3,sigma,frameRate,mode);
%%
outDataSet2D1.scanConvert2D;
outDataSet2D2.scanConvert2D;
outDataSet2D3.scanConvert2D;
%%
outDataSetBiplane.compute2DDecorr_Freq;