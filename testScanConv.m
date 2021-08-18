clear
targetDir = '/Volumes/DATA 2/datadump07142021/AllBufferDump/IQDATA_Date_07-14-2021_Time_14-41-24-30/';
targetFile = 'bufApl4Out_0x1_0x0.data.dm.part';
targetFull = fullfile(targetDir,targetFile);
H = read_lbdump(targetFull);
data = squeeze(H.data(:,:,1,:));
obj = struct; 
%%
[sizeRange, sizeAngle, numFrames] = size(data);
obj.thetamin = -45*pi/180; 
obj.thetamax = 45*pi/180; 
obj.cartScalingFactor = 2; 
obj.dr = 1/H.Info.NumSamplesPerMm;
obj.rmin = 0; 
obj.rmax = obj.dr * sizeRange;

mumax = sin(obj.thetamax); mumin = sin(obj.thetamin);
muvec = linspace(mumin,mumax,sizeAngle);
dmu = muvec(2)-muvec(1);
Rvec = obj.rmin:obj.dr:obj.rmax;
% Cartesian grid, onto which we're scan-converting (interpolating)
%obj.cartScalingFactor =2;
obj.dz = obj.cartScalingFactor*obj.dr;  % spatial step
obj.dy = obj.dz;
maxY = obj.rmax*sin(obj.thetamax);
minY = obj.rmax*sin(obj.thetamin);
obj.z_range = obj.rmin:obj.dz:obj.rmax;  % depth
obj.y_range = minY:obj.dy:maxY; %-32:obj.dz:32;  % azimuth
[z,y] = ndgrid(obj.z_range,obj.y_range);
obj.yMax = obj.y_range(end);
obj.yMin = obj.y_range(1); 
obj.zMax = obj.z_range(end);
obj.zMin = obj.z_range(1); 

% polar coordinates of Cartesian grid points
R0 = sqrt(y.^2+z.^2);
mu0 = atan(y./z);


% find Cartesian points inside pyramid to interpolate
p = find(R0>=obj.rmin & R0<=obj.rmax-obj.dr & mu0>=mumin & mu0<=mumax-dmu); % points for valid interpolation

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
iR(p) = floor((R0(p) - obj.rmin)/obj.dr) + 1;
LR(p) = R0(p) - Rvec(iR(p))';

%interpolation_initialization_time = toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tic;
Icart = zeros(size(R0));
for currFrame = 1:numFrames
    Isph = squeeze(data(:,:,currFrame));
    for ip = 1:length(p)
        q = p(ip);

        % differences to be used below, trying to save a few flops
        drmLR = obj.dr-LR(q);
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
    obj.rawData_cart(:,:,currFrame) = Icart/(obj.dr*dmu);
end

imagesc(log10(abs((obj.rawData_cart(:,:,2)))))