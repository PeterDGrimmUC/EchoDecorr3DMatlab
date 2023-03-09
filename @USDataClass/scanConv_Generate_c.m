function [qOut] = scanConv_Generate_c( obj )
% This script reads IQ data in the first section (SIEMENS Scripts), then
% does the 3D interpolation on spherical IQ data with function named
% "frustumInterp". In the last section the spherical and
% interpolated data in cartesian system are displayed.

% Writers: Elmira Ghahramani Z., Dr. Douglas Mast
% Image-guided Ultrasound Therapeutics Laboratories
% University of Cincinnati
% Contacts: ghahraea@mail.uc.edu
%           masttd@UCMAIL.UC.EDU
% Date last updated: 02/19/2019

%% Read IQ data

%for volIndex = 1:size(obj.rawData,4)
    Isph = squeeze(obj.rawData(:,:,:,1));
    
    %% set up the parameters
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
    obj.dz = obj.voxelStepCart;%0.5;  % spatial step
    obj.dx = obj.dz;
    obj.dy = obj.dz;
    obj.cartScalingFactor=obj.dx/obj.dr;
    maxY = ceil(obj.rmax*sin(obj.phimax));
    minY = floor(obj.rmax*sin(obj.phimin));
    maxX = ceil(obj.rmax*sin(obj.thetamax));
    minX = floor(obj.rmax*sin(obj.thetamin));
    obj.z_range = obj.rmin:obj.dz:obj.rmax+1;  % depth
    obj.y_range = minY:obj.dz:maxY; %-32:obj.dz:32;  % azimuth
    obj.x_range = minX:obj.dz:maxX; %-31:obj.dz:31;  % elevation;
    [x,y,z] = ndgrid(obj.x_range,obj.y_range,obj.z_range);
    obj.xMax = obj.x_range(end);
    obj.xMin = obj.x_range(1); 
    obj.yMax = obj.y_range(end);
    obj.yMin = obj.y_range(1); 
    obj.zMax = obj.z_range(end);
    obj.zMin = obj.z_range(1); 
    %defining image cross sections (default: half range, az., el.)
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
    LR(p) = R0(p) - Rvec(iR(p))';

    [qOut] = scanConv_Frust_c(p,Lmu,Lnu,LR,dmu,dnu,obj.dr,length(p));
end

