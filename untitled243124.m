a = ExperimentClass2D('biplane');
a.initDataFolderGUI()
%%
a.setImagingParams(90,90,70,1,90,3);
%%
a.runOfflineExperiment()
%%
%a.getNextDataSet()