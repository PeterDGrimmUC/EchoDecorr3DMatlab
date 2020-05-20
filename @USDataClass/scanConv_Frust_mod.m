function [qOut, p, sz] = scanConv_Frust_mod( obj )
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
    %tic
    %global p LR Lmu Lnu iR imu inu R0
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
    %defining image cross sections (default: half range, az., el.)
%     ixmid = find(abs(obj.x_range)==min(abs(obj.x_range)));
%     iymid = find(abs(obj.y_range)==min(abs(obj.y_range)));
%     izmid = ceil(size(obj.z_range,2)/2);
    
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
    
    %interpolation_initialization_time = toc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %tic;
    %qOut = zeros(1,length(p));
    sz = size(R0); 
    %void generatePyramidalCoordinates(const mxArray * p,const mxArray * Lmu, const mxArray * Lnu, const mxArray * LR, double dmu, double dnu, double dr, long int pSize){
    %tic;
    [test] = scanConv_Frust_c(p,Lmu,Lnu,LR,dmu,dnu,obj.dr,length(p));
    %tic
   [test2] = scanConv_Frust_apply_c(p,Isph,test,iR,inu,imu,length(p),length(obj.x_range),length(obj.y_range),length(obj.z_range),size(Isph));
    %toc
    qOut = reshape(test2,length(obj.x_range),length(obj.y_range),length(obj.z_range))/(obj.dr*dmu*dnu);
    %toc
%     qOut = zeros(1,8*length(p));
%         for ip = 1:length(p)
%         q = p(ip);
%         
%         % differences to be used below, trying to save a few flops
%         drmLR = obj.dr-LR(q);
%         dmumLmu = dmu-Lmu(q);
%         dnumLnu = dnu-Lnu(q);
%         %
%         %n = drmLR * dmumLmu * dnumLnu;
%         qOut((ip-1)*8 + 1) = drmLR * dmumLmu * dnumLnu;
%         qOut((ip-1)*8 + 2) = LR(q) * dmumLmu * dnumLnu;
%         qOut((ip-1)*8 + 3) = drmLR * Lmu(q) * dnumLnu;
%         qOut((ip-1)*8 + 4) = drmLR * dmumLmu * Lnu(q);
%         qOut((ip-1)*8 + 5) = LR(q) * dmumLmu * Lnu(q);
%         qOut((ip-1)*8 + 6) = drmLR * Lmu(q) * Lnu(q);
%         qOut((ip-1)*8 + 7) = LR(q) * Lmu(q) * dnumLnu;
%         qOut((ip-1)*8 + 8) = LR(q) * Lmu(q) * Lnu(q);
%         Icart(q) = Isph(iR(q),imu(q),inu(q)) ...
%             * qOut((ip-1)*8 + 1) + ...
%             Isph(iR(q)+1,imu(q),inu(q)) ...
%             * qOut((ip-1)*8 + 2) + ...
%             Isph(iR(q),imu(q)+1,inu(q)) ...
%             * qOut((ip-1)*8 + 3) + ...
%             Isph(iR(q),imu(q),inu(q)+1) ...
%             * qOut((ip-1)*8 + 4) + ...
%             Isph(iR(q)+1,imu(q),inu(q)+1) ...
%             * qOut((ip-1)*8 + 5) + ...
%             Isph(iR(q),imu(q)+1,inu(q)+1) ...
%             * qOut((ip-1)*8 + 6) + ...
%             Isph(iR(q)+1,imu(q)+1,inu(q)) ...
%             * qOut((ip-1)*8 + 7) + ...
%             Isph(iR(q)+1,imu(q)+1,inu(q)) ...
%             * qOut((ip-1)*8 + 8);
%         %qOut(q) = drmLR * dmumLmu * dnumLnu; 
%         %qOut(q,2) = LR(q) * dmumLmu * dnumLnu; 
%         %qOut(q,3) = drmLR * Lmu(q) * dnumLnu; 
%         %qOut(q,4) = drmLR * dmumLmu * Lnu(q); 
%         %qOut(q,5) = LR(q) * dmumLmu * Lnu(q); 
%         %qOut(q,6) = drmLR * Lmu(q) * Lnu(q); 
%         %qOut(q,7) = LR(q) * Lmu(q) * dnumLnu; 
%         %qOut(q,8) = LR(q) * Lmu(q) * Lnu(q); 
% % %         Icart(q) = Isph(iR(q),imu(q),inu(q)) ...
% % %           
% % %             Isph(iR(q),imu(q)+1,inu(q)+1) ...
% % %             * drmLR * Lmu(q) * Lnu(q) + ...
% % %             Isph(iR(q)+1,imu(q)+1,inu(q)) ...
% % %             * LR(q) * Lmu(q) * dnumLnu + ...
% % %             Isph(iR(q)+1,imu(q)+1,inu(q)) ...
% % %             * LR(q) * Lmu(q) * Lnu(q);
%      end
    
%end
end

