classdef ExperimentClass < handle
    %EXPERIMENTCLASS: Performs processess on data sets for an experiment
    %  organizes decorrelation code for a simple to use and expandable
    %  interface.
    %  Holds arrays of type USDataClass, the data set format for individual
    %  volumes
    %  designed to be easily accessed for a GUI application 
    properties
        % machine state variables 
        machineState;
        % init
        initDataSet; % Initial dataset, used for setting up parameters within the class.
        % main arrays
        ultrasoundDataSeries; % Array containing USDataClass objects, corresponding to a set of recorded volumes
        decorrelationMapSeries; % Decorrelation data 
        decorrelationMapSeriesROI; % Decorrelation data within specified ROI
        cumulativeDecorr;  % Cumulative decorrelation map over the entire volume
        cumulativeDecorrROI; % Cumulative decorrelation map in ROI
        decorrSumSeries; % 
        decorrSumSeriesROI;
        decorrAverageSeries;
        decorrAverageSeriesROI;
        decorrVolume; 
        averageDecorr; 
        subRegionMap;
        scanConvLookup; 
        templateFolder; 
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
        framerate; % volumes per second
        % experiment parameters
        numDataSets; % Current number of data sets
        dataFolder; % target folder for data
        subRegionROIMap % ROI within minimum subregion for saving on computation
        activeFolder; % Current folder containing decorrelation volumes
        activeFolderDir; % File contents of activeFolder
        numVolumes; % current number of volumes
        defaultDataFileName; % 
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
        xVec_sub;
        yVec_sub;
        zVec_sub; 
        ROIAlpha;
        ROIBeta;
        ROIGamma;
        ROIMap; 
        ROIMapSubregion; 
        subRegionRbounds;
        subRegionThetabounds;
        subRegionPhibounds;
        subRegionRboundsi;
        subRegionThetaboundsi;
        subRegionPhiboundsi;
        subRegionXbounds;
        subRegionYbounds;
        subRegionZbounds;
        subRegionXRange;
        subRegionYRange;
        subRegionZRange;
        regionOverlay;        
        timeArr;
        rfDataArr;
    end
    
    methods
        % Constructor 
        function obj = ExperimentClass()
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
            obj.defaultDataFileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr'; % Sets target file name
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
        
        function setImagingParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thisinterFrameTime,thissigma)
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
            obj.cartScalingFactor = thiscartScalingFactor;
            obj.interFrameTime = thisinterFrameTime; 
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
            nextDataSet = obj.getNextDataSetFolder_c();
            % If not yet arrived, keep checking in a loop
            while isempty(nextDataSet)
                nextDataSet = obj.getNextDataSetFolder_c();
            end
            % Check that all files have been transferred
            while(~ExperimentClass.verifyFilesReady(nextDataSet)); end
            % Get path
            dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
            % Get data from file
            obj.initDataSet = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
            % Create precomputed lookup table for scan conversion
            obj.scanConvLookup = obj.initDataSet.scanConv_Generate_c();
            % Apply lookup table to first volume pair to generate cart data
            obj.initDataSet.scanConv_apply_c(obj.scanConvLookup); 
            % Set initial parameters 
            obj.numVolumes = 0; 
            obj.xVec = obj.initDataSet.x_range; 
            obj.yVec = obj.initDataSet.y_range; 
            obj.zVec = obj.initDataSet.z_range;
            obj.dx = obj.initDataSet.dx;
            obj.dy = obj.initDataSet.dy;
            obj.dz = obj.initDataSet.dz;
            obj.dr = obj.initDataSet.dr;
            obj.numDataSets = 1; 
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
                obj.framerate = Dm.Info.framerate;
                obj.phiRange = Dm.Info.phiRange;
                obj.thetaRange = Dm.Info.thetaRange;
                obj.thetamax = pi/360*obj.thetaRange;
                obj.thetamin = -obj.thetamax;
                obj.phimax = pi/360*obj.phiRange;
                obj.phimin = -obj.phimax;
            catch
                disp('Could not read additional info file!');
            end
            % create USDataClass objet
            outDataSet = USDataClass(Dm.data,Dm.startTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
        end
        
        function defineROI2(obj) 
            % defineROI2: Use internal information to create ROI mask
            %
            % Uses information about the volume geometry as well as information about the ROI to create a vector of points within the ROI
            % This version works on an arbitrary ellipsoid, it defines the axes as centered around 0 and uses the definition of an ellipsoid to create the region
            % this is then translated to match the volume geomtry, and rotated to match the provided rotation information
            %
            % Usage:
            %   defineROI2(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            xMid = obj.initDataSet.x_range(floor(end/2));
            yMid = obj.initDataSet.y_range(floor(end/2));
            zMid = obj.initDataSet.z_range(floor(end/2));
            diffX = abs(obj.initDataSet.x_range(1) - obj.initDataSet.x_range(2));
            diffY = abs(obj.initDataSet.y_range(1) - obj.initDataSet.y_range(2));
            diffZ = abs(obj.initDataSet.z_range(1) - obj.initDataSet.z_range(2));
            [zGrid, yGrid, xGrid] = ndgrid(obj.initDataSet.z_range-zMid,obj.initDataSet.y_range-yMid,obj.initDataSet.x_range-xMid);
            validPoints = find(((xGrid).^2./obj.ROIr0^2 + (yGrid).^2./obj.ROIr1^2 + (zGrid).^2./obj.ROIr2^2)<1);
            finalGrid = zeros(size(xGrid));
            finalGrid(validPoints) = 1;
            finalGrid = reshape(finalGrid,(size(xGrid)));
            finalGrid = imrotate3(finalGrid, obj.ROIAlpha,[1 0 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIBeta,[0 1 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIGamma,[0 0 1],'crop');
            finalGrid = imtranslate(finalGrid, [(obj.ROIz0-zMid)/diffZ,(obj.ROIy0-yMid)/diffY,(obj.ROIx0-xMid)/diffX ]);
            obj.ROIMap = logical(finalGrid); 
            obj.ROIVoxelNum = sum(obj.ROIMap(:)); 
            obj.initDataSet.ROIMap = obj.ROIMap;
            %TODO
            %obj.initDataSet.compute3DDecorr_ROI();
            obj.initDataSet.compute3DDecorr_Freq();
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
            obj.ROIVoxelNum = sum(obj.ROIMap(:)); 
            obj.initDataSet.ROIMap = obj.ROIMap;
            %obj.initDataSet.compute3DDecorr_ROI();
            obj.initDataSet.compute3DDecorr_Freq();
        end
        
        function defineGridBounds(obj)
            % defineGridBounds: define bounds for a subregion to save on computation time, often unnessesary due to other optimizations
            %
            % Find the minimum bounds that will contain the entire target region with a margin of 3*sigma, does this computationally due to infeasibility of an analytic expression for an arbitrary rotated ellipsoid
            %
            % Usage:
            %   defineGridBounds(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            xMid = obj.initDataSet.x_range(floor(end/2));
            yMid = obj.initDataSet.y_range(floor(end/2));
            zMid = obj.initDataSet.z_range(floor(end/2));
            diffX = abs(obj.initDataSet.x_range(1) - obj.initDataSet.x_range(2));
            diffY = abs(obj.initDataSet.y_range(1) - obj.initDataSet.y_range(2));
            diffZ = abs(obj.initDataSet.z_range(1) - obj.initDataSet.z_range(2));
            [xGrid,yGrid,zGrid] = ndgrid(obj.initDataSet.x_range-xMid,obj.initDataSet.y_range-yMid,obj.initDataSet.z_range-zMid);
            validPoints = find(((xGrid).^2./((obj.ROIr0+6*obj.sigma)^2) + (yGrid).^2./((obj.ROIr1+6*obj.sigma)^2) + (zGrid).^2./((obj.ROIr2+6*obj.sigma)^2))<1);
            finalGrid = zeros(size(xGrid));
            finalGrid(validPoints) = 1;
            finalGrid = reshape(finalGrid,(size(xGrid)));
            finalGrid = imrotate3(finalGrid, obj.ROIAlpha,[1 0 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIBeta,[0 1 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIGamma,[0 0 1],'crop');
            finalGrid = imtranslate(finalGrid, [(obj.ROIx0-xMid)/diffX,(obj.ROIy0-yMid)/diffY,(obj.ROIz0-zMid)/diffZ ]);
            finalGrid = logical(finalGrid);
            pts = find(finalGrid == 1); 
            [xGrid,yGrid,zGrid] = ndgrid(obj.initDataSet.x_range,obj.initDataSet.y_range,obj.initDataSet.z_range);
           
            R = sqrt(xGrid.^2 + yGrid.^2 + zGrid.^2);
            Theta = yGrid./(sqrt(zGrid.^2 + yGrid.^2));
            Phi = xGrid./(sqrt(R.^2 - yGrid.^2));
            ROIR = R(pts); maxR = max(ROIR); minR = min(ROIR);
            ROITheta = Theta(pts); maxTheta = max(ROITheta); minTheta = min(ROITheta);
            ROIPhi = Phi(pts); maxPhi = max(ROIPhi); minPhi = min(ROIPhi);
            
            sizeAz = size(obj.initDataSet.rawData,2);
            sizeEl = size(obj.initDataSet.rawData,3);
            obj.dr = 1/obj.initDataSet.InfoFile.NumSamplesPerMm;         % range (mm)
            obj.rmin = obj.initDataSet.rmin;
            obj.rmax = obj.initDataSet.rmax;
            RVec = obj.rmin:obj.dr:obj.rmax;
            muVec = linspace(sin(obj.thetamin),sin(obj.thetamax), sizeAz);
            nuVec = linspace(sin(obj.phimin),sin(obj.phimax), sizeEl);
           
            
            obj.subRegionRbounds = [minR,maxR];
            obj.subRegionThetabounds = [minTheta,maxTheta];
            obj.subRegionPhibounds = [minPhi,maxPhi];
            [~,minRi] = min(abs(minR-RVec));
            [~,maxRi] = min(abs(maxR-RVec));
            [~,minThetai] = min(abs(minTheta-muVec));
            [~,maxThetai] = min(abs(maxTheta-muVec));
            [~,minPhii] = min(abs(minPhi-nuVec));
            [~,maxPhii] = min(abs(maxPhi-nuVec));
            
            obj.subRegionRboundsi = [minRi,maxRi];
            obj.subRegionThetaboundsi = [minThetai,maxThetai];
            obj.subRegionPhiboundsi = [minPhii,maxPhii];
            %obj.ROIMap = obj.ROIMap(xMini:xMaxi,yMini:yMaxi,zMini:zMaxi);
            %obj.subRegionROIMap = obj.ROIMap(minRi:maxRi,minThetai,maxThetai,minPhii,maxPhii);
            %obj.subRegionMap = zeros(size(obj.ROIMap));
            %obj.subRegionMap(minRi:maxRi,minThetai,maxThetai,minPhii,maxPhii) = 1; 
            rmin = obj.subRegionRbounds(1);
            rmax = obj.subRegionRbounds(2);
            thetamin = obj.subRegionThetabounds(1);
            thetamax = obj.subRegionThetabounds(2);
            phimin = obj.subRegionPhibounds(1);
            phimax = obj.subRegionPhibounds(2);
            rV = obj.subRegionRboundsi(1):obj.subRegionRboundsi(2);
            thetaV = obj.subRegionThetaboundsi(1):obj.subRegionThetaboundsi(2);
            phiV = obj.subRegionPhiboundsi(1):obj.subRegionPhiboundsi(2);
            tempDataSet = USDataClass(obj.initDataSet.rawData,obj.initDataSet.time, obj.initDataSet.InfoFile,rmin,rmax,thetamin,thetamax,phimin,phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
            tempDataSet.scanConv_Frust(); 
            [~,xMini] = min(abs(tempDataSet.x_range(1)-obj.initDataSet.x_range));
            [~,yMini] = min(abs(tempDataSet.y_range(1)-obj.initDataSet.y_range));
            [~,zMini] = min(abs(tempDataSet.z_range(1)-obj.initDataSet.z_range));
            xRa = xMini:xMini+numel(tempDataSet.x_range)-1;
            yRa = yMini:yMini+numel(tempDataSet.y_range)-1;
            zRa = zMini:zMini+numel(tempDataSet.z_range)-1;
            obj.ROIMapSubregion = obj.ROIMap(xRa,yRa,zRa);
            obj.regionOverlay = zeros(size(obj.ROIMap)); 
            obj.regionOverlay(xRa,yRa,zRa) = 1; 
            obj.subRegionXRange = xRa; 
            obj.subRegionYRange = yRa; 
            obj.subRegionZRange = zRa; 
            obj.subRegionXbounds = [xRa(1), xRa(end)];
            obj.subRegionYbounds = [yRa(1), yRa(end)];
            obj.subRegionZbounds = [zRa(1), zRa(end)];
            obj.xVec_sub = tempDataSet.x_range;
            obj.yVec_sub = tempDataSet.y_range;
            obj.zVec_sub = tempDataSet.z_range;
        end

        function returnVal = addNextRawDataSet_c(obj)
            % addNextRawData_set_c: Use the c program to add the next data set in the target folder to the object
            %
            % Checks form, adds and processes the next data set (chronologically) to the object. Uses USDataClass built in methods to handle processing, as well as the ROI defined in the ExperimentClass object. 
            %
            % Usage:
            %   returnVal = addNextRawDataSet_c(obj)
            %             inputs:
            %                None
            %             outputs:
            %                None
            nextDataSet = obj.getNextDataSetFolder();
            if obj.numDataSets == []
                obj.numDataSets = 1; 
            end
            if(~isempty(nextDataSet))
                %pause(3)
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                %defineGridBounds(obj)
                
                dataObj = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
                dataObj.folderName = dataFolderPath;
                %toc
                newPath = fullfile(obj.dataFolder,'Complete',nextDataSet.name);
                fclose all;
                movefile(dataFolderPath,newPath);
                %tic
                dataObj.scanConv_apply_c(obj.scanConvLookup);
                dataObj.ROIMap = obj.ROIMap;
                %dataObj.compute3DDecorr_ROI(); 
                dataObj.compute3DDecorr_Freq(); 
                %toc
                dataObj.decorrThresh = obj.decorrThresh;
                if(isempty(obj.cumulativeDecorr))
                    %obj.cumulativeDecorr = (dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr);
                    obj.cumulativeDecorr = dataObj.decorr;
                    obj.cumulativeDecorrROI = obj.cumulativeDecorr.*obj.ROIMap;
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMap(:));
                else
                    %obj.cumulativeDecorr = max(obj.cumulativeDecorr,(dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr));
                    obj.cumulativeDecorr = max(obj.cumulativeDecorr,(dataObj.decorr));
                    obj.cumulativeDecorrROI = max(obj.cumulativeDecorrROI,obj.cumulativeDecorr.*obj.ROIMap);
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMap(:));
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
            % getNextDataSetFolder: Checks the target directory for the next data set 
            %
            % Checks the directory for unprocessed data sets, returns the location of the next valid data set folder
            %
            % Usage:
            %   nextDataSetFolder = getNextDataSetFolder(obj)
            %                     inputs:
            %                        None
            %                     outputs:
            %                        nextDataSetFolder: Path of next target directory
            % getNextDataSetFolder
            % gets next (chronologically) data set inside of the target
            % folder. 
            % Returns a dir struct of next data set folder
            dataSetsReady = obj.getWaitingDataSets();
            timeCells = arrayfun(@(x) regexp(x.name,'\d+','match'),dataSetsReady,'UniformOutput',false);
            dateTimeArr = cellfun(@(y) posixtime(datetime(str2num(y{3}),str2num(y{1}),str2num(y{2}),str2num(y{4}),str2num(y{5}),str2num(y{6}),str2num(y{7}))),timeCells,'UniformOutput',false);
            dateTimeArr = [dateTimeArr{:}];
            if(~isempty(dataSetsReady))
                [~,minInd] = min(dateTimeArr);
                nextDataSetFolder = dataSetsReady(minInd);
            else
                nextDataSetFolder = [];
            end
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
            dataSetsReady = obj.getWaitingDataSets();
            timeCells = arrayfun(@(x) regexp(x.name,'\d+','match'),dataSetsReady,'UniformOutput',false);
            dateTimeArr = cellfun(@(y) posixtime(datetime(str2num(y{3}),str2num(y{1}),str2num(y{2}),str2num(y{4}),str2num(y{5}),str2num(y{6}),str2num(y{7}))),timeCells,'UniformOutput',false);
            dateTimeArr = [dateTimeArr{:}];
            if(~isempty(dataSetsReady))
                [~,minInd] = min(dateTimeArr);
                nextDataSetFolder = dataSetsReady(minInd);
            else
                nextDataSetFolder = [];
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
            invalidFolders = {'.','..','Complete','ready'};
            binOut = ones(1,numel(folderDir));
            for invalidFoldN = 1:numel(invalidFolders)
                binOut = ~arrayfun(@(x) strcmp(x.name,invalidFolders(invalidFoldN)),folderDir)' & binOut;
            end
            dataSetList = folderDir(binOut); 
        end
        
        function obj = addNextDataSetViaFilename2(obj, thisFileName) 
            % addNextDataSetViaFilename2: Adds next data set to object
            % given a filename
            %
            % Function to be called by another function which provides the
            % target filename. 
            %
            % Usage:
            %   obj = addNextDataSetViaFilename2(obj, thisFileName)
            %       inputs:
            %         thisFileName: The filename to extract data from.
            %         Should be a pcmr file
            %       outputs:
            %         Obj: Updated object
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
        
        function infoOut = getInitInfo(obj)
            % getInitInfo: Get scanner parameters from 'extra data file'
            %
            % Gets data from the 'extra data file', which is created by the
            % scanner script. Contains information about scanner
            % parameters, targets previously set initial data set folder. 
            %
            % Usage:
            %   infoOut = getInitInfo(obj)
            %           inputs:
            %             None
            %           outputs:
            %             infoOut: Data from extra data file
            %               Index 1: Frame rate
            %               Index 2: depth (mm)
            %               Index 3: Azimuth scan angle range (degrees)
            %               Index 4: Azimuth scan angle range (degrees)
            
            infoOut = ones(1,4);
            folderDir = dir(obj.dataFolder);
            folderDir = folderDir([folderDir.isdir]);
            invalidFolders = {'.','..','Complete','ready'};
            binOut = ones(1,numel(folderDir));
            for invalidFoldN = 1:numel(invalidFolders)
                binOut = ~arrayfun(@(x) strcmp(x.name,invalidFolders(invalidFoldN)),folderDir)' & binOut;
            end
            dataSetList = folderDir(binOut); 
            chosenfile = dataSetList(1).name;
            fileName = fullfile(obj.dataFolder,chosenfile,'addParamFile.txt');
            fidAdd = fopen(fileName);
            endOfFile = 0;
            while ~endOfFile
                lineText=fgetl(fidAdd);
                regexString = '(\w+)\W+=\W+(\w+)';
                if lineText==-1
                    endOfFile=1;
                else
                    [mat, tok, ~ ] = regexp(lineText,regexString,'match','tokens', 'tokenExtents');
                    if ~isempty(mat)
                        varName = tok{1};
                        varName = varName{1};
                        varVal = tok{1};
                        varVal = varVal{2};
                        switch varName
                            case 'frameRate'
                                infoOut(1) = str2num(varVal);
                            case 'depth'
                                infoOut(2) = str2num(varVal);
                            case 'phiRange'
                                infoOut(3) = str2num(varVal);
                            case 'thetaRange'
                                infoOut(4) = str2num(varVal);
                            otherwise
                                error('Variable name not valid');
                        end
                    end
                end
            end
            
        end
        
        function obj = addNextDataSetViaFilename(obj, thisFileName)
            % addNextDataSetViaFilename: Adds next data set to object
            % given a filename
            %
            % Function to be called by another function which provides the
            % target filename. 
            %
            % Usage:
            %   obj = addNextDataSetViaFilename2(obj, thisFileName)
            %       inputs:
            %         thisFileName: The filename to extract data from.
            %         Should be a pcmr file
            %       outputs:
            %         Obj: Updated object
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
            obj.activeFolderDir = fullDirectory(3:end);
            obj.numVolumes = 1; 
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
            fullDirectory  = dir(obj.activeFolder);
            obj.activeFolderDir = fullDirectory(3:end);
            obj.numVolumes = 1; 
        end
        
        function newFilePresent = checkFolder(obj)
            % newFilePresent : Check if a new set of volumes is ready for processing 
            %
            % Checks if there is an unused folder in the target directory, returns true if so
            %
            % Usage:
            %   newFilePresent = checkFolder(obj)
            %                  inputs:
            %                   None
            %                 outputs:
            %                   newFilePresent: True if a new folder is present
            obj.activeFolderDir  = dir(obj.activeFolder);
            if ismac
                obj.activeFolderDir = obj.activeFolderDir(3:end); 
            else
                obj.activeFolderDir = obj.activeFolderDir(3:end); 
            end
            if(length(obj.activeFolderDir) >= obj.numVolumes)
                newFilePresent = 1; 
            else
                newFilePresent = 0;
            end
        end
        
        function nextDataSetInFolder(obj)
            % nextDataSetInFolder: get the next data set in the folder
            %
            % %Description%
            %
            % Usage:
            %   nextDataSetInFolder(obj)
            %     inputs:
            %       %inp1%:
            %     outputs:
            %       %outp1%
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
            if((obj.decorrThresh) <= log10(obj.decorrAverageSeriesROI(obj.numDataSets-1)))
                boolOut =  1; 
            else
                boolOut =  0; 
            end
        end

        function sendSerialData(obj)
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
            fprintf(obj.outSerialObj,'S');
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
        
        function updateROIDataSet(obj)
            % updateROIDataSet: Recompute decorrelation within the ROI using newly set ROI parameters
            %
            %
            % Usage:
            %   updateROIDataSet(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            for currN = 1:length(obj.ultrasoundDataSeries) 
                interVal = obj.cumulativeDecorr(currN).decorr(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2));
                obj.decorrSumSeriesROI(currN) = mean(interVal(:));
            end
        end
        
        function initExperiment(obj)
            % initExperiment: Initailize experiment
            %
            % Inits data objects for later use
            %
            % Usage:
            %   initExperiment(obj)
            %     inputs:
            %       None
            %     outputs:
            %       None
            interVal = obj.cumulativeDecorr(1).decorr(obj.ROI_zRange(1):obj.ROI_zRange(2),obj.ROI_yRange(1):obj.ROI_yRange(2),obj.ROI_xRange(1):obj.ROI_xRange(2));
            obj.decorrSumSeriesROI(1) = mean(interVal(:));
        end
        
        function generateTemplateFolder(obj,dirName)
            % generateTemplateFolder: Create a template folder (unused)
            %
            %
            % Usage:
            %   generateTemplateFolder(obj,dirName)
            %     inputs:
            %       None
            %     outputs:
            %       None
            myDir = dir(dirName);
            obj.templateFolder = myDir;
        end
        
        function succ = checkTransfer(obj,dirName)
            % checkTransfer: Checks if the data has been succesfully transferred from the scanner
            %
            % Makes sure all data has arrived from the scanner before proceeding, returns a boolean if so
            %
            % Usage:
            %   succ = checkTransfer(obj,dirName)
            %        inputs:
            %         dirName: Name of directory to check
            %       outputs:
            %         succ: Boolean representing succesful transfer
            currDir = dir(dirName);
            succ = true;
            for n = 1:numel(obj.templateFolder)
                if currDir(n).name ~= obj.templateFolder(n).name
                    if abs(currDir(n).bytes - obj.templateFolder(n).bytes) > .01 * currDir(n).bytes
                        succ = false; 
                    end
                end
            end
        end
        
        function volOut = fixvolume(obj,vol)
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
            %  verifyFilesReady: Check if all files are ready in the folder
            %
            % %Description%
            %
            % Usage:
            %   succ = verifyFilesReady(nextDataSet)
            %        inputs:
            %         %inp1%:
            %       outputs:
            %         %outp1%
            temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
            tempInd = arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false);
            tempInd = [tempInd{:}];
            temp(tempInd) = [];
            succ = length(temp) == 21 || length(temp) == 23;
        end
    end
end

