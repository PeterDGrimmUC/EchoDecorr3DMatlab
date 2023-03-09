function getNextDataSet(obj)
    dirListing = preParseDir(dir(obj.dataFolder));
    if ~isempty(dirListing)
        targetFolder = fullfile(dirListing(1).folder,dirListing(1).name); 
        timeOut = 3; 
        startTime = datetime(); 
        while ~checkFilesReady(targetFolder,obj.targetFiles) && seconds(datetime()-startTime) < timeOut;end
        if seconds(datetime()-startTime) > timeOut
            return
        end
        newDataSet = loadNewFile(targetFolder,obj.mode,obj.plane1FileName,obj.plane2FileName,obj);
        obj.dataSeries{end+1} = newDataSet; 
        moveToComplete(targetFolder,dirListing(1).name,obj);
    end
end
function dirListing = preParseDir(dirListing)
    dirListing=dirListing(~ismember({dirListing.name},{'.','..','Complete'}));
    dirListing=dirListing(arrayfun(@(y) isfolder(fullfile(y.folder,y.name)),dirListing));
end
function succ=checkFilesReady(targetDir,targetFiles)
    dir2check = dir(targetDir);
    dir2check = {dir2check.name};
    checkExists = @(strIn) any(cellfun(@(currString) strcmp(strIn,currString), dir2check ));
    succ = all(cellfun(checkExists,targetFiles));
end
function dat = loadNewFile(folderName,mode,plane1FileName,plane2FileName,obj)
    switch mode
        case '2D'
            DataSet1Name = fullfile(folderName,plane1FileName);
            dat = read_lbdump_wrap(DataSet1Name,obj);
        case 'biplane'
            DataSet1Name = fullfile(folderName,plane1FileName);
            dat1 = read_lbdump_wrap(DataSet1Name,obj);
            DataSet2Name = fullfile(folderName,plane2FileName);
            dat2 = read_lbdump_wrap(DataSet2Name,obj);
            dat = dat1;
            dat.rawData = {dat1.rawData, dat2.rawData};
            dat.InfoFile = {dat1.InfoFile, dat2.InfoFile};
        otherwise
            dat = {};
    end
end
function outDataSet = read_lbdump_wrap(thisFileName,obj)
    Dm = read_lbdump(thisFileName); % call memory mapped read function
    % get radius information
    obj.rmin = 0;
    obj.rmax = (1/Dm.Info.NumSamplesPerMm)* Dm.Info.NumRangeSamples;
    obj.frameRate = Dm.Info.framerate;
    obj.elAngle = Dm.Info.phiRange;
    obj.azAngle = Dm.Info.thetaRange;
    obj.thetamax = pi/360*obj.azAngle;
    obj.thetamin = -obj.thetamax;
    obj.phimax = pi/360*obj.elAngle;
    obj.phimin = -obj.phimax;
    % create USDataClass objet
    thisTime = processDate(thisFileName);
    outDataSet = USDataClass2D(Dm.data,thisTime, Dm.Info,obj.rmin,obj.rmax,obj.thetamin,obj.thetamax,obj.phimin,obj.phimax,obj.voxelStepCart,obj.sigma,obj.frameRate,obj.mode);
    %USDataClass2D(thisRawData,startTime,thisInfoFile,thisrmin,thisrmax,thisthetamin,thisthetamax,thiscartScalingFactor,thiswindowSigma,thisinterFrameTime,mode)
end
function moveToComplete(dataFolderPath,dataFolderName,obj)
    newPath = fullfile(obj.dataFolder,'Complete',dataFolderName);
    fclose all;
    movefile(dataFolderPath,newPath);
end
function outTime = processDate(thisFileName)
    folderStr = split(thisFileName,'/');
    folderStr = folderStr{6};
    folderSplit = split(folderStr,'_');
    dayString = folderSplit{3};
    timeString = folderSplit{5};
    outTime = datetime(strcat(dayString,'-',timeString),'InputFormat','MM-dd-yyyy-HH-mm-ss-SS');
end