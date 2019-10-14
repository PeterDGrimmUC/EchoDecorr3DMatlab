classdef ExperimentClass < handle
    %EXPERIMENTCLASS: Performs processess on data sets for an experiment
    %  organizes decorrelation code for a simple to use and expandable
    %  interface
    %  designed to be easily accessed for a GUI application 
    % forms the 'Model-Controller' element in the model view controller architecture
    properties
        % machine state variables 
        machineState;
        % init
        initDataSet; 
        % main arrays
        ultrasoundDataSeries; 
        decorrelationMapSeries;
        decorrelationMapSeriesROI;
        cumulativeDecorr; 
        cumulativeDecorrROI;
        decorrSumSeries; 
        decorrSumSeriesROI;
        decorrAverageSeries;
        decorrAverageSerisROI;
        decorrVolume; 
        averageDecorr; 
        % ultrasound data parameters 
        rmin;
        rmax;
        cartScalingFactor;
        sigma; 
        interFrameTime; 
        thetamin;
        thetamax;
        phimin;
        phimax; 
        decorrThresh;
        phiRange;
        thetaRange;
        framerate;
        % experiment parameters
        numDataSets;
        dataFolder; 
        
        activeFolder;
        activeFolderDir; 
        numVolumes; 
        defaultDataFileName;
        totalThresh; 
        totalThreshVolume; 
        inSerialString; 
        outSerialString; 
        outSerialObj;
        inSerialObj; 
        experimentState = 0; 
        ROIVoxelNum;
        ROI_xRange; 
        ROI_yRange; 
        ROI_zRange;
        ROI_ellipPoints; 
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
    end
    
    methods
        % Constructor 
        function obj = ExperimentClass(obj)
            % set machine state to 0
            obj.machineState = 0; 
            obj.defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
        end
        function reset(obj)
            obj.machineState = 0; 
            obj.ultrasoundDataSeries = []; 
            obj.decorrelationMapSeries = [];
            obj.cumulativeDecorr = []; 
            obj.decorrSumSeries = []; 
            obj.decorrSumSeriesROI = []; 
            obj.decorrVolume = []; 
            obj.averageDecorr = []; 
        end
        function ExperimentClassSetParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thissigma,thisinterFrameTime,thisdecorrthresh,thistotalThreshVolume)
            obj.cartScalingFactor = thiscartScalingFactor;
            obj.sigma = thissigma; 
            obj.interFrameTime = thisinterFrameTime; 
            obj.thetamin = thisthetamin;
            obj.thetamax = thisthetamax;
            obj.phimin = thisphimin;
            obj.phimax = thisphimax; 
            obj.decorrThresh = thisdecorrthresh;
            obj.defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
        end
        function setControlParams(obj,myThresh, mySigma)
            obj.sigma = mySigma; 
            obj.decorrThresh = myThresh; 
        end
        function setImagingParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thisinterFrameTime)
            %EXPERIMENTCLASS Construct an instance of this class
            %   Detailed explanation goes here
            obj.cartScalingFactor = thiscartScalingFactor;
            obj.interFrameTime = thisinterFrameTime; 
            obj.thetamin = thisthetamin;
            obj.thetamax = thisthetamax;
            obj.phimin = thisphimin;
            obj.phimax = thisphimax; 
            obj.defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
        end
        function setROIParams(obj,myx0,myy0,myz0,myr0,myr1,myr2,myr0_in,myr1_in,myr2_in,myalpha,mygamma,mybeta)
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
        function obj = setRoiEllipsParams(obj,myx0,myy0,myz0,myr0,myr1,myr2)
            obj.ROIx0 = myx0;
            obj.ROIy0 = myy0;
            obj.ROIz0 = myz0;
            obj.ROIr0 = myr0;
            obj.ROIr1 = myr1;
            obj.ROIr2 = myr2;
        end
        function outVec = computePointsInROIEllipse(obj,index)
            %data_size = size(obj.decorrelationMapSeries(index));
            [x_grid,y_grid,z_grid] = ndgrid(obj.ultrasoundDataSeries(index).x_range,obj.ultrasoundDataSeries(index).y_range,obj.ultrasoundDataSeries(index).z_range);
            outVec = find(x_grid);
        end
        function getInitDataSet(obj)
            nextDataSet = obj.getNextDataSetFolder();
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.initDataSet.scanConv_Frust();
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range; 
            end
        end
        
        function outDataSet = parseDataFromDir(obj,thisFileName)
            Dm = read_lbdump(thisFileName);
            obj.rmin = 0;
            obj.rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
            try 
                obj.framerate = Dm.Info.framerate;
                obj.phiRange = Dm.Info.phiRange;
                obj.thetaRange = Dm.Info.thetaRange;
                obj.thetamax = pi/360*obj.thetaRange;
                obj.thetamin = -obj.thetamax;
                obj.phimax = pi/360*obj.phiRange;
                obj.phimin = -obj.phimax;
            catch
                display('Could not read additional info file');
            end
            outDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
        end
        
        function defineROI(obj) 
            xMid = obj.xVec(floor(end/2));
            yMid = obj.yVec(floor(end/2));
            zMid = obj.zVec(floor(end/2));
            diffX = abs(obj.xVec(1) - obj.xVec(2));
            diffY = abs(obj.yVec(1) - obj.yVec(2));
            diffZ = abs(obj.zVec(1) - obj.zVec(2));
            [xGrid,yGrid,zGrid] = ndgrid(obj.xVec-xMid,obj.yVec-yMid,obj.zVec-zMid);
            validPoints = find(((xGrid).^2./obj.ROIr0^2 + (yGrid).^2./obj.ROIr1^2 + (zGrid).^2./obj.ROIr2^2)<1);
            finalGrid = zeros(size(xGrid));
            finalGrid(validPoints) = 1;
            finalGrid = reshape(finalGrid,(size(xGrid)));
            finalGrid = imrotate3(finalGrid, obj.ROIAlpha,[1 0 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIBeta,[0 1 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIGamma,[0 0 1],'crop');
            finalGrid = imtranslate(finalGrid, [(obj.ROIx0-xMid)/diffX,(obj.ROIy0-yMid)/diffY,(obj.ROIz0-zMid)/diffZ ]);
            obj.ROIMap = logical(finalGrid); 
            obj.ROIVoxelNum = sum(obj.ROIMap(:)); 
        end
        
        function getDecorrInROI(obj)
            logical(obj.ROIMap); 
        end
        function returnVal = addNextDataSet(obj)
            nextDataSet = obj.getNextDataSetFolder();
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                dataObj = obj.parseDataFromDir(fullfile(dataFolderPath,obj.defaultDataFileName));
                newPath = fullfile(obj.dataFolder,'Complete',nextDataSet.name);
                movefile(dataFolderPath,newPath);
                dataObj.scanConv_Frust();
                dataObj.compute3DDecorr(); 
                dataObj.decorrThresh = obj.decorrThresh;
                if(isempty(obj.cumulativeDecorr))
                    obj.cumulativeDecorr = dataObj.decorr;
                    obj.cumulativeDecorrROI = dataObj.decorr.*obj.ROIMap;
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                else
                    obj.cumulativeDecorr = max(obj.cumulativeDecorr,dataObj.decorr);
                    obj.cumulativeDecorrROI = max(obj.cumulativeDecorrROI,dataObj.decorr.*obj.ROIMap);
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                end
                if(isempty(obj.ultrasoundDataSeries))
                    obj.ultrasoundDataSeries = dataObj;
                else
                    obj.ultrasoundDataSeries = [obj.ultrasoundDataSeries,dataObj]; 
                end
                obj.numDataSets = obj.numDataSets +1;
                returnVal = 1;
            else
                returnVal = -1;  
            end
            
        end
        
        function nextDataSetFolder = getNextDataSetFolder(obj)
            % getNextDataSetFolder
            % gets next (chronologically) data set inside of the target
            % folder. 
            % Returns a dir struct of next data set folder
            dataSetsReady = obj.getWaitingDataSets();
            if(~isempty(dataSetsReady))
                timeVec = arrayfun(@(x)x.datenum,dataSetsReady);
                [~,minInd] = min(timeVec);
                nextDataSetFolder = dataSetsReady(minInd);
            else
                nextDataSetFolder = [];
            end
        end
        
        function dataSetList = getWaitingDataSets(obj)
            folderDir = dir(obj.dataFolder);
            folderDir = folderDir([folderDir.isdir]);
            invalidFolders = {'.','..','Complete','ready'};
            binOut = ones(1,numel(folderDir));
            for invalidFoldN = 1:numel(invalidFolders)
                binOut = ~arrayfun(@(x) strcmp(x.name,invalidFolders(invalidFoldN)),folderDir)' & binOut;
            end
            dataSetList = folderDir(binOut); 
        end
        
        function obj = addNextDataSetViaFilename2(obj, thisFileName) 
            Dm = read_lbdump(thisFileName);
            obj.rmin = 0;
            obj.rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
            try 
                obj.framerate = Dm.Info.framerate;
                obj.phiRange = Dm.Info.phiRange;
                obj.thetaRange = Dm.Info.thetaRange;
                obj.thetamax = pi/360*obj.thetaRange;
                obj.thetamin = -obj.thetamax;
                obj.phimax = pi/360*obj.phiRange;
                obj.phimin = -obj.phimax;
            catch
                display('Could not read additional info file')
            end
            tempDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
            tempDataSet.scanConv_Frust();
            tempDataSet.compute3DDecorr(); 
            tempDataSet.decorrThresh = obj.decorrThresh;
            if(isempty(obj.cumulativeDecorr))
                obj.cumulativeDecorr = tempDataSet.decorr;
            else
                obj.cumulativeDecorr = max(obj.cumulativeDecorr,tempDataSet.decorr);
            end
            obj.decorrSumSeries(obj.numVolumes) = sum(obj.cumulativeDecorr(:)/numel(obj.cumlativeDecorr));
            obj.ultrasoundDataSeries = [obj.ultrasoundDataSeries tempDataSet];
        end
        function obj = addNextDataSetViaFilename(obj, thisFileName)
            % Compute decorr of data set
            Dm = read_lbdump(thisFileName);
            obj.rmin = 0;
            obj.rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
            try 
                obj.framerate = Dm.Info.framerate;
                obj.phiRange = Dm.Info.phiRange;
                obj.thetaRange = Dm.Info.thetaRange;
                obj.thetamax = pi/360*obj.thetaRange;
                obj.thetamin = -obj.thetamax;
                obj.phimax = pi/360*obj.phiRange;
                obj.phimin = -obj.phimax;
            catch
                display('Could not read additional info file')
            end
            tempDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
            tempDataSet.scanConv_Frust();
            tempDataSet.compute3DDecorr(); 
            tempDataSet.decorrThresh = obj.decorrThresh;
            % compute ablated volume
            
            if(isempty(obj.cumulativeDecorr))
                % set initial cumulative decorrelation to the result of the
                % first volume's decorr
                obj.cumulativeDecorr(1).decorr = tempDataSet.decorr; 
                % compute decorrelation sum 
                sizeOfVol = size(tempDataSet.decorr);
                obj.decorrSumSeries = sum(obj.cumulativeDecorr(1).decorr(:))/prod(sizeOfVol(1:3)); 
                % create mask of pixels which exceed the threshold
                obj.decorrelationMapSeries(1).decorrMap = tempDataSet.decorr;
                % remove elements below the threshold
                tempAblatedPoints = find(obj.decorrelationMapSeries(1).decorrMap >= obj.decorrThresh);
                obj.decorrelationMapSeries(1).decorrMap(tempAblatedPoints) = 1;
                %set elements above threshold to 1
                obj.decorrelationMapSeries(1).decorrMap(find(obj.decorrelationMapSeries(1).decorrMap ~= 1)) = 0;   
                % each point above the threshold has a volume of dx^3, so
                % the number of points * dx^3 gives the volume of ablated
                % tissue
                obj.averageDecorr(1) = log10(mean(obj.cumulativeDecorr(1).decorr(:)));
                obj.decorrVolume(1) = .001*(length(tempAblatedPoints))*tempDataSet.dx^3; 
            else
                % find max value between current decorrelation and previous
                % cumulative decorrelation 
                obj.cumulativeDecorr(obj.numVolumes).decorr = max(obj.cumulativeDecorr(obj.numVolumes-1).decorr,tempDataSet.decorr);
                % compute sum 
                sizeOfVol = size(tempDataSet.decorr);
                obj.decorrSumSeries(obj.numVolumes) = sum(obj.cumulativeDecorr(obj.numVolumes).decorr(:))/prod(sizeOfVol(1:3)); 
                % create decorrelation map for current volume 
                obj.decorrelationMapSeries(obj.numVolumes).decorrMap = obj.cumulativeDecorr(obj.numVolumes).decorr;
                tempAblatedPoints = find(obj.decorrelationMapSeries(obj.numVolumes).decorrMap >= obj.decorrThresh);
                obj.decorrelationMapSeries(obj.numVolumes).decorrMap(tempAblatedPoints) = 1;
                obj.decorrelationMapSeries(obj.numVolumes).decorrMap(find(obj.decorrelationMapSeries(obj.numVolumes).decorrMap ~= 1)) = 0;
                % each point above the threshold has a volume of dx^3, so
                % the number of points * dx^3 gives the volume of ablated
                % tissue
                interVal = obj.cumulativeDecorr(obj.numVolumes).decorr(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2));
                obj.decorrSumSeriesROI(obj.numVolumes) = mean(interVal(:));
                obj.averageDecorr(obj.numVolumes) = log10(mean(obj.cumulativeDecorr(obj.numVolumes).decorr(:)));
                
                obj.decorrVolume(obj.numVolumes) = .001*(length(tempAblatedPoints))*tempDataSet.dx^3; % in cm^3
            end
            % append ultrasound data to internal data struct
            obj.ultrasoundDataSeries = [obj.ultrasoundDataSeries tempDataSet];
        
        end
        function obj = initDataFolderGUI(obj)
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
            obj.activeFolderDir = fullDirectory(3:end);
            obj.numVolumes = 1; 
        end
        
        function newFilePresent = checkFolder(obj)
            obj.activeFolderDir  = dir(obj.activeFolder);
            if ismac
                obj.activeFolderDir = obj.activeFolderDir(3:end); 
            else
                obj.activeFolderDir = obj.activeFolderDir(3:end); 
            end
            if(length(obj.activeFolderDir) >= obj.numVolumes)
                pause(1)
                newFilePresent = 1; 
            else
                newFilePresent = 0;
            end
        end
        function nextDataSetInFolder(obj)
            if ispc
                fullPath =strcat(obj.activeFolder,'\',{obj.activeFolderDir(obj.numVolumes).name},'\',obj.defaultDataFileName);
            elseif ismac
                fullPath =strcat(obj.activeFolder,'/',{obj.activeFolderDir(obj.numVolumes).name},'/',obj.defaultDataFileName);
            end
            while(~exist(fullPath{1},'file'))
               pause(.01); 
               display('waiting for file'); 
            end
            obj.addNextDataSetViaFilename2(fullPath{1});
            obj.numVolumes = obj.numVolumes+1; 
        end
        function dataSlice = getDataSlice_cart(obj,direction,set,frame,index)
            switch direction
                case 'z'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).rawData_cart(:,:,index,frame));
                case 'y'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).rawData_cart(:,index,:,frame));
                case 'x'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).rawData_cart(index,:,:,frame));
                otherwise
                    dataSlice = 1; 
            end
        end
        function dataSlice = getDataSlice_decorr(obj,direction,set,frame,index)
            switch direction
                case 'z'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).decorr(:,:,index,frame));
                case 'y'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).decorr(:,index,:,frame));
                case 'x'
                    dataSlice = squeeze(obj.ultrasoundDataSeries(set).decorr(index,:,:,frame));
                otherwise
            end
        end
        function dataSlice = getDataSlice_cumulativeDecorr(obj,direction,set,frame,index)
            switch direction
                case 'z'
                    dataSlice = squeeze(obj.cumulativeDecorr(set).decorr(:,:,index,frame));
                case 'y'
                    dataSlice = squeeze(obj.cumulativeDecorr(set).decorr(:,index,:,frame));
                case 'x'
                    dataSlice = squeeze(obj.cumulativeDecorr(set).decorr(index,:,:,frame));
                otherwise
            end
        end
        
        function dataSlice = getDataSlice_decorrMask(obj,direction,set,frame,index)
            switch direction
                case 'z'
                    dataSlice = squeeze(obj.decorrelationMapSeries(set).decorrMap(:,:,index,frame));
                case 'y'
                    dataSlice = squeeze(obj.decorrelationMapSeries(set).decorrMap(:,index,:,frame));
                case 'x'
                    dataSlice = squeeze(obj.decorrelationMapSeries(set).decorrMap(index,:,:,frame));
                otherwise
            end
        end
        
        function dataSlice = getDataSlice_ROI(obj,direction,set,frame,index)
            subVolume = obj.ultrasoundDataSeries(set).rawData_cart(:,:,:,frame);
            maskVol = zeros(size(subVolume));
            maskVol(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2)) = 1; 
            %subVolume([1:obj.ROI_zRange(1),obj.ROI_zRange(2):end],[1:obj.ROI_yRange(1),obj.ROI_yRange(2):end],[1:obj.ROI_zRange(1),obj.ROI_zRange(2):end]) = 0; 
            subVolume = subVolume .* maskVol; 
            switch direction
                case 'z'
                    dataSlice = squeeze(subVolume(:,:,index,frame));
                case 'y'
                    dataSlice = squeeze(subVolume(:,index,:,frame));
                case 'x'
                    dataSlice = squeeze(subVolume(index,:,:,frame));
                otherwise
            end
        end
        
        function computeDecorrStats(obj, tempDataSet, dataIndex)
            if(isempty(obj.cumulativeDecorr))
                obj.cumulativeDecorr = tempDataSet.decorr; 
                obj.decorrelationMapSeries;
                obj.decorrSumSeries; 
                obj.decorrVolume; 
            else
                obj.cumulativeDecorr = max(obj.cumulativeDecorr,tempDataSet.decorr);
            end
        end
        
        function boolOut = decorrExceedsThresh(obj) 
            if((obj.totalThresh) <= log10(obj.decorrSumSeriesROI(obj.numVolumes-1)))
                boolOut =  1; 
            else
                boolOut =  0; 
            end
        end
        function recomputeDecorr(obj)
            for currentVol = 1:length(obj.ultrasoundDataSeries)
                obj.ultrasoundDataSeries(currentVol).compute3DDecorr(); 
                obj.ultrasoundDataSeries(currentVol).decorrThresh = obj.decorrThresh;
                if(currentVol == 1)
                    obj.cumulativeDecorr(currentVol).decorr = obj.ultrasoundDataSeries(currentVol).decorr;
                    % compute sum 
                    sizeOfVol = size(obj.ultrasoundDataSeries(currentVol).decorr);
                    obj.decorrSumSeries(currentVol) = sum(obj.cumulativeDecorr(currentVol).decorr(:))/prod(sizeOfVol(1:3)); 
                    % create decorrelation map for current volume 
                    obj.decorrelationMapSeries(currentVol).decorrMap = obj.cumulativeDecorr(currentVol).decorr;
                    tempAblatedPoints = find(obj.decorrelationMapSeries(currentVol).decorrMap >= obj.decorrThresh);
                    obj.decorrelationMapSeries(currentVol).decorrMap(tempAblatedPoints) = 1;
                    obj.decorrelationMapSeries(currentVol).decorrMap(find(obj.decorrelationMapSeries(currentVol).decorrMap ~= 1)) = 0;
                    % each point above the threshold has a volume of dx^3, so
                    % the number of points * dx^3 gives the volume of ablated
                    % tissue
                    obj.decorrVolume(currentVol) = .001*(length(tempAblatedPoints))*obj.ultrasoundDataSeries(currentVol).dx^3; % in cm^3
                else
                    obj.cumulativeDecorr(currentVol).decorr = max(obj.cumulativeDecorr(currentVol-1).decorr , obj.ultrasoundDataSeries(currentVol).decorr);
                    % compute sum 
                    sizeOfVol = size(obj.ultrasoundDataSeries(currentVol).decorr);
                    obj.decorrSumSeries(currentVol) = sum(obj.cumulativeDecorr(currentVol).decorr(:))/prod(sizeOfVol(1:3)); 
                    % create decorrelation map for current volume 
                    obj.decorrelationMapSeries(currentVol).decorrMap = obj.cumulativeDecorr(currentVol).decorr;
                    tempAblatedPoints = find(obj.decorrelationMapSeries(currentVol).decorrMap >= obj.decorrThresh);
                    obj.decorrelationMapSeries(currentVol).decorrMap(tempAblatedPoints) = 1;
                    obj.decorrelationMapSeries(currentVol).decorrMap(find(obj.decorrelationMapSeries(currentVol).decorrMap ~= 1)) = 0;
                    % each point above the threshold has a volume of dx^3, so
                    % the number of points * dx^3 gives the volume of ablated
                    % tissue
                    obj.decorrVolume(currentVol) = .001*(length(tempAblatedPoints))*obj.ultrasoundDataSeries(currentVol).dx^3; % in cm^3
                end
            end
        end
        function sendSerialData(obj)
            %pause(3)
            
            fprintf(obj.outSerialObj,'S');
            
        end
        function setUpSerialOutConnection(obj)
            obj.outSerialObj = serial(obj.outSerialString,'BaudRate', 115200);
            fopen(obj.outSerialObj);
        end
        function removeSerialConnection()
            fclose(obj.outSerialObj); 
        end
        function updateROIDataSet(obj)
            for currN = 1:length(obj.ultrasoundDataSeries) 
                interVal = obj.cumulativeDecorr(currN).decorr(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2));
                obj.decorrSumSeriesROI(currN) = mean(interVal(:));
            end
        end
        function initExperiment(obj)
            interVal = obj.cumulativeDecorr(1).decorr(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2));
            obj.decorrSumSeriesROI(1) = mean(interVal(:));
        end
    end
end

