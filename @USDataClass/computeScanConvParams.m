function computeScanConvParams( obj )
%COMPUTESCANCONVPARAMS Summary of this function goes here
%   Detailed explanation goes here
% obj.dnu, obj.dmu, obj.Lmu, obj.Lnu, obj.iR, obj.imu, obj.inu, obj.LR
    Isph = obj.rawData;
    sizeR = size(Isph,1);
    sizeAz = size(Isph,2);
    sizeEl = size(Isph,3);
    
    % define coordinates on pyramidal grid
    
    obj.dr = obj.rmax / (sizeR-1);         % range (mm)
    Rvec = obj.rmin:obj.dr:obj.rmax;
    
    % sin theta (azobj.imuth)
    mumax = sin(obj.thetamax); mumin=-mumax;
    muvec = linspace(mumin,mumax,sizeAz);
    obj.dmu = muvec(2)-muvec(1);
    
    % sin phi (elevation)
    numax = sin(obj.phimax); numin=-numax;
    nuvec = linspace(numin,numax,sizeEl);
    obj.dnu = nuvec(2)-nuvec(1);
    
    % Cartesian grid, onto which we're scan-converting (interpolating)
    obj.cartScalingFactor =2;
    obj.dz = obj.cartScalingFactor*obj.dr;%0.5;  % spatial step
    obj.dx = obj.dz;
    obj.dy = obj.dz;
    maxY = obj.rmax*sin(obj.thetamax); maxZ = obj.rmax*sin(obj.phimax);
    obj.z_range = 0:obj.dz:obj.rmax;  % depth
    obj.y_range = -maxY:obj.dz:maxY; %-32:obj.dz:32;  % azobj.imuth
    obj.x_range = -maxZ:obj.dz:maxZ; %-31:obj.dz:31;  % elevation;
    [z,y,x] = ndgrid(obj.z_range,obj.y_range,obj.x_range);
    
    %defining image cross sections (default: half range, az., el.)
%     ixmid = find(abs(obj.x_range)==min(abs(obj.x_range)));
%     iymid = find(abs(obj.y_range)==min(abs(obj.y_range)));
%     izmid = ceil(size(obj.z_range,2)/2);
    
    % pyramidal coordinates of Cartesian grid points
    obj.R0 = sqrt(x.^2+y.^2+z.^2);
    obj.mu0 = y./sqrt(z.^2+y.^2);
    obj.nu0 = x./(sqrt(obj.R0.^2-y.^2));
    
    % find Cartesian points inside pyramid to interpolate
    obj.frustumPoints = find(obj.R0>=obj.rmin & obj.R0<=obj.rmax-obj.dr & obj.mu0>=mumin & obj.mu0<=mumax-obj.dmu & ...
        obj.nu0>=numin & obj.nu0<=numax-obj.dnu); % points for valid interpolation
    
    %image_initialization_time = toc
    
    %tic;
    % for each point to interpolate, find nearest previous neighbors, and
    %  distances from them along R, mu, nu dobj.iRections
    obj.imu = zeros(size(obj.R0));
    obj.Lmu = zeros(size(obj.R0));
    obj.imu(obj.frustumPoints) = floor((obj.mu0(obj.frustumPoints) - mumin)/obj.dmu) + 1;
    obj.Lmu(obj.frustumPoints) = obj.mu0(obj.frustumPoints) - muvec(obj.imu(obj.frustumPoints))';
    
    obj.inu = zeros(size(obj.R0));
    obj.Lnu = zeros(size(obj.R0));
    obj.inu(obj.frustumPoints) = floor((obj.nu0(obj.frustumPoints) - numin)/obj.dnu) + 1;
    obj.Lnu(obj.frustumPoints) = obj.nu0(obj.frustumPoints) - nuvec(obj.inu(obj.frustumPoints))';
    
    obj.iR = zeros(size(obj.R0));
    obj.LR = zeros(size(obj.R0));
    obj.iR(obj.frustumPoints) = floor((obj.R0(obj.frustumPoints) - obj.rmin)/obj.dr) + 1;
    obj.LR(obj.frustumPoints) = obj.R0(obj.frustumPoints) - Rvec(obj.iR(obj.frustumPoints))';
    
    %interpolation_initialization_time = toc
    

end

