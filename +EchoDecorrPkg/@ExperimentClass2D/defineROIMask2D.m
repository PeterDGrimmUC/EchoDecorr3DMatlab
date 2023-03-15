function defineROIMask2D(obj)
    zVec = obj.initDataSet.z_range();
    yVec = obj.initDataSet.y_range();
    [zGrid,yGrid]=ndgrid(zVec,yVec);
    obj.ROIPoints = find((zGrid-obj.z0).^2 + (yGrid-obj.y0).^2 < obj.r0^2);
    obj.ROIMask = zeros(size(zGrid)); 
    obj.ROIMask(obj.ROIPoints) = 1; 
end