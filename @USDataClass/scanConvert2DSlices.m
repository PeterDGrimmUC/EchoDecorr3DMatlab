function [ scan_converted_volume,x_range,y_range,z_range ] = scanConvert2DSlices( thisVolume, rmin, rmax, thetamin, thetamax,phimin,phimax)
%% 3d scan convert multistage from 2d scan convert
%
r_arr = linspace(rmin,rmax,size(thisVolume,1));
theta_arr = linspace(thetamin,thetamax,size(thisVolume,2));
phi_arr = linspace(phimin,phimax,size(thisVolume,3));
[r_2d_points,theta_2d_points] = ndgrid(r_arr,theta_arr);
[x_2d_points,y_2d_points ] = pol2cart(theta_2d_points,r_2d_points);
minX = min(x_2d_points(:));
maxX = max(x_2d_points(:));
minY = min(y_2d_points(:));
maxY = max(y_2d_points(:));
dr = abs(diff(r_arr));
dr = dr(1);
dx = dr*3;
dy = dr*3;
[x_2d_mat,y_2d_mat] = ndgrid(minX:dx:maxX,minY:dy:maxY);

%interVolume = zeros()
for phi = 1:size(thisVolume,3)
   interVolume(:,:,phi) = griddata(x_2d_points,y_2d_points,thisVolume(:,:,phi),x_2d_mat,y_2d_mat); 
end
r_2_arr = linspace(rmin,rmax,size(interVolume,1));
[r_2_2d_points,phi_2d_points] = ndgrid(r_2_arr,phi_arr);
[x_2_2d_points,y_2_2d_points ] = pol2cart(phi_2d_points,r_2_2d_points);
minX = min(x_2_2d_points(:));
maxX = max(x_2_2d_points(:));
minY = min(y_2_2d_points(:));
maxY = max(y_2_2d_points(:));
dr = abs(diff(r_arr));
dr = dr(1);
dx = dr*5;
dy = dr*5;
[x_2_2d_mat,y_2_2d_mat] = ndgrid(minX:dx:maxX,minY:dy:maxY);

% interVolume(x',y',phi)
% y' is the new scan line
% 
for theta = 1:size(interVolume,2)
    finalVolume(:,theta,:) = griddata(x_2_2d_points,y_2_2d_points,squeeze(interVolume(:,theta,:)),x_2_2d_mat,y_2_2d_mat);
end
scan_converted_volume = finalVolume;
end

