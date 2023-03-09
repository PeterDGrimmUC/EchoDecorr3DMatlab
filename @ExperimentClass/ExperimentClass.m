classdef ExperimentClass < handle
    %EXPERIMENTCLASS: Performs processess on data sets for an experiment
    %  organizes decorrelation code for a simple to use and expandable
    %  interface.
    %  Holds arrays of type USDataClass, the data set format for individual
    %  volumes
    %  designed to be easily accessed for a GUI application 
    properties
        % init
        initDataSet; % Initial dataset, used for setting up parameters within the class.
        cumulativeDecorr;  % Cumulative decorrelation map over the entire volume
        cumulativeShamDecorr;
        % main arrays
        ultrasoundDataSeries=[]; % Array containing USDataClass objects, corresponding to a set of recorded volumes
        cumdecorrAverageSeriesROI=[];
        decorrAverageSeries=[];
        decorrAverageSeriesROI=[];
        scanConvLookup; 
        templateFolder;
        fileLUT={'.','..','Complete','ready'};
        defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
        % ultrasound data parameters
        dx % x (elevation) direction voxel length
        dy % y (azimuth) direction voxel length
        dz % z (range) direction voxel length
        dr % r (radius in pyramidal coordinates) direction voxel length
        rmin; % minimum r value
        rmax; % maximum r value
        cartScalingFactor; % dr/dx 
        sigma; % Parameter used for Gaussian window
        interFrameTime; % Time between volume frames
        thetamin; % minimum azimuth angle
        thetamax; % maximum azimuth angle
        phimin; % minimum elevation angle
        phimax; % maximum elevation angle
        decorrThresh; % decorrelation threshold for stopping treatment
        phiRange; % range of elevation values
        thetaRange; % range of azimuth angles
        frameRate; % volumes per second
        % experiment parameters
        dataFolder; % target folder for data
        subRegionROIMap % ROI within minimum subregion for saving on computation
        activeFolder; % Current folder containing decorrelation volumes
        inSerialString; 
        outSerialString; 
        outSerialObj;
        inSerialObj; 
        ROIx0; 
        ROIy0; 
        ROIz0; 
        ROIr0; 
        ROIr1;
        ROIr2;
        ROIr0_in;
        ROIr1_in;
        ROIr2_in;
        xVec;
        yVec;
        zVec; 
        ROIAlpha;
        ROIBeta;
        ROIGamma;
        ROIMap; 
        regionOverlay;        
        timeArr;
        rfDataArr;
        voxelStepCart;
        IBSVoxels;
        IBSrMax;
        IBSrMin;
        IBSElMin;
        IBSElMax;
        IBSAzMin;
        IBSAzMax;
        IBSGeoSet=false;
        isMotionCorrected=false;
        correctedDecorrArg=struct('global',false,'local',true);
        uncorrectedDecorrArg=struct('global',true,'local',true);
        numShamSets=0;
    end
    
    methods
        % Constructor 
        function obj = ExperimentClass(overrideUncorrectedDecorrStruct, overrideCorrectedDecorrStruct)
            %  ExperimentClass: Constructor for experiment class
            %
            %  Constructs ExperimentClass object, takes no arguments
            %
            % Usage:
            %   obj = ExperimentClass()
            %       inputs:
            %          None
            %       outputs:
            %          None

            if (exist('overrideUncorrectedDecorrStruct','var'))
                obj.uncorrectedDecorrArg=overrideUncorrectedDecorrStruct;
            end
            if (exist('overrideCorrectedDecorrStruct','var'))
                obj.correctedDecorrArg=overrideCorrectedDecorrStruct;
            end
            obj.IBSGeoSet=false;
        end
        
        function reset(obj)
            % reset: Resets object to empty
            %
            % Reset the object to empty for use with a new experiment
            %
            % Usage:
            %   reset(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            obj.ultrasoundDataSeries = []; 
            obj.decorrelationMapSeries = [];
            obj.cumulativeDecorr = []; 
            obj.decorrSumSeries = []; 
            obj.decorrSumSeriesROI = []; 
            obj.decorrVolume = []; 
            obj.averageDecorr = []; 
        end

        function setControlParams(obj,myThresh)
            % setControlParams: Set parameters for control
            %
            % Sets the value of the decorrelation threshold for use during experiments
            %
            % Usage:
            %   setControlParams(obj,myThresh)
            %     inputs:
            %        myThresh: Log10 Decorrelation value for threshold within ROI
            %     outputs:
            %        None
            obj.decorrThresh = myThresh; 
        end
        
        function setImagingParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,voxelStepCart,thisFrameRate,thissigma)
            % setImagingParams: Set parameters for ultrasound imaging, data gathered from scanner
            %
            % Sets scanner parameters such as scan angles, depth, interframetime, scale between pyramidal and cartesian coordinates
            %
            % Usage:
            %   setImagingParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thisinterFrameTime,thissigma)
            %     inputs:
            %        thisthetamin: minimum value of azimuthal angle in degrees
            %        thisthetamax: maximum value of azimuthal angle in degrees
            %        thisphimin: minimum value of elevation angle in degrees
            %        thisphimax: maximum value of elevation angle in degrees
            %        thiscartScalingFactor: dr/dx, the scale factor between the voxel size in the radial direction and cartesian directions
            %        thisinterFrameTime: time between successive volumes (s)
            %        thissigma: value of sigma for gaussian window (mm)
            %     outputs:
            %        None
            obj.voxelStepCart = voxelStepCart;
            obj.frameRate = thisFrameRate;
            obj.interFrameTime= 1/thisFrameRate;
            obj.thetamin = thisthetamin;
            obj.thetamax = thisthetamax;
            obj.phimin = thisphimin;
            obj.phimax = thisphimax; 
            obj.defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
            obj.sigma = thissigma; 
        end
        
        function setROIParams(obj,myx0,myy0,myz0,myr0,myr1,myr2,myr0_in,myr1_in,myr2_in,myalpha,mygamma,mybeta)
            % setROIParams: Set parameters for target ROI
            %
            % Sets values used to determine the target ellipsoid ROI
            %
            % Usage:
            %   setROIParams(obj,myx0,myy0,myz0,myr0,myr1,myr2,myr0_in,myr1_in,myr2_in,myalpha,mygamma,mybeta)
            %     inputs:
            %        myx0: center of the ROI in the elevation direction (mm)
            %        myy0: center of the ROI in the azimuth direction (mm)
            %        myz0: center of the ROI in the range direction (mm)
            %        myr0: principle axes of the ellipsoid in the elevation direction (mm)
            %        myr1: principle axes of the ellipsoid in the azimuth direction (mm)
            %        myr2: principle axes of the ellipsoid in the range direction (mm)
            %        myr0_in: principle axes of the internal ellipsoid in the elevation direction (mm) (for use with two ellipsoid mode)
            %        myr1_in: principle axes of the internal ellipsoid in the azimuth direction (mm) (for use with two ellipsoid mode)
            %        myr2_in: principle axes of the internal ellipsoid in the range direction (mm) (for use with two ellipsoid mode)
            %        myalpha: Angle of rotation in elevation direction
            %        mygamma: Angle of rotation in azimuth direction
            %        mybeta: Angle of rotation in range direction
            %     outputs:
            %        None  
            obj.ROIx0 = myx0;
            obj.ROIy0 = myy0;
            obj.ROIz0 = myz0;
            obj.ROIr0 = myr0;
            obj.ROIr1 = myr1;
            obj.ROIr2 = myr2;
            obj.ROIr0_in = myr0_in;
            obj.ROIr1_in = myr1_in;
            obj.ROIr2_in = myr2_in;
            obj.ROIAlpha = myalpha;
            obj.ROIGamma = mygamma; 
            obj.ROIBeta = mybeta; 
            obj.defineROI; 
        end
        function setIBSparam(obj,myIBSrMin,myIBSrMax,myIBSazMin,myIBSazMax,myIBSelMin,myIBSelMax)
            obj.IBSrMax=myIBSrMax;
            obj.IBSrMin=myIBSrMin;
            obj.IBSElMax=myIBSelMax;
            obj.IBSElMin=myIBSelMin;
            obj.IBSAzMax=myIBSazMax;
            obj.IBSAzMin=myIBSazMin;
            
            obj.IBSGeoSet=true;
        end
        function getInitDataSet_c(obj)
            % getInitDataSet: Get initial dataset from folder
            %
            % Selects the first data set in the target folder to use as an initial dataset, geometry will be calibrated based on this given volume
            %
            % Usage:
            %   getInitDataSet_c(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            
            % check for new data set
            % If not yet arrived, keep checking in a loop
            while true
                nextDataSet = obj.getNextDataSetFolder_c();
                if ~isempty(nextDataSet)
                    break;
                end
            end
            % Get path
            dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
            % Get data from file
            obj.initDataSet = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
            % Create precomputed lookup table for scan conversion
            obj.scanConvLookup = obj.initDataSet.scanConv_Generate_c();
            % Apply lookup table to first volume pair to generate cart data
            obj.initDataSet.scanConv_apply_c(obj.scanConvLookup); 
            % Set initial parameters 
            obj.xVec = obj.initDataSet.x_range; 
            obj.yVec = obj.initDataSet.y_range; 
            obj.zVec = obj.initDataSet.z_range;
            obj.dx = obj.initDataSet.dx;
            obj.dy = obj.initDataSet.dy;
            obj.dz = obj.initDataSet.dz;
            obj.dr = obj.initDataSet.dr;
            obj.fileLUT{end+1}=nextDataSet.name;
            obj.cumulativeDecorr=zeros(size(obj.initDataSet.rawData_cart(:,:,:,1)));
            obj.cumulativeShamDecorr=zeros(size(obj.initDataSet.rawData_cart(:,:,:,1)));
        end
        
        function outDataSet = parseDataFromDir_c(obj,thisFileName)
            % parseDataFromDir_c: parses a data set from a given folder
            %
            % Parses data from the siemens SC2000 scanner in a given folder, given as a parameter in the function.
            %
            % Usage:
            %   outDataSet = parseDataFromDir_c(obj,thisFileName)
            %              inputs:
            %                thisFileName: Target file containing the data to be parsed as string
            %             outputs:
            %                outDataSet: A USDataClass object with the data from the provided folder
            Dm = read_lbdump_wrapc(thisFileName); % call memory mapped read function
            % get radius information
            obj.rmin = 0;
            obj.rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
            try 
                obj.frameRate = Dm.Info.framerate;
                obj.phiRange = Dm.Info.phiRange;
                obj.thetaRange = Dm.Info.thetaRange;
                obj.thetamax = pi/360*obj.thetaRange;
                obj.thetamin = -obj.thetamax;
                obj.phimax = pi/360*obj.phiRange;
                obj.phimin = -obj.phimax;
            catch
                disp('Could not read additional info file! Enter information manually');
            end
            % create USDataClass objet
            outDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.voxelStepCart,obj.sigma,obj.interFrameTime);
            if obj.IBSGeoSet
                outDataSet.setIBSParam(obj.IBSrMin,obj.IBSrMax, obj.IBSAzMin,obj.IBSAzMax,obj.IBSElMin,obj.IBSElMax);
            end
        end
        
        function defineROI(obj) 
            % defineROI: Use internal information to create ROI mask
            %
            % Uses information about the volume geometry as well as information about the ROI to create a vector of points within the ROI.
            % This version assumes a spherical ROI and computes it using the definition of a sphere
            %
            % Usage:
            %   defineROI(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            [zGrid, yGrid, xGrid] = ndgrid(obj.initDataSet.z_range,obj.initDataSet.y_range,obj.initDataSet.x_range);
            validPoints = find((xGrid-obj.ROIx0).^2+(yGrid-obj.ROIy0).^2+(zGrid-obj.ROIz0).^2 <= obj.ROIr0^2);
            finalGrid = zeros(size(xGrid));
            finalGrid(validPoints) = 1;
            obj.ROIMap = logical(finalGrid); 
            obj.initDataSet.compute3DDecorr();
        end
       
        function updateDecorrSeries(obj,dataObj)
            decorrIn=dataObj.getFormattedDec(struct('time',true,'local',obj.decStruct.local,'global',obj.decStruct.global));
            obj.updateCumulativeDecorr(decorrIn); 
        end

        function dataObj=processDataSet(obj, targetDirectory)
            dataObj = obj.parseDataFromDir_c(fullfile(targetDirectory,obj.defaultDataFileName)); fclose all;
            dataObj.scanConv_apply_c(obj.scanConvLookup);
            dataObj.computeDecorrTerms(); % compute components of decorrelation (R01,R00,R11, B2, B2_avg) 
                                              % these are properties of dataobj and can be used to compute decorrelation under different definitions 
                                              % call dataObj.getFormattedDec(struct('global',true/false,'local',true/false)) 
        end

        function nextDataSet(obj)
            incomingDataSet=obj.getNextDataSetFolder_c(); targetDirectory = fullfile(obj.dataFolder,incomingDataSet.name);
            obj.fileLUT{end+1}=incomingDataSet.name;
            % process data set
            dataObj=obj.processDataSet(targetDirectory);
            obj.ultrasoundDataSeries = [obj.ultrasoundDataSeries, dataObj];
            if ~obj.isMotionCorrected
                obj.updateCumulativeDecorr(dataObj);
            else
                obj.updateCumulativeMotionCorrectedDecorr(dataObj);
            end
        end
        function initMotionCorrection(obj)
            obj.cumulativeDecorr=zeros(size(obj.cumulativeDecorr));
        end
        function nextShamDataSet(obj)
            incomingDataSet=obj.getNextDataSetFolder_c(); targetDirectory = fullfile(obj.dataFolder,incomingDataSet.name);
            obj.fileLUT{end+1}=incomingDataSet.name;
            % process data set
            dataObj=obj.processDataSet(targetDirectory);
            obj.ultrasoundDataSeries = [obj.ultrasoundDataSeries, dataObj];
            obj.updateCumulativeShamDecorr(dataObj)
            obj.cumulativeDecorr=obj.cumulativeShamDecorr;
        end
        function updateCumulativeDecorr(obj,dataObj)
            decorr=dataObj.getFormattedDec(obj.uncorrectedDecorrArg);
            obj.cumulativeDecorr=max(obj.cumulativeDecorr,decorr);
        end
        function updateCumulativeShamDecorr(obj,dataObj)
            decorr=dataObj.getFormattedDec(obj.correctedDecorrArg);
            obj.cumulativeShamDecorr=max(obj.cumulativeShamDecorr, decorr);
        end
        function updateCumulativeMotionCorrectedDecorr(obj,dataObj)
            decorr=dataObj.getMotionCorrectedDecorr(obj.cumulativeShamDecorr);
            obj.cumulativeDecorr=max(obj.cumulativeDecorr,decorr);
        end
        function success=newDataSetReady(obj)
           % check if a new data set exists and all files are ready
           availDataSets=obj.getWaitingDataSets();
            if ~isempty(availDataSets)
                nextDataSetFolder=obj.getNextDataSetFolder_c();
                if obj.verifyFilesReady(nextDataSetFolder)
                    success=true;
                    return
                end
            end
            success=false;
        end
       function nextDataSetFolder = getNextDataSetFolder_c(obj)
            % getNextDataSetFolder_c: checks the target directory for the next data set
            %
            % Checks the directory for unprocessed data sets, returns the location of the next valid data set folder
            %
            % Usage:
            %   nextDataSetFolder = getNextDataSetFolder_c(obj)
            %                     inputs:
            %                        None
            %                     outputs:
            %                        nextDataSetFolder: Path of next target directory 
            % getNextDataSetFolder
            % gets next (chronologically) data set inside of the target
            % folder. 
            % Returns a dir struct of next data set folder
            dataSetsReady = obj.getWaitingDataSets(); % get datasets which have not been processed
            timeCells = arrayfun(@(x) regexp(x.name,'\d+','match'),dataSetsReady,'UniformOutput',false); %map regex over list of datasets to match all consecutive strings of numbers
            dateTimeArr = cellfun(@(y) posixtime(datetime(str2num(y{3}),str2num(y{1}),str2num(y{2}),str2num(y{4}),str2num(y{5}),str2num(y{6}),str2num(y{7}))),timeCells,'UniformOutput',false); % parse regex output into date
            dateTimeArr = [dateTimeArr{:}]; % convert cell to mat
            if(~isempty(dataSetsReady))
                [~,minInd] = min(dateTimeArr); % find index of oldest unprocessed dataset
                nextDataSetFolder = dataSetsReady(minInd);
            else
                nextDataSetFolder = []; % return an empty array if no new datasets are available
            end
        end
        
        function dataSetList = getWaitingDataSets(obj)
            % getWaitingDataSets: Returns a list of unprocessed data sets
            %
            % List is used to determine which data set will be processed next by other functions
            %
            % Usage:
            %   dataSetList = getWaitingDataSets(obj)
            %               inputs:
            %                  None
            %               outputs:
            %                  None     
            folderDir = dir(obj.dataFolder);
            folderDir = folderDir([folderDir.isdir]);
            invalidFolders = obj.fileLUT;
            binOut = ones(1,numel(folderDir));
            for invalidFoldN = 1:numel(invalidFolders)
                binOut = ~arrayfun(@(x) strcmp(x.name,invalidFolders(invalidFoldN)),folderDir)' & binOut;
            end
            dataSetList = folderDir(binOut); 
        end
        
        function obj = initDataFolderGUI(obj)
            % initDataFolderGUI: Set the target directory for an experiment
            % using the matlab file selection GUI
            %
            % Interactively select a path to extract experiment data from
            % should be one directory above each individual folder output
            % from the scanner
            % Interactive version of 'initDataFolder'
            %
            % Usage:
            %   obj = initDataFolderGUI(obj)
            %       inputs:
            %         None
            %       outputs:
            %         Updated object
            try 
                if ispc
                    basePath = strcat('C:\Users\',getenv('username'),'\Box\SiemensSC2000IQData');
                elseif ismac
                    basePath = strcat('/Users/',getenv('USER'),'/box');
                end
            catch
                basePath = matlabroot;
            end
            obj.activeFolder =  uigetdir(basePath);
            obj.dataFolder = obj.activeFolder; 
            mkdir(fullfile(obj.dataFolder,'Complete'));
            fullDirectory  = dir(obj.activeFolder);
        end
        
        function obj = initDataFolder(obj,dirName)
            % obj : initialize data folder 
            %
            % Initialize data folder non interactively, identical to initDataFolderGUI but given a filename instead of a prompt
            %
            % Usage:
            %   obj = initDataFolder(obj,dirName)
            %       inputs:
            %         dirName: directory target
            %       outputs:
            %         Update object
            
            obj.activeFolder =  dirName;
            obj.dataFolder = obj.activeFolder; 
            mkdir(fullfile(obj.dataFolder,'Complete'));
        end
        
        function boolOut = decorrExceedsThresh(obj) 
            % decorrExceedsThread: Check if the current decorrelation exceeds the set threshold
            %
            % Uses internal variables and the current cumulative average decorrelation within the ROI
            %
            % Usage:
            %   boolOut = decorrExceedsThresh(obj)
            %           inputs:
            %             None
            %           outputs:
            %             boolOut: boolean which is true if the current average decorrelation exceeds the threshold
            if((obj.decorrThresh) <= log10(obj.decorrAverageSeriesROI(end)))
                boolOut =  1; 
            else
                boolOut =  0; 
            end
        end

        function success=sendSerialData(obj)
            % sendSerialData: Sends signal to the RF generator activating circuit
            %
            % Sends the character 'S' over serial to the RF generator activating circuit. The microcontroller listens on its serial port for a given command and activates the pump/release mechanism when it recieves the character 'S'
            %
            % Usage:
            %   sendSerialData(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            try
                fprintf(obj.outSerialObj,'S');
                success=true;
            catch
                success=false;
            end
        end
        
        function setSerialOutName(obj,myname)
            % setSerialOutName: Set the name of the device to be used as the connection to the RF generator circuit.
            %
            % Sets the internal variable 'outSerialString', on windows this will look like 'COM[number]', no brackets
            %
            % Usage:
            %   setSerialOutName(obj,myname)
            %     inputs:
            %       myname: Name of the serial device to use
            %     outputs:
            %       None
            obj.outSerialString = myname; 
        end
        
        function setSerialInName(obj,myname)
            % setSerialInName: sets the name of the device to be used to gather data from the RF generator
            %
            % Sets the internal variable 'inSerialString', on windows this will look like 'COM[number]', no brackets
            %
            % Usage:
            %   setSerialInName(obj,myname)
            %     inputs:
            %       myname: Name of the serial device to use
            %     outputs:
            %       None
            obj.inSerialString = myname; 
        end
        
        function setUpSerialOutConnection(obj)
            % setUpSerialOutConnection: Create matlab object to handle serial output to the RF generator controlling device
            %
            % Sets up a serial object using MATLAB's internal serial object, sets the proper baud for communication
            %
            % Usage:
            %   setUpSerialOutConnection(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            obj.outSerialObj = serial(obj.outSerialString,'BaudRate', 115200);
            fopen(obj.outSerialObj);
        end
        
        function setUpSerialInConnection(obj)
            % setUpSerialInConnection: Create matlab object to handle serial output to the RF generator controlling device
            %
            % Sets up a serial object using MATLAB's internal serial object, sets the proper baud rate for communication
            %
            % Usage:
            %   setUpSerialInConnection(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            obj.inSerialObj = SerialClass(obj.inSerialString, 9600);
            obj.inSerialObj = obj.inSerialObj.initSerialBlocks();
        end
        
        function removeSerialConnection(obj)
            % removeSerialConnection: Delete outSerialObj
            %
            %
            % Usage:
            %   removeSerialConnection(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            fclose(obj.outSerialObj); 
        end
  
        function obj = setRFDataArray(obj,rfDataArr)
            %  setRFDataArray: Set the variable 'rfDataArray' (legacy)
            %
            %
            % Usage:
            %   obj = setRFDataArray(obj,rfDataArr)
            obj.rfDataArr = rfDataArr;
        end
        
        function outObj = saveObj(obj)
            % saveObj: Create an object containing all relevant information to save for later use
            %
            % Creates a matlab structure to save all relevant information pertaining to the experiment, saving matlab objects often does not work so this is neccessary 
            %
            % Usage:
            %   outObj = saveObj(obj)
            %          inputs:
            %           None
            %         outputs:
            %           Object that contains all relevant information 
            outObj.dx = obj.initDataSet.dx;
            outObj.dy = obj.initDataSet.dy;
            outObj.dz = obj.initDataSet.dz;
            outObj.rmax = obj.initDataSet.rmax;
            outObj.rmin = obj.initDataSet.rmin;
            outObj.thetamax = obj.initDataSet.thetamax;
            outObj.thetamin = obj.initDataSet.thetamin;
            outObj.phimax = obj.initDataSet.phimax;
            outObj.phimin = obj.initDataSet.phimin;
            outObj.xmin = obj.initDataSet.xMin;
            outObj.xmax = obj.initDataSet.xMax;
            outObj.ymin = obj.initDataSet.yMin;
            outObj.ymax = obj.initDataSet.yMax;
            outObj.zmin = obj.initDataSet.zMin;
            outObj.zmax = obj.initDataSet.zMax;
            outObj.timeArr = arrayfun(@(x)x.time, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instibs = arrayfun(@(x)(x.ibs), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instdecorr = arrayfun(@(x) x.decorr, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.Bmode = arrayfun(@(x) x.rawData_cart, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.decorr = (obj.cumulativeDecorr); 
            outObj.decorrThresh = obj.decorrThresh; 
            outObj.ROIMap = obj.ROIMap;
            outObj.folderNames = arrayfun(@(x)x.folderName, obj.ultrasoundDataSeries, 'UniformOutput', false); 
        end
        
        function outObj = saveObj_withrf(obj,rfDataArr)
            % saveObj_withrf: Create an object containing all relevant information to save for later use, with rf data
            %
            % Creates a matlab structure to save all relevant information pertaining to the experiment, saving matlab objects often does not work so this is neccessary 
            %
            % Usage:
            %   outObj = saveObj_withrf(obj,rfDataArr)
            %          inputs:
            %           None
            %         outputs:
            %           outObj: object that contains all relevant information
            % need inst decorr sets, scan converted volumes, imaging
            % settings, timestamp
            outObj.dx = obj.initDataSet.dx;
            outObj.dy = obj.initDataSet.dy;
            outObj.dz = obj.initDataSet.dz;
            outObj.rmax = obj.initDataSet.rmax;
            outObj.rmin = obj.initDataSet.rmin;
            outObj.thetamax = obj.initDataSet.thetamax;
            outObj.thetamin = obj.initDataSet.thetamin;
            outObj.phimax = obj.initDataSet.phimax;
            outObj.phimin = obj.initDataSet.phimin;
            outObj.xmin = obj.initDataSet.xMin;
            outObj.xmax = obj.initDataSet.xMax;
            outObj.ymin = obj.initDataSet.yMin;
            outObj.ymax = obj.initDataSet.yMax;
            outObj.zmin = obj.initDataSet.zMin;
            outObj.zmax = obj.initDataSet.zMax;
            outObj.timeArr = arrayfun(@(x)x.time, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instibs = arrayfun(@(x)x.ibs, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instdecorr = arrayfun(@(x)x.decorr, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.Bmode = arrayfun(@(x)x.rawData_cart, obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.decorr = obj.cumulativeDecorr; 
            outObj.decorrThresh = obj.decorrThresh; 
            outObj.folderNames = arrayfun(@(x)x.folderName, obj.ultrasoundDataSeries, 'UniformOutput', false); 
            outObj.rfDataArr = rfDataArr;
            outObj.ROIMap = obj.ROIMap;
        end
        
        function outDat = getTimeArr(obj)
            % outDat : get time series from ultrasound files
            %
            % Gets the time of each ultrasound volume pair 
            %
            % Usage:
            %   outDat = getTimeArr(obj)
            %          inputs:
            %           None
            %         outputs:
            %           outDat: cell of times
            outDat = arrayfun(@(x)x.time, obj.ultrasoundDataSeries,'UniformOutput',false);
        end
    end
    methods (Static)
        function succ = verifyFilesReady(nextDataSet)
            fileCells = {'addParamFile.txt', 'alfconfiga0.pmcr', 'apiconfiga0.pmcr', 'aqiconfiga0.pmcr', 'ariconfiga0.pmcr', 'bbfconfiga0.pmcr', 'bufApl0Out_0x0_0x0.data.dm.pmcr', 'bufApl0Out_0x0_0x0.info.txt', 'demodconfiga0.pmcr', 'dsfconfiga0.pmcr', 'dsfconfiga1.pmcr', 'factorygainconfiga0.pmcr', 'imagestatisticsconfiga0.pmcr', 'lsynthconfiga0.pmcr', 'patientcompressionconfig.pmcr', 'patientgainconfiga0.pmcr', 'phaseadjustconfiga0.pmcr', 'psynthconfiga0.pmcr', 'rangeadjustconfiga0.pmcr', 'rrfconfiga0.pmcr', 'scaleadjustconfiga0.pmcr'};
            dir2check = dir(fullfile(nextDataSet.folder,nextDataSet.name));
            dir2check = {dir2check.name};
            checkExists = @(strIn) any(cellfun(@(currString) strcmp(strIn,currString), dir2check));
            succ = all(cellfun(checkExists,fileCells));
            if succ
                disp(strcat('Transfer complete. Folder: ',nextDataSet.name));
            end
        end
        function volOut = fixvolume(vol)
            % fixvolume: Fix volume to match room coordinates (legacy)
            %
            % 
            %
            % Usage:
            %   volOut = fixvolume(obj,vol)
            %          inputs:
            %            vol: Volume to fix
            %         outputs:
            %            volOut: fixed volume
            for j = 1:size(vol,4)
                temp = permute(squeeze(vol(:,:,:,j)),[3,2,1]); % permute to same layout as mask data
                temp = flipdim(temp,2); % flip dim from right to left -> left to right 
                temp = flipdim(temp,3); % flip dim from top to bottm -> bottom to top 
                volOut(:,:,:,j) = temp; 
            end
        end
    end
end

