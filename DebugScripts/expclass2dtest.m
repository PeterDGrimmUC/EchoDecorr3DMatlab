a = ExperimentClass2D('2D');
a.initDataFolderGUI()
%%
a.setImagingParams(90,90,70,1,90,3);
%%
a.runOfflineExperiment()
%%
%a.getNextDataSet()