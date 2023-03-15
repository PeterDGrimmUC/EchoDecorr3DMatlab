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
[fileName dirName]= uigetfile('*.pmcr');
Dm = read_lbdump([dirName '/' fileName]);% Dm.data has IQ data
% Dm = read_lbdump(fileName);
% volume = Dm.data;
thisVolume = squeeze(Dm.data(:,:,:,2));

%% set up the parameters
tic
Isph = thisVolume;
global p dR LR dmu Lmu dnu Lnu iR imu inu R0
sizeR = size(thisVolume,1);
sizeAz = size(thisVolume,2);
sizeEl = size(thisVolume,3);

% define coordinates on pyramidal grid
azAngle = 61/2; elAngle = 61/2;
Rmin = 0; Rmax = 100; dR = Rmax/(sizeR-1);         % range (mm)
Rvec = Rmin:dR:Rmax; 

% sin theta (azimuth)
mumax = sind(azAngle); mumin=-mumax; 
muvec = linspace(mumin,mumax,sizeAz);
dmu = muvec(2)-muvec(1);

% sin phi (elevation)
numax = sind(elAngle); numin=-numax; 
nuvec = linspace(numin,numax,sizeEl);
dnu = nuvec(2)-nuvec(1);

[R,mu,nu] = ndgrid(Rvec,muvec,nuvec);

% Cartesian grid, onto which we're scan-converting (interpolating)
scale =2;
dz = scale*dR;%0.5;  % spatial step
maxY = Rmax*sind(azAngle); maxZ = Rmax*sind(elAngle);
zvec = 0:dz:Rmax;  % depth
yvec = -maxY:dz:maxY; %-32:dz:32;  % azimuth
xvec = -maxZ:dz:maxZ; %-31:dz:31;  % elevation;
[z,y,x] = ndgrid(zvec,yvec,xvec);

%defining image cross sections (default: half range, az., el.)
ixmid = find(abs(xvec)==min(abs(xvec)));
iymid = find(abs(yvec)==min(abs(yvec)));
izmid = ceil(size(zvec,2)/2); 

% pyramidal coordinates of Cartesian grid points
R0 = sqrt(x.^2+y.^2+z.^2); 
mu0 = y./sqrt(z.^2+y.^2);
nu0 = x./(sqrt(R0.^2-y.^2));

% find Cartesian points inside pyramid to interpolate
p = find(R0>=Rmin & R0<=Rmax-dR & mu0>=mumin & mu0<=mumax-dmu & ...
          nu0>=numin & nu0<=numax-dnu); % points for valid interpolation

image_initialization_time = toc 

tic;
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
iR(p) = floor((R0(p) - Rmin)/dR) + 1;
LR(p) = R0(p) - Rvec(iR(p))';

interpolation_initialization_time = toc

tic;
Icart = frustumInterp(thisVolume);
interpolation_time = toc

%% Displaying the interpolated images
maxuu = .4; dbrange = 55;
thisVolumeScaled = (10*log10(abs(thisVolume./maxuu).^2)+dbrange)/dbrange;
% plot cross sections of results for comparison
%Spherical IQ data
figure(1);
subplot(2,2,1); 
imagesc(yvec,zvec,abs(thisVolumeScaled(:,:,21)));
xlabel('y (mm)');
ylabel('z (mm)');
title('Isph');colorbar; colormap gray; axis equal, axis tight;
subplot(2,2,2); 
imagesc(xvec,zvec,abs(squeeze(thisVolumeScaled(:,23,:))),[0 1]);
xlabel('x (mm)');
ylabel('z (mm)');colorbar; colormap gray; axis equal, axis tight;
subplot(2,2,3); 
imagesc(yvec,xvec,abs(squeeze(thisVolumeScaled(179,:,:))));
xlabel('y (mm)');
ylabel('x (mm)');colorbar; colormap gray; axis equal, axis tight;

%Cartesian interpolated data
IcartScaled = (10*log10(abs(Icart./maxuu).^2)+dbrange)/dbrange;
figure(2);
subplot(2,2,1); 
imagesc(yvec,zvec,abs(IcartScaled(:,:,ixmid)));
xlabel('y (mm)');
ylabel('z (mm)');
title('Interpolated'); colorbar; colormap gray; axis equal, axis tight;
subplot(2,2,2); 
imagesc(xvec,zvec,abs(squeeze(IcartScaled(:,ixmid,:))));
xlabel('x (mm)');
ylabel('z (mm)');colorbar; colormap gray; axis equal, axis tight; 
subplot(2,2,3); 
imagesc(yvec,xvec,abs(squeeze(IcartScaled(ixmid,:,:))));
xlabel('y (mm)');
ylabel('x (mm)');colorbar; colormap gray; axis equal, axis tight;


% %defining image cross sections (default: half range, az., el.)
% ixmidSph = ceil(sizeEl/2);
% iymidSph = ceil(sizeAz/2);
% izmidSph = ceil(sizeR/2); 
% 
% coord = sph2cartMod2(asin(mu),asin(nu),R); 
% figure(3); 
% subplot(221);
% surf(squeeze(coord.y(:,:,ixmidSph)),squeeze(coord.z(:,:,ixmidSph)),...
%     abs(thisVolumeScaled(:,:,ixmidSph)),'edgecolor','none');
% view(0,90), colorbar, colormap gray; axis equal, axis tight;
% xlabel('y [mm]')
% ylabel('z [mm]'), set(gca,'Ydir','reverse')
% subplot(222);
% surf(squeeze(coord.x(:,iymidSph,:)),squeeze(coord.z(:,iymidSph,:)),...
%     squeeze(abs(thisVolumeScaled(:,iymidSph,:))),'edgecolor','none');
% view(0,90), colorbar, colormap gray; axis equal, axis tight;
% xlabel('x [mm]')
% ylabel('z [mm]'), set(gca,'Ydir','reverse')
% subplot(223);
% surf(squeeze(coord.y(izmidSph,:,:)),squeeze(coord.x(izmidSph,:,:)),...
%     squeeze(abs(thisVolumeScaled(izmidSph,:,:))),'edgecolor','none');
% view(0,90), colorbar, colormap gray; axis equal, axis tight;
% xlabel('y [mm]')
% ylabel('x [mm]'), set(gca,'Ydir','reverse')