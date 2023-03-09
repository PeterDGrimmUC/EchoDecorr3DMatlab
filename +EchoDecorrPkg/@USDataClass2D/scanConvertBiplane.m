function scanConvertBiplane( obj )
%SCANCONVERT3D_FRUST Summary of this function goes here
%   Detailed explanation goes here
%% plane 1
    [sizeRange, ~, ~] = size(obj.rawData{1});
    obj.dr = 1/obj.InfoFile{1}.NumSamplesPerMm;
    obj.rmin = 0; 
    obj.rmax = obj.dr * sizeRange;
    Rvec = obj.rmin:obj.dr:obj.rmax;
    % Cartesian grid, onto which we're scan-converting (interpolating)
    obj.dz = obj.cartScalingFactor*obj.dr;  % spatial step
    obj.dy = obj.dz;
    obj.dx = obj.dz;
    maxY = obj.rmax*sin(obj.thetamax);
    minY = obj.rmax*sin(obj.thetamin);
    maxX = obj.rmax*sin(obj.phimax);
    minX = obj.rmax*sin(obj.phimin);
    obj.z_range = obj.rmin:obj.dz:obj.rmax;  % depth
    obj.y_range = minY:obj.dy:maxY; %% azimuth
    obj.x_range = minX:obj.dx:maxX; %% azimuth
    [z1,y1] = ndgrid(obj.z_range,obj.y_range);
    [z2,x2] = ndgrid(obj.z_range,obj.x_range);
    obj.yMax = obj.y_range(end);
    obj.yMin = obj.y_range(1); 
    obj.zMax = obj.z_range(end);
    obj.zMin = obj.z_range(1); 
    obj.xMax = obj.x_range(end);
    obj.xMin = obj.x_range(1); 
    plane1 = scanConvertPlane(obj.rawData{1},z1,y1,obj.rmin, obj.rmax, obj.thetamin, obj.thetamax, obj.dz,Rvec);
    plane2 = scanConvertPlane(obj.rawData{2},z2,x2,obj.rmin, obj.rmax, obj.phimin, obj.phimax,obj.dz, Rvec);
    obj.rawData_cart = {plane1,plane2};
end

function rawData_cart=scanConvertPlane(rawData,z,y,rMin,rMax, thetaMin,thetaMax,dr,Rvec)
    [~,sizeAngle,numFrames]= size(rawData)
    rawData_cart = {};
    mumax = sin(thetaMax); mumin = sin(thetaMin);
    muvec = linspace(mumin,mumax,sizeAngle);
    dmu = muvec(2)-muvec(1);
    R0 = sqrt(y.^2+z.^2);
    mu0 = atan(y./z);


    % find Cartesian points inside pyramid to interpolate
    p = find(R0>=rMin & R0<=rMax-dr & mu0>=mumin & mu0<=mumax-dmu); % points for valid interpolation

    %image_initialization_time = toc

    %tic;
    % for each point to interpolate, find nearest previous neighbors, and
    %  distances from them along R, mu, nu directions
    imu = zeros(size(R0));
    Lmu = zeros(size(R0));
    imu(p) = floor((mu0(p) - mumin)/dmu) + 1;
    Lmu(p) = mu0(p) - muvec(imu(p))';

    iR = zeros(size(R0));
    LR = zeros(size(R0));
    iR(p) = floor((R0(p) - rMin)/dr) + 1;
    LR(p) = R0(p) - Rvec(iR(p))';

    %interpolation_initialization_time = toc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %tic;
    Icart = zeros(size(R0));
    clear temp; 
    for currFrame = 1:numFrames
        dat = rawData;
        Isph = squeeze(dat(:,:,currFrame));
        for ip = 1:length(p)
            q = p(ip);

            % differences to be used below, trying to save a few flops
            drmLR = dr-LR(q);
            dmumLmu = dmu-Lmu(q);
            Icart(q) = Isph(iR(q),imu(q)) ... % p1
                * drmLR * dmumLmu + ...
                Isph(iR(q),imu(q)+1) ... % p2
                * LR(q) * dmumLmu + ...
                Isph(iR(q)+1,imu(q)) ... % p3
                * drmLR * Lmu(q) + ...
                Isph(iR(q)+1,imu(q)+1) ... % p4
                * LR(q) * Lmu(q);
        end
        temp(:,:,currFrame) = Icart/(dr*dmu);
    end
    rawData_cart = temp;
end
