%% USDataClass: Data class for computation of echo decorrelation
classdef USDataClass2D < handle 
    % USDataClass: Data class for computation of echo decorrelation 
    %   each set of data has is an object of type USDataClass
    %   contains the data parameters, raw spherical data, cartesian scan converted data, ibs,
    %   and decorrelation 
    % Author: Peter Grimm 12/21/2019
    properties
        % data properties
        rawData;           % raw spherical volume data for one data set export
        rawData_cart;      % scan converted cartesian data from spherical data
        ROICart;  
        ROIMask; 
        ROIMap;
        ibs;               % Integrated backscatter for every (cartesian) volume
        R;
        decorr;            % decorr (cartesian) between volume at t and t+tau
        autocorr01;        % autocorr between volume at t and t+tau
        decorrAvg;         % average of decorrelation in entire data set, either ensemble or running 
        time;
        cumulativeDecorr;
        cumulativeDecorrSum;
        decorrThresh;
        decorrMap; 
        decorrSumPixels; 
        decorrVolEstimate; 
        % bounds 
        ROIBounds;         % bounds of region of interest [xMin xMax yMin yMax zMin zMax]
        ROIBounds_spherical; %TODO, minimum bounds in spherical coordinates
        folderName;
        % bounded data properties 
        rawData_cart_ROI;
        ibs_ROI;
        decorr_ROI;
        autocorr01_ROI;
        decorrAvg_ROI;
        isBiplane;
        % parameters
        %The following would ideally be part of InfoFile in the future
        InfoFile;          % Info file provided by siemens SC2000 scanner
        rmax,rmin,thetamax,thetamin,phimax,phimin; % bounds in cm of the spherical data 
        xMin,xMax,yMin,yMax,zMin,zMax; % bounds in cm of cartesian data
        x_range,y_range,z_range; % range in cartesian plane
        windowSigma;       % sigma of gaussian smoothing kernel
        dPhi;              % angular difference between successive phi 
        dTheta;            % angular difference between successive theta
        dr;                % distance in cm in the radius direction(cm/pixel)
        dx;                % distance in cm in the x direction (cm/pixel)
        dy;                % distance in cm in the x direction (cm/pixel)
        dz;                % distance in cm in the x direction (cm/pixel)
        interFrameTime;    % time between volume recordings (cm/pixel)
        cartScalingFactor; % Factor to scale cartesian distances by (dx/dr)
                           % e.g Given dr, to find dx take
                           % dr*cartScalingFactor = dx
                           % reduces resolution by a factor of
                           % cartScalingFactor for faster scan conversion
        maskfilt;          % Gaussian Mask, for FFT based filtering 
        voxelStepCart; 
        rawData_cart_slicemethod;
        ibs_slicemethod;               % Integrated backscatter for every (cartesian) volume
        decorr_slicemethod;            % decorr (cartesian) between volume at t and t+tau
        autocorr01_slicemethod;        % autocorr between volume at t and t+tau
        decorrAvg_slicemethod;         % average of decorrelation in entire data set, either ensemble or running 
        % scan conversion properties
        dmu;
        dnu;
        frustumPoints;
        imu;
        Lmu;
        inu;
        Lnu;
        iR;
        LR;
        R0;
        mu0;
        nu0;
    end
    
    methods
        %% Constructor method
        function obj = USDataClass2D(thisRawData,startTime,thisInfoFile,thisrmin,thisrmax,thisthetamin,thisthetamax,thisphimin,thisphimax,thisVoxelStepCart,thiswindowSigma,thisinterFrameTime,mode)
           obj.rawData = thisRawData;   
           obj.InfoFile = thisInfoFile;
           obj.rmax = thisrmax;
           obj.rmin = thisrmin;
           obj.thetamax = thisthetamax;
           obj.thetamin = thisthetamin;
           obj.phimax = thisphimax;
           obj.phimin = thisphimin;
           obj.voxelStepCart = thisVoxelStepCart;
           obj.windowSigma = thiswindowSigma;
           obj.interFrameTime = thisinterFrameTime;
           obj.time = startTime;
           if strcmp(mode,'biplane')
                isBiplane = true;
           elseif strcmp(mode,'2D')
                isBiplane = false; 
           else
               display('invalid mode')
           end
        end
        scanConvert2D( obj );
        compute2DDecorr_Freq( obj );
        scanConvertBiplane( obj );
        computeBiplaneDecorr_Freq( obj );
        compute2DDecorr_Time( obj );
    end
end

