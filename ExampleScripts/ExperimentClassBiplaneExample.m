%% example script for biplane decorrelation computation of an experiment with the SC2000 scanner
experimentNumber = 3; 
experiment = ExperimentClass2D('biplane',experimentNumber); % first argument '2D' or 'biplane', second argument: experiment number
% provide the folder that contains your data
folderName = '/Volumes/DATA 2/Data08182021/2021-8-18_experiment_9';
% set it in the object
experiment.initDataFolder(folderName)
%% parameters
cartScalingFactor = 1; % dr/dx -> spatial step in radial direction, over step in cartesian direction 
sigma = 3; % smoothing window
% roi parametersOI i
z0 = 10; % center of Rn depth
x0 = 10; % center of ROI in elevation
y0 = 10; % center of ROI in azimuth
r0 = 10; % radius of ROI
experiment.setImagingParams(cartScalingFactor, sigma) % set parameters
experiment.getInitDataSet(); % get first data set to set geometry
experiment.setROIParams(z0,y0,x0,r0); % set ROI geometry
experiment.runOnlineExperiment() % loop through files to process data
%%
experiment.saveDat(); 