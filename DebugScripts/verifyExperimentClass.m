%% Example usage of decorrelation scripts
% make sure to add all files in echoDecorr3DMatlab to the path before running this script

% Before starting, the script expects a certain form for the data folders
% Each 'IQData.q..' folder should be in another enclosing folder, which is where you should point the script toward when it asks you to select a folder
% After it processes a folder it will move it to the complete folder
% to rerun the script you have to move the folders back to their original location outside of the 'complete' folder. 
EchoDecorrPkg.Utils.lambdas;
%% Init class
experiment = EchoDecorrPkg.ExperimentClass(); % Create experiment class object
experiment.initDataFolderGUI(); % set target folder, should be one directory above each individual output folder from the scanner
%experiment.initDataFolder('/Users/petergrimm/Documents/EchoDecorrData/Other data/in-vivo/InVivo_pig/2022-3-18_experiment_4')
% Get geometry info
% Manually set
sigma = 3; 
cartScalingFactor = 1; % dr/dx s.t each voxel is 1mmx1mmx1mm
% Info gathered from scanner
infoOut = experiment.getInitInfo();
frameRate = infoOut(1);
elevationRange = infoOut(3);
azimuthRange = infoOut(4);
elevMax = deg2rad(elevationRange/2);
elevMin = -elevMax;
azimMax = deg2rad(azimuthRange/2);
azimMin = -azimMax;
% set fields in object
experiment.setImagingParams(azimMin,azimMax,elevMin,elevMax,cartScalingFactor,frameRate,sigma)
experiment.getInitDataSet_c(); % get first data set from folder
%% set ROI information
elevLoc = 0; % center of ROI in elevation, centered at 0
azimLoc = 0; % center of ROI in azimuth, centered at 0
depthLoc = 30; % center of ROI in depth, distance from transducer
% the script lets you define an arbitrary ellipsoid ROI, set all equal for a sphere
elevR = 10; 
azimR = 10; 
depthR = 10; 
% the ellipsoid can be rotated using these controlls, set to 0 to not rotate
betaAng = 0; 
alphaAng = 0; 
gammaAng = 0; 
% another version lets you use the intersection of two ellipsoids as a
% region, don't worry about this unless you want to use this feature, se to 0 otherwise
elevR_in = 0; 
azimR_in = 0; 
depthR_in = 0; 
%%
experiment.setIBSparam(-1000, 1000, -1000,1000,-1000,1000)
experiment.setROIParams(elevLoc,azimLoc,depthLoc,elevR,azimR,depthR,elevR_in,azimR_in,depthR_in,alphaAng,gammaAng,betaAng);
%%
numSham = 3; 
for i =1:numSham
    if ~isempty(experiment.getWaitingDataSets)
        experiment.nextShamDataSet
    end
end
%%
experiment.initMotionCorrection(3)
%%
while experiment.newDataSetReady()
    experiment.nextDataSet()
end
%%
%%
noMotCorrDecGUI = load('GUI_apr3_exp2_nomotcorr_3sham.mat');
motCorrDecGUI=load('GUI_apr3_exp2_motcorr_3sham.mat');
load('FullExp_03-Apr-2023_2.mat');
%%
tau=experiment.interFrameTime*1000;
%%
instDecLocal=map(@(x) x.getFormattedDec(struct('local',true,'global',false)), ...
                        experiment.ultrasoundDataSeries);
instDecGlobal=map(@(x) x.getFormattedDec(struct('local',true,'global',true))/x.tau, ...
                        experiment.ultrasoundDataSeries);
cumDecSham=mapreduce(@(x,y) max(x,y), instDecLocal(1:numSham));
motionCorrDecorr=map(@(x) x.getMotionCorrectedDecorr(cumDecSham)/x.tau, ...
                          experiment.ultrasoundDataSeries);

cumMoCorDec=mapreduce(@(x,y) max(x,y), motionCorrDecorr(numSham:end));
cumNoMotDec=mapreduce(@(x,y) max(x,y), instDecGlobal(numSham:end));
%%

figure(1);
subplot(3,3,1),imagesc(log10(cumDecSham(:,:,floor(end/2))),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative sham, non-GUI script');
subplot(3,3,2),imagesc(log10(cumNoMotDec(:,:,floor(end/2))),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr non-GUI, w/o mot corr');
subplot(3,3,3),imagesc(log10(cumMoCorDec(:,:,floor(end/2))),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr non-GUI, w/mot corr');
subplot(3,3,4),imagesc(log10(motCorrDecGUI.cumShamDecorr(:,:,floor(end/2))/tau),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative sham decorr GUI');
subplot(3,3,5),imagesc(log10(noMotCorrDecGUI.cumDecorr(:,:,floor(end/2))/tau),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr GUI, w/o mot corr');
subplot(3,3,6),imagesc(log10(noMotCorrDecGUI.cumDecorr(:,:,floor(end/2))),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr GUI, w/mot corr');
subplot(3,3,9),imagesc(log10(outDat.decorr(:,:,floor(end/2))/tau),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr output file, /w mot corr');
%subplot(2,3,6),imagesc(log10(cumMoCorDec(:,:,floor(end/2))),[-3.5,-1]);axis image;colormap("hot"); title('Cumulative decorr, w/motion correction');
