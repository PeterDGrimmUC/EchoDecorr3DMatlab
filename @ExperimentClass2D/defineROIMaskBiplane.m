function defineROIMaskBiplane(obj)
    zVec = obj.initDataSet.z_range();
    yVec = obj.initDataSet.y_range();
    xVec = obj.initDataSet.x_range();
    %%
    [zGrid,yGrid]=ndgrid(zVec,yVec);
    obj.ROIPoints{end+1} = find((zGrid-obj.z0).^2 + (yGrid-obj.y0).^2 < obj.r0^2);
    temp= zeros(size(zGrid)); 
    temp(obj.ROIPoints{end}) = 1;
    obj.ROIMask{end+1} = temp; 
    %%
    [zGrid,xGrid]=ndgrid(zVec,xVec);
    obj.ROIPoints{end+1} = find((zGrid-obj.z0).^2 + (xGrid-obj.x0).^2 < obj.r0^2);
    temp= zeros(size(zGrid)); 
    temp(obj.ROIPoints{end}) = 1;
    obj.ROIMask{end+1} = temp; 
end