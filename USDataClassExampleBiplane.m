% Example usage of USDataClass object 
% requires compiled c MEX files 
%fileName = mfilename('fullpath');
%            addpath(genpath(fileName(1:end-length(mfilename('class')))));
%thisFileDir = uigetdir(); % point this towards the target data directory
%thisFileName = fullfile(thisFileDir,'bufApl0Out_0x0_0x0.data.dm.pmcr');
targetDir = '/Volumes/DATA 2/datadump07142021/AllBufferDump/IQDATA_Date_07-14-2021_Time_14-41-24-30/';
targetFile = 'bufApl4Out_0x1_0x0.data.dm.part';
targetFile2 = 'bufApl4Out_0x0_0x0.data.dm.part';
thisFileName = fullfile(targetDir,targetFile);
thisFileName2 = fullfile(targetDir,targetFile2);
Dm = read_lbdump(thisFileName2); % call memory mapped read function (requires MEX function)
Dm2 = read_lbdump(thisFileName); % call memory mapped read function (requires MEX function)
%%
% get radius information
rmin = 0;
rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
frameRate = 87;
thetaRange = 90;
thetamax = pi/360*thetaRange;
thetamin = -thetamax;

cartScalingFactor = Dm.Info.NumSamplesPerMm/2;
sigma = 3;
% create USDataClass object
Dm.startTime = datetime;
outDataSetBiplane = USDataClass2D({Dm.data,Dm2.data},Dm.startTime,{Dm.Info,Dm2.Info},rmin,rmax,thetamin,thetamax,cartScalingFactor,sigma,frameRate);
%%
outDataSetBiplane.scanConvertBiplane;
%%
outDataSetBiplane.computeBiplaneDecorr_Freq;
%%
biplaneB1 = outDataSetBiplane.rawData_cart{1};
biplaneB2 = outDataSetBiplane.rawData_cart{2};
biplaneD1 = outDataSetBiplane.decorr{1};
biplaneD2 = outDataSetBiplane.decorr{2};
figure(2), imagesc(log10(abs(biplaneB1(:,:,1))));
colormap(gray)
axis image
figure(3), imagesc(log10(abs(biplaneB2(:,:,1))));
colormap(gray)
axis image
figure(4), imagesc(log10((biplaneD1(:,:))));
axis image
figure(5), imagesc(log10((biplaneD2(:,:))));

axis image