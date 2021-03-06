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
        experimentalUSDataSeries; 
        decorrelationMapSeries;
        decorrelationMapSeriesROI;
        cumulativeDecorr; 
        cumulativeDecorrROI;
        decorrSumSeries; 
        decorrSumSeriesROI;
        decorrAverageSeries;
        decorrAverageSeriesROI;
        decorrVolume; 
        averageDecorr; 
        subRegionMap;
        scanConvLookup; 
        templateFolder; 
        % ultrasound data parameters
        dx
        dy
        dz
        dr
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
        subRegionROIMap
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
        function obj = ExperimentClass(obj)
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
        function setControlParams(obj,myThresh)
            obj.decorrThresh = myThresh; 
        end
        function setImagingParams(obj,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thisinterFrameTime,thissigma)
            %EXPERIMENTCLASS Construct an instance of this class
            %   Detailed explanation goes here
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
        function getInitDataSet(obj)
            % Get initial data set from folder
            while true
                nextDataSet = obj.getNextDataSetFolder();
                if ~isempty(nextDataSet)
                    temp = dir(fullfile(nextDataSet.folder,nextDataSet.name));
                    tempInd = [arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false)];
                    tempInd = [tempInd{:}];
                    temp(tempInd) = [];
                    while length(temp) ~= 21
                        temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
                        tempInd = arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false);
                        tempInd = [tempInd{:}];
                        temp(tempInd) = [];
                    end
                    break
                end
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.initDataSet.scanConv_Frust();
                
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range;
                obj.dx = obj.initDataSet.dx;
                obj.dy = obj.initDataSet.dy;
                obj.dz = obj.initDataSet.dz;
                obj.dr = obj.initDataSet.dr;
            end
            obj.numDataSets = 1;
        end
        function getInitDataSet_c(obj)
            % get initial data set, use mex files
            while true
                nextDataSet = obj.getNextDataSetFolder_c();
                if ~isempty(nextDataSet)
                    temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
                    tempInd = arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false);
                    tempInd = [tempInd{:}];
                    temp(tempInd) = [];
                    while length(temp) ~= 21 && length(temp) ~= 23
                        temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
                        tempInd = arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false);
                        tempInd = [tempInd{:}];
                        temp(tempInd) = [];
                    end
                    break
                end
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.scanConvLookup = obj.initDataSet.scanConv_Generate_c();
                obj.initDataSet.scanConv_apply_c(obj.scanConvLookup); 
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range;
                obj.dx = obj.initDataSet.dx;
                obj.dy = obj.initDataSet.dy;
                obj.dz = obj.initDataSet.dz;
                obj.dr = obj.initDataSet.dr;
            end
            obj.numDataSets = 1; 
        end
        function getInitDataSet_c_nocheck(obj)
            % get initial data set, use mex files
            while true
                nextDataSet = obj.getNextDataSetFolder_c();
                if ~isempty(nextDataSet)
                    temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
                    tempInd = arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false);
                    tempInd = [tempInd{:}];
                    temp(tempInd) = [];
                    %while length(temp) ~= 21
                        temp = (dir(fullfile(nextDataSet.folder,nextDataSet.name)));
                        tempInd = [arrayfun(@(x) x.name(1) == '.',temp,'UniformOutput',false)];
                        tempInd = [tempInd{:}];
                        temp(tempInd) = [];
                    %end
                    break
                end
            end
            if(~isempty(nextDataSet))
                %pause(3)
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.scanConvLookup = obj.initDataSet.scanConv_Generate_c();
                obj.initDataSet.scanConv_apply_c(obj.scanConvLookup); 
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range;
                obj.dx = obj.initDataSet.dx;
                obj.dy = obj.initDataSet.dy;
                obj.dz = obj.initDataSet.dz;
                obj.dr = obj.initDataSet.dr;
            end
            obj.numDataSets = 1; 
        end
        function getInitDataSetNoMove(obj)
            while 1
                nextDataSet = obj.getNextDataSetFolder();
                
                if ~isempty(nextDataSet)
                    while numel(dir(fullfile(nextDataSet.folder,nextDataSet.name))) ~= 23
                    
                    end
                    break
                end
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.initDataSet.scanConv_Frust();
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range;
                obj.dx = obj.initDataSet.dx;
                obj.dy = obj.initDataSet.dy;
                obj.dz = obj.initDataSet.dz;
                obj.dr = obj.initDataSet.dr;
            end
            obj.numDataSets = 1; 
        end
        function getInitDataSetNoMove_c(obj)
            while 1
                nextDataSet = obj.getNextDataSetFolder();
                
                if ~isempty(nextDataSet)
                    while numel(dir(fullfile(nextDataSet.folder,nextDataSet.name))) ~= 23
                    
                    end
                    break
                end
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                obj.initDataSet = obj.parseDataFromDir_c(fullfile(dataFolderPath,obj.defaultDataFileName));
                obj.initDataSet.scanConv_Frust();
                obj.numVolumes = 0; 
                obj.xVec = obj.initDataSet.x_range; 
                obj.yVec = obj.initDataSet.y_range; 
                obj.zVec = obj.initDataSet.z_range;
                obj.dx = obj.initDataSet.dx;
                obj.dy = obj.initDataSet.dy;
                obj.dz = obj.initDataSet.dz;
                obj.dr = obj.initDataSet.dr;
            end
            obj.numDataSets = 1; 
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
        function outDataSet = parseDataFromDir_c(obj,thisFileName)
            %pause(3)
            Dm = read_lbdump_wrapc(thisFileName);
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
            %obj.timeArr(end) = Dm.startTime;
        end
        function outDataSet = parseDataFromDirExperimental(obj,thisFileName)
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
            rmin = obj.subRegionRbounds(1);
            rmax = obj.subRegionRbounds(2);
            thetamin = obj.subRegionThetabounds(1);
            thetamax = obj.subRegionThetabounds(2);
            phimin = obj.subRegionPhibounds(1);
            phimax = obj.subRegionPhibounds(2);
            rV = obj.subRegionRboundsi(1):obj.subRegionRboundsi(2);
            thetaV = obj.subRegionThetaboundsi(1):obj.subRegionThetaboundsi(2);
            phiV = obj.subRegionPhiboundsi(1):obj.subRegionPhiboundsi(2);
            outDataSet = USDataClass(Dm.data(rV,thetaV,phiV,:),Dm.startTime, Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
        end
        
        function defineROI(obj) 
            xMid = obj.initDataSet.x_range(floor(end/2));
            yMid = obj.initDataSet.y_range(floor(end/2));
            zMid = obj.initDataSet.z_range(floor(end/2));
            diffX = abs(obj.initDataSet.x_range(1) - obj.initDataSet.x_range(2));
            diffY = abs(obj.initDataSet.y_range(1) - obj.initDataSet.y_range(2));
            diffZ = abs(obj.initDataSet.z_range(1) - obj.initDataSet.z_range(2));
            [xGrid,yGrid,zGrid] = ndgrid(obj.initDataSet.x_range-xMid,obj.initDataSet.y_range-yMid,obj.initDataSet.z_range-zMid);
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
            obj.initDataSet.ROIMap = obj.ROIMap;
            obj.initDataSet.compute3DDecorr_ROI();
        end
        function defineGridBounds(obj)
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
            dr = 1/obj.initDataSet.InfoFile.NumSamplesPerMm;         % range (mm)
            obj.rmin = obj.initDataSet.rmin;
            obj.rmax = obj.initDataSet.rmax;
            RVec = obj.rmin:dr:obj.rmax;
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
        function getDecorrInROI(obj)
            logical(obj.ROIMap); 
        end
        function returnVal = addNextDataSet(obj)
            nextDataSet = obj.getNextDataSetFolder();
            if obj.numDataSets == []
                obj.numDataSets = 1; 
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                dataObj = obj.parseDataFromDirExperimental(fullfile(dataFolderPath,obj.defaultDataFileName));
                newPath = fullfile(obj.dataFolder,'Complete',nextDataSet.name);
                fclose all;
                movefile(dataFolderPath,newPath);
                tic
                dataObj.scanConv_Frust();
                dataObj.compute3DDecorr(); 
                toc
                dataObj.decorrThresh = obj.decorrThresh;
                if(isempty(obj.cumulativeDecorr))
                    obj.cumulativeDecorr = dataObj.decorr;
                    obj.cumulativeDecorrROI = dataObj.decorr.*obj.ROIMapSubregion;
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMapSubregion(:));
                else
                    obj.cumulativeDecorr = max(obj.cumulativeDecorr,dataObj.decorr);
                    obj.cumulativeDecorrROI = max(obj.cumulativeDecorrROI,dataObj.decorr.*obj.ROIMapSubregion);
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMapSubregion(:));
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
        function returnVal = addNextRawDataSet(obj)
            nextDataSet = obj.getNextDataSetFolder();
            if obj.numDataSets == []
                obj.numDataSets = 1; 
            end
            if(~isempty(nextDataSet))
                dataFolderPath = fullfile(obj.dataFolder,nextDataSet.name);
                defineGridBounds(obj)
                
                dataObj = obj.parseDataFromDir(fullfile(dataFolderPath,obj.defaultDataFileName));
                dataObj.folderName = dataFolderPath;
                %toc
                newPath = fullfile(obj.dataFolder,'Complete',nextDataSet.name);
                fclose all;
                movefile(dataFolderPath,newPath);
                %tic
                dataObj.scanConv_Frust();
                dataObj.ROIMap = obj.ROIMap;
                dataObj.compute3DDecorr_ROI(); 
                %toc
                dataObj.decorrThresh = obj.decorrThresh;
                if(isempty(obj.cumulativeDecorr))
                    obj.cumulativeDecorr = (dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr);
                    obj.cumulativeDecorrROI = obj.cumulativeDecorr.*obj.ROIMap;
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMap(:));
                else
                    obj.cumulativeDecorr = max(obj.cumulativeDecorr,(dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr));
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
        function returnVal = addNextRawDataSet_c(obj)
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
                dataObj.compute3DDecorr_ROI(); 
                %toc
                dataObj.decorrThresh = obj.decorrThresh;
                if(isempty(obj.cumulativeDecorr))
                    obj.cumulativeDecorr = (dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr);
                    %obj.cumulativeDecorr = dataObj.decorr;
                    obj.cumulativeDecorrROI = obj.cumulativeDecorr.*obj.ROIMap;
                    obj.decorrAverageSeries(obj.numDataSets) = sum(obj.cumulativeDecorr(:))/numel(obj.cumulativeDecorr(:));
                    obj.decorrAverageSeriesROI(obj.numDataSets) = sum(obj.cumulativeDecorrROI(:))/sum(obj.ROIMap(:));
                else
                    obj.cumulativeDecorr = max(obj.cumulativeDecorr,(dataObj.decorr - obj.initDataSet.decorr)./(1-obj.initDataSet.decorr));
                    %obj.cumulativeDecorr = max(obj.cumulativeDecorr,(dataObj.decorr));
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
                                infoOut(1) = str2num(varVal)
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
        function obj = initDataFolder(obj,dirName)
            
            obj.activeFolder =  dirName;
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
        
        function computeDecorrStats(obj, tempDataSet)
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
            if((obj.decorrThresh) <= log10(obj.decorrAverageSeriesROI(obj.numDataSets-1)))
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
            fprintf(obj.outSerialObj,'S');
        end
        function setSerialOutName(obj,myname)
            obj.outSerialString = myname; 
        end
        function setSerialInName(obj,myname)
            obj.inSerialString = myname; 
        end
        function setUpSerialOutConnection(obj)
            obj.outSerialObj = serial(obj.outSerialString,'BaudRate', 115200);
            fopen(obj.outSerialObj);
        end
        function setUpSerialInConnection(obj)
            obj.inSerialObj = SerialClass(obj.inSerialString, 9600);
            obj.inSerialObj = obj.inSerialObj.initSerialBlocks();
        end
        function removeSerialConnection(obj)
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
        function generateTemplateFolder(obj,dirName)
            myDir = dir(dirName);
            obj.templateFolder = myDir;
        end
        function succ = checkTransfer(obj,dirName)
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
            for j = 1:size(vol,4)
                temp = permute(squeeze(vol(:,:,:,j)),[3,2,1]); % permute to same layout as mask data
                temp = flipdim(temp,2); % flip dim from right to left -> left to right 
                temp = flipdim(temp,3); % flip dim from top to bottm -> bottom to top 
                volOut(:,:,:,j) = temp; 
            end
        end
        function obj = setRFDataArray(obj,rfDataArr)
            obj.rfDataArr = rfDataArr;
        end
        function outObj = saveObj(obj)
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
            outObj.instibs = arrayfun(@(x)obj.fixvolume(x.ibs), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instdecorr = arrayfun(@(x)obj.fixvolume(x.decorr), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.Bmode = arrayfun(@(x)obj.fixvolume(x.rawData_cart), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.decorr = obj.fixvolume(obj.cumulativeDecorr); 
            outObj.decorrThresh = obj.decorrThresh; 
            outObj.folderNames = arrayfun(@(x)x.folderName, obj.ultrasoundDataSeries, 'UniformOutput', false); 
        end
        function outObj = saveObj_withrf(obj,rfDataArr)
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
            outObj.instibs = arrayfun(@(x)obj.fixvolume(x.ibs), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.instdecorr = arrayfun(@(x)obj.fixvolume(x.decorr), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.Bmode = arrayfun(@(x)obj.fixvolume(x.rawData_cart), obj.ultrasoundDataSeries,'UniformOutput',false);
            outObj.decorr = obj.fixvolume(obj.cumulativeDecorr); 
            outObj.decorrThresh = obj.decorrThresh; 
            outObj.folderNames = arrayfun(@(x)x.folderName, obj.ultrasoundDataSeries, 'UniformOutput', false); 
            outObj.rfDataArr = rfDataArr;
        end
        function outDat = getTimeArr(obj)
            outDat = arrayfun(@(x)x.time, obj.ultrasoundDataSeries,'UniformOutput',false);
        end
    end
    
end

