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
        %% imaging properties
        sigma,azAngle,elAngle,depth,cartScalingFactor,frameRate; 
        rmax,rmin,phimin,phimax,thetamin,thetamax;
        ROIPoints, ROIMask; 
        %% control properties
        thresh;
        z0,y0,x0,r0,r1,r2,r3;
        %% serial properties
        outSerialString,inSerialString;
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
    end
    
    methods
        %% constructor
        function obj = ExperimentClass2D(mode)
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
        end
        %% setters
        function setControlParams(obj,thresh)
            obj.thresh = thresh; 
        end
        function setImagingParams(obj, azAngle, elAngle, depth, cartScalingFactor, frameRate,sigma)
            obj.azAngle = azAngle;
            obj.elAngle = elAngle;
            obj.depth = depth;
            obj.cartScalingFactor = cartScalingFactor;
            obj.frameRate = frameRate;
            obj.sigma = sigma;
            obj.rmin = 0;
            obj.rmax = depth;
            obj.thetamin = -obj.azAngle/2;
            obj.thetamax = -obj.azAngle/2;
            obj.phimin = -obj.elAngle/2;
            obj.phimax = -obj.elAngle/2;
        end
        function setROIParams(obj,z0,y0,x0,r0)
            obj.z0 = z0;
            obj.y0 = y0;
            obj.x0 = x0;
            obj.r0 = r0;
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