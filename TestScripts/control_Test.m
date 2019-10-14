%% Define parameters

warning('off','all')
try 
    if ispc
        basePath = strcat('C:\Users\',getenv('username'),'\Box\SiemensSC2000IQData');
    elseif ismac
        basePath = strcat('/Users/',getenv('USER'),'/box');
    end
catch
    basePath = matlabroot;
end
fullDirectory =  uigetdir(basePath);
dataDirectory = dir(fullDirectory);
fileName = 'bufApl0Out_0x0_0x0.data.dm.pmcr';
%user defined
azimuthAngle = 2*pi*80/360;
rangeAngle = 2*pi*80/360;
rmin = 0;
cartScalingFactor = 2; % dx/dr
sigma = 1; %mm
frameRate = 22; % hz
%% get US data
if ispc
    fullPath =strcat(fullDirectory,'\',{dataDirectory(6).name},'\',fileName);
elseif ismac
    fullPath =strcat(fullDirectory,'/',{dataDirectory(6).name},'/',fileName);
end

DmBase = read_lbdump(fullPath{1});
%computed from existing parameters/infofile
rmax = 90%(size(DmBase.data,1)/DmBase.Info.NumSamplesPerMm)/10;
thetamin= -azimuthAngle/2;
thetamax = azimuthAngle/2;
phimin=-rangeAngle/2;
phimax=rangeAngle/2;

interFrameTime = 1/frameRate;
thresh = .1; 
%% compute first decorrelation, to obtain size for cumumaltive decorr
Dm.startTime =1;
usData(1) = USDataClass(Dm.data,Dm.startTime, Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,interFrameTime);
usData(1).scanConv_Frust();
usData(1).compute3DDecorr();
cumulDecorr = usData(1).decorr;
%%
for n = 5:size(dataDirectory)
    %tic
    if ispc
        fullPath =strcat(fullDirectory,'\',{dataDirectory(n).name},'\',fileName);
    elseif ismac
        fullPath =strcat(fullDirectory,'/',{dataDirectory(n).name},'/',fileName);
    end
    dataDirectory(n).name;
    Dm = read_lbdump(fullPath{1});
    usData(n-3) = USDataClass(Dm.data,Dm.startTime, Dm.Info,rmin,rmax,thetamin,thetamax,phimin,phimax,cartScalingFactor,sigma,interFrameTime);

    %usData(n-3).scanConvert3DVolume_sliceMethod;
    %usData(n-3).compute3DDecorr_sliceMethod;
    %tic;
    usData(n-3).scanConv_Frust();
    %usData(n-3).scanConvert3D_Frust;
    %toc;
    %tic
    usData(n-3).compute3DDecorr();
    cumulDecorr = max(cumulDecorr,usData(n-3).decorr);
end
toc;
%%
cumulDecorr(1).totalDecorr = usData(1).decorr;
cumulDecorrSum(1) =  sum(cumulDecorr(1).totalDecorr(:));
for n = 2:size(usData)
    cumulDecorr(n).totalDecorr = max(usData(n).decorr,cumulDecorr(n-1).totalDecorr);
    cumulDecorrSum(n) =  sum(cumulDecorr(n).totalDecorr(:));
end
plot(cumulDecorrSum);