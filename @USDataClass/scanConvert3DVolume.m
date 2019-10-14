function scanConvert3DVolume(obj)
%scanConvert3DVolume: Scan converts volumetric ultrasound data
%   Example call: scanConvert3D(myVolume)
%   Parameters: 
%       thisVolume: Volume taken from 3D curved array transducer in polar
%       format where the first dimension is r, second is azimuth angle,
%       third is elevation angle
%       rmin,rmax: minimum and maximum bounds of the radius in the dataset,
%       assumes all successive radii are equally spaced
%       thetamin,thetamax: minimum and maximum azimuth angle, assumes all
%       angles are evently spaced
%       phimin,phimax: minimum and maximum elevation angle, assumes all
%       angles are evently spaced
    %% Define polar dimension arrays
    rk = linspace(obj.rmin,obj.rmax,size(obj.rawData,1));
    thetak = asin((linspace(sin(obj.thetamin),sin(obj.thetamax),size(obj.rawData,2))));
    phik = asin(linspace(sin(obj.phimin),sin(obj.phimax),size(obj.rawData,3)));
    %% define grids, image data
    [r_mat, steering_angles_mat,depth_angle_mat] = ndgrid(rk,thetak,phik);
    [cart_x,cart_y,cart_z] = sph2cart(steering_angles_mat,depth_angle_mat,r_mat);
    obj.xMin = min(cart_x(:));
    obj.xMax = max(cart_x(:));
    obj.yMin = min(cart_y(:));
    obj.yMax = max(cart_y(:));
    obj.zMin = min(cart_z(:));
    obj.zMax = max(cart_z(:));
    obj.dr = abs(diff(rk));
    obj.dr = obj.dr(1);
    % compute cartesian plane
    obj.dx = obj.dr*obj.cartScalingFactor;
    obj.dy = obj.dr*obj.cartScalingFactor;
    obj.dz = obj.dr*obj.cartScalingFactor;
    obj.x_range = obj.xMin:obj.dx:obj.xMax;
    obj.y_range = obj.yMin:obj.dy:obj.yMax;
    obj.z_range = obj.zMin:obj.dz:obj.zMax;
    [pos_mat_x,pos_mat_y,pos_mat_z] = ndgrid(obj.x_range,obj.y_range,obj.z_range);
    obj.rawData_cart = zeros(size(pos_mat_x,1),size(pos_mat_x,2),size(pos_mat_x,3),size(obj.rawData,4));
    %% interpolate 3D data
    % loop through volumes
    for currVolume = 1:size(obj.rawData,4) 
        obj.rawData_cart(:,:,:,currVolume)  = griddata(cart_x,cart_y,cart_z,obj.rawData(:,:,:,currVolume),pos_mat_x,pos_mat_y,pos_mat_z,'linear');
    end
end

