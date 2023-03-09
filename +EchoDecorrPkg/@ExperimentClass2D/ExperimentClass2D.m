classdef ExperimentClass2D < handle
    %EXPERIMENTCLASS: Performs processess on data sets for an experiment
    %  organizes decorrelation code for a simple to use and expandable
    %  interface.
    %  Holds arrays of type USDataClass, the data set format for individual
    %  volumes
    %  designed to be easily accessed for a GUI application 
    properties
        %% Internal Properties
        mode,dataFolder,activeFolderDir,targetFiles,plane1FileName,plane2FileName;
        startTime, experimentNumber; 
        %% imaging properties
        sigma,azAngle,elAngle,depth,cartScalingFactor,frameRate; 
        rmax,rmin,phimin,phimax,thetamin,thetamax;
        ROIPoints, ROIMask; 
        %% control properties
        thresh;
        z0,y0,x0,r0,r1,r2,r3;
        %% serial properties
        outSerialString,inSerialString;
        %%
        IBSr,IBStheta,IBSPhi;
        %% Data
        numVolumes;
        dataSeries;
        initDataSet;
        decorrelationMapSeries; 
        cumulativeDecorr; 
        adjCumulativeDecorr; 
        meanDecorrSeries; 
        meanDecorrSeriesAdj;
        meanDecorrSeriesROI;
        meanDecorrSeriesROIAdj;
        voxelStepCart;
    end
    
    methods
        %% constructor
        function obj = ExperimentClass2D(mode,experimentNum)
            obj.mode = mode; 
            obj.targetFiles = {'addParamFile.txt'};
            switch obj.mode
                case '2D'
                    obj.targetFiles{end+1} = 'bufApl4Out_0x0_0x0.data.dm.pmcr';
                case 'biplane'
                    obj.targetFiles{end+1} = 'bufApl4Out_0x0_0x0.data.dm.pmcr';
                    obj.targetFiles{end+1} = 'bufApl4Out_0x1_0x0.data.dm.pmcr';
            end
            obj.plane1FileName = 'bufApl4Out_0x0_0x0.data.dm.pmcr';
            obj.plane2FileName = 'bufApl4Out_0x1_0x0.data.dm.pmcr';
            obj.dataSeries = {};
            obj.experimentNumber = experimentNum;
        end
        %% setters
        function setControlParams(obj,thresh)
            obj.thresh = thresh; 
        end
        function setImagingParams(obj, voxelStepCart, sigma)
            obj.voxelStepCart = voxelStepCart;
            obj.sigma = sigma;
        end
        function setROIParams(obj,z0,y0,x0,r0,IBSr,IBStheta,IBSphi)
            obj.z0 = z0;
            obj.y0 = y0;
            obj.x0 = x0;
            obj.r0 = r0;
            obj.IBSr=IBSr;
            obj.IBSphi=IBSphi;
            obj.IBStheta=IBStheta;
            obj.defineROIMask();
        end
        function setSerialOutName(obj,myname)
            obj.outSerialString = myname; 
        end
        function setSerialInName(obj,myname)
            obj.inSerialString = myname; 
        end
        %% getters
        %% Interaction
        function obj = initDataFolderGUI(obj)
            basePath = matlabroot;
            obj.dataFolder = uigetdir(basePath);
            mkdir(fullfile(obj.dataFolder,'Complete'));
            obj.numVolumes = 1; 
        end
        function obj = initDataFolder(obj,dirName)
            obj.dataFolder = dirName; 
            mkdir(fullfile(obj.dataFolder,'Complete'));
            obj.numVolumes = 1; 
        end
        function saveDat(obj)
            dateStr = string(datetime(obj.startTime(),'Format', 'MM-dd-yyyy'));
            fileName = strcat(dateStr,"_experiment_",string(obj.experimentNumber),'.mat');
            data = obj.createSaveObj;
            save(fileName,'data');
        end
        function outDat = createSaveObj(obj)
            outDat = struct;
            outDat.mode = obj.mode;
            outDat.dataFolder = obj.dataFolder;
            outDat.activeFolderDir = obj.activeFolderDir;
            outDat.targetFiles = obj.targetFiles;
            outDat.plane1FileName = obj.plane1FileName;
            outDat.plane2FileName = obj.plane2FileName;
            outDat.startTime = obj.startTime;
            outDat.experimentNumber = obj.experimentNumber;
            outDat.sigma = obj.sigma;
            outDat.azAngle = obj.azAngle;
            outDat.elAngle = obj.elAngle;
            outDat.depth = obj.depth;
            outDat.cartScalingFactor = obj.cartScalingFactor;
            outDat.voxelStepCart = obj.voxelStepCart;
            outDat.frameRate = obj.frameRate;
            outDat.rmax = obj.rmax;
            outDat.rmin = obj.rmin;
            outDat.phimin = obj.phimin;
            outDat.phimax = obj.phimax;
            outDat.thetamin = obj.thetamin;
            outDat.thetamax = obj.thetamax;
            outDat.ROIPoints = obj.ROIPoints;
            outDat.ROIMask = obj.ROIMask;
            outDat.thresh = obj.thresh;
            outDat.z0 = obj.z0;
            outDat.y0 = obj.y0;
            outDat.x0 = obj.x0;
            outDat.r0 = obj.r0;
            outDat.r1 = obj.r1;
            outDat.r2 = obj.r2;
            outDat.r3 = obj.r3;
            outDat.outSerialString = obj.outSerialString;
            outDat.inSerialString = obj.inSerialString;
            outDat.numVolumes = obj.numVolumes;
            outDat.dataSeries = obj.dataSeries;
            outDat.initDataSet = obj.initDataSet;
            outDat.decorrelationMapSeries = obj.decorrelationMapSeries;
            outDat.cumulativeDecorr = obj.cumulativeDecorr;
            outDat.adjCumulativeDecorr = obj.adjCumulativeDecorr;
            outDat.meanDecorrSeries = obj.meanDecorrSeries;
            outDat.meanDecorrSeriesAdj = obj.meanDecorrSeriesAdj;
            outDat.meanDecorrSeriesROI = obj.meanDecorrSeriesROI;
            outDat.meanDecorrSeriesROIAdj = obj.meanDecorrSeriesROIAdj;
            
        end
        %% External
        getInitDataSet(obj);
        getNextDataSet(obj); 
        processDataSet(obj,ind);
        runOfflineExperiment(obj);
        ready=checkNextDataSetReady(obj);
        defineROIMask2D(obj);
        defineROIMaskBiplane(obj);
        defineROIMask(obj);
        updateCumulativeDecorr(obj)
        runOnlineExperiment(obj);
    end
end