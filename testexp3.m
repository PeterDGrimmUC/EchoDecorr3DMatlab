load('time_exp_16-Jun-2020_6.mat')
load('outputRaw_exp_16-Jun-2020_6.mat')

% Init
allTrials = [25];

%for thisTrial = 1:numel(allTrials)
basePath = 'C:\Users\USServer\Documents\Shared\IQDump';
tissueHeight = 70;
trials = allTrials;
inBoxLimit = [1 82 34 115 4 103];
% Load Experiment class
for currTrial = 1:numel(allTrials)
    experimentArr(currTrial) = ExperimentClass();
    % set folder
    fileTarget = fullfile(basePath,strcat('trial_',num2str(allTrials(currTrial))));
    dirInFile = dir(fileTarget); 
    foldersInDir = [dirInFile.isdir];
    targetDirs = dirInFile(foldersInDir);
    dirNames = arrayfun(@(x) x.name, targetDirs, 'UniformOutput', false);
    validDirs = cell2mat(cellfun(@(x) ~(isequal(x,'.') || isequal(x,'..')),dirNames,'UniformOutput',false));
    dirNames = dirNames(validDirs);
    if length(dirNames) > 1
        display('Extra folder detected!');
    end
    finalTargetDir = fullfile(fileTarget,dirNames{1});
    experimentArr(currTrial).initDataFolder(finalTargetDir); 
    thisphimax = deg2rad(78/2);
    thisphimin = -thisphimax;
    thisthetamax = deg2rad(78/2);
    thisthetamin = -thisphimax;
    thiscartScalingFactor = 3; 
    thisinterFrameTime = 55; 
    thissigma = 3; 
    experimentArr(currTrial).setImagingParams(thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thisinterFrameTime,thissigma)

    %
    experimentArr(currTrial).getInitDataSet_c();
    %
    % set parameters
    x0 = 0;
    y0 = 0; 
    z0 = 67; 
    Rx_in = 15;
    Ry_in = 15;
    Rz_in = 15;
    Rx_out = 15;
    Ry_out = 15;
    Rz_out = 15;
    alphaAng = 0; 
    betaAng = 0; 
    gammaAng = 0; 
    ROIMode = 1;
    % init 
    experimentArr(currTrial).setROIParams(x0,y0,z0,Rx_out,Ry_out,Rz_out,Rx_in,Ry_in,Rz_in,alphaAng,gammaAng,betaAng);
    % loop over folder to get all data sets
    tic
     while(experimentArr(currTrial).addNextRawDataSet_c() ~= -1)
        toc
        tic
     end

  toc
end
%%
for k = 1:1:length(convertStringsToChars(outputRaw(2)))-1
    tOut(k,:) = arrayfun(@(x)getElem(x,k), outputRaw);
end
%%
decorrTimes = arrayfun(@(x)x.time,experimentArr(1).ultrasoundDataSeries)
%cumulativeDecorr = arrayfun(@(x)x.cumulativeDecorr,experimentArr(1).ultrasoundDataSeries)
decorr = experimentArr(1).decorrAverageSeries
decorrROI = experimentArr(1).decorrAverageSeriesROI
RFtime = datetime(timeArr)

%decorr_ROI = arrayfun(@(x)x.decorr_ROI,experimentArr(1).ultrasoundDataSeries)

%decorr_ROI = arrayfun(@(x)x.decorr_ROI,experimentArr(1).ultrasoundDataSeries,'UniformOutput',false)
%%
t1 = squeeze(tOut(21,:));
for n = 2:length(t1)
    if t1(n) == 0
        t1(n) = t1(n-1);
    end
end
%%
yyaxis left
plot(RFtime,t1)
yyaxis right
plot(decorrTimes,decorr)

%%
function t = getElem(inp,ind)
    inputLine = convertStringsToChars(inp);
    try
    t = numto14(inputLine(ind),inputLine(ind+1))/10;
    catch
    t = 0    
    end
end