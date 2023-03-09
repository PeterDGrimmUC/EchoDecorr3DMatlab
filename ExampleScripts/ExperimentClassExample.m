%% Example usage of decorrelation scripts
% make sure to add all files in echoDecorr3DMatlab to the path before running this script

% Before starting, the script expects a certain form for the data folders
% Each 'IQData.q..' folder should be in another enclosing folder, which is where you should point the script toward when it asks you to select a folder
% After it processes a folder it will move it to the complete folder
% to rerun the script you have to move the folders back to their original location outside of the 'complete' folder. 
%% Init class
experiment = ExperimentClass(); % Create experiment class object
%experiment.initDataFolderGUI(); % set target folder, should be one directory above each individual output folder from the scanner
experiment.initDataFolder('/Users/petergrimm/Documents/EchoDecorrData/Other data/in-vivo/2022-8-24_experiment_4');
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
depthLoc = 15; % center of ROI in depth, distance from transducer
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
experiment.setIBSparam(-1000, 60, -30,30,-30,30)
experiment.setROIParams(elevLoc,azimLoc,depthLoc,elevR,azimR,depthR,elevR_in,azimR_in,depthR_in,alphaAng,gammaAng,betaAng);

%% process remaining data
% run this function in a loop, it will check for a new data set and add it
% once there are no folders remaining, it returns -1
while(experiment.newDataSetReady())
    experiment.nextDataSet();
end
%% final output
% this version cleans up the final output to match room coordinates after completion
% the newer version does this at the beginning instead
finalOutput = experiment.saveObj();