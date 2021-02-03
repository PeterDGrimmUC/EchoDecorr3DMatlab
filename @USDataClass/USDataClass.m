%% USDataClass: Data class for computation of echo decorrelation
classdef USDataClass < handle 
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
        function obj = USDataClass(thisRawData,startTime,thisInfoFile,thisrmin,thisrmax,thisthetamin,thisthetamax,thisphimin,thisphimax,thiscartScalingFactor,thiswindowSigma,thisinterFrameTime,decorrThresh)
           obj.rawData = thisRawData;   
           obj.InfoFile = thisInfoFile;
           obj.rmax = thisrmax;
           obj.rmin = thisrmin;
           obj.thetamax = thisthetamax;
           obj.thetamin = thisthetamin;
           obj.phimax = thisphimax;
           obj.phimin = thisphimin;
           obj.cartScalingFactor = thiscartScalingFactor;
           obj.windowSigma = thiswindowSigma;
           obj.interFrameTime = thisinterFrameTime;
           obj.time = startTime;
        end
        function scanConv_apply_c( obj, scanMap )
            %% set up the parameters
            %global p LR Lmu Lnu iR imu inu R0
            Isph = squeeze(obj.rawData(:,:,:,1));
            sizeR = size(Isph,1);
            sizeAz = size(Isph,2);
            sizeEl = size(Isph,3);

            % define coordinates on pyramidal grid
            obj.dr = 1/obj.InfoFile.NumSamplesPerMm;         % range (mm)
            Rvec = obj.rmin:obj.dr:obj.rmax;

            % sin theta (azimuth)
            mumax = sin(obj.thetamax); mumin = sin(obj.thetamin);
            muvec = linspace(mumin,mumax,sizeAz);
            dmu = muvec(2)-muvec(1);

            % sin phi (elevation)
            numax = sin(obj.phimax); numin=sin(obj.phimin);
            nuvec = linspace(numin,numax,sizeEl);
            dnu = nuvec(2)-nuvec(1);

            [R,mu,nu] = ndgrid(Rvec,muvec,nuvec);

            % Cartesian grid, onto which we're scan-converting (interpolating)
            %obj.cartScalingFactor =2;
            obj.dz = obj.cartScalingFactor*obj.dr;%0.5;  % spatial step
            obj.dx = obj.dz;
            obj.dy = obj.dz;
            maxY = obj.rmax*sin(obj.phimax);
            minY = obj.rmax*sin(obj.phimin);
            maxX = obj.rmax*sin(obj.thetamax);
            minX = obj.rmax*sin(obj.thetamin);
            obj.z_range = obj.rmin:obj.dz:obj.rmax;  % depth
            obj.y_range = minY:obj.dz:maxY; %-32:obj.dz:32;  % azimuth
            obj.x_range = minX:obj.dz:maxX; %-31:obj.dz:31;  % elevation;
            [x,y,z] = ndgrid(obj.x_range,obj.y_range,obj.z_range);
            obj.xMax = obj.x_range(end);
            obj.xMin = obj.x_range(1); 
            obj.yMax = obj.y_range(end);
            obj.yMin = obj.y_range(1); 
            obj.zMax = obj.z_range(end);
            obj.zMin = obj.z_range(1); 
            % pyramidal coordinates of Cartesian grid points
            R0 = sqrt(x.^2+y.^2+z.^2);
            mu0 = y./sqrt(z.^2+y.^2);
            nu0 = x./(sqrt(R0.^2-y.^2));

            % find Cartesian points inside pyramid to interpolate
            p = find(R0>=obj.rmin & R0<=obj.rmax-obj.dr & mu0>=mumin & mu0<=mumax-dmu & ...
                nu0>=numin & nu0<=numax-dnu); % points for valid interpolation

            %image_initialization_time = toc

            %tic;
            % for each point to interpolate, find nearest previous neighbors, and
            %  distances from them along R, mu, nu directions
            imu = zeros(size(R0));
            Lmu = zeros(size(R0));
            imu(p) = floor((mu0(p) - mumin)/dmu) + 1;
            Lmu(p) = mu0(p) - muvec(imu(p))';

            inu = zeros(size(R0));
            Lnu = zeros(size(R0));
            inu(p) = floor((nu0(p) - numin)/dnu) + 1;
            Lnu(p) = nu0(p) - nuvec(inu(p))';

            iR = zeros(size(R0));
            LR = zeros(size(R0));
            iR(p) = floor((R0(p) - obj.rmin)/obj.dr) + 1;
            for volIndex = 1:size(obj.rawData,4)
                Isph = squeeze(obj.rawData(:,:,:,volIndex));
                [cOut] = scanConv_Frust_apply_c(p,Isph,scanMap,iR,inu,imu,length(p),length(obj.x_range),length(obj.y_range),length(obj.z_range),size(Isph));
                obj.rawData_cart(:,:,:,volIndex) = reshape(cOut,length(obj.x_range),length(obj.y_range),length(obj.z_range))/(obj.dr*dmu*dnu);
            end
            for j = 1:size(obj.rawData_cart,4)
                temp = permute(squeeze(obj.rawData_cart(:,:,:,j)),[3,2,1]); % permute to same layout as mask data
                temp = flipdim(temp,2); % flip dim from right to left -> left to right 
                temp = flipdim(temp,3); % flip dim from top to bottm -> bottom to top 
                volOut(:,:,:,j) = temp; 
            end
            obj.rawData_cart = volOut; 
        end


    end
    
    
end

