%% 
experiment = ExperimentClass2D('biplane');
folderName = '/Volumes/DATA 2/Data08182021/2021-8-18_experiment_9';
experiment.initDataFolder(folderName)
%%
azAngle = 90; 
elAngle = 90; 
depth= 60; 
frameRate = 70;
cartScalingFactor = 1; 
sigma = 3; 
z0 = 10; 
x0 = 10; 
y0 = 10; 
r0 = 10; 
experiment.setImagingParams(azAngle, elAngle, depth, cartScalingFactor, frameRate,sigma)
experiment.getInitDataSet(); 
experiment.setROIParams(z0,y0,x0,r0)
experiment.runOfflineExperiment()