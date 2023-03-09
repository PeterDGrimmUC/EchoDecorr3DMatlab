 function defineGridBounds(obj)
            % defineGridBounds: define bounds for a subregion to save on computation time, often unnessesary due to other optimizations
            %
            % Find the minimum bounds that will contain the entire target region with a margin of 3*sigma, does this computationally due to infeasibility of an analytic expression for an arbitrary rotated ellipsoid
            %
            % Usage:
            %   defineGridBounds(obj)
            %     inputs:
            %        None
            %     outputs:
            %        None
            xMid = obj.initDataSet.x_range(floor(end/2));
            yMid = obj.initDataSet.y_range(floor(end/2));
            zMid = obj.initDataSet.z_range(floor(end/2));
            diffX = abs(obj.initDataSet.x_range(1) - obj.initDataSet.x_range(2));
            diffY = abs(obj.initDataSet.y_range(1) - obj.initDataSet.y_range(2));
            diffZ = abs(obj.initDataSet.z_range(1) - obj.initDataSet.z_range(2));
            [xGrid,yGrid,zGrid] = ndgrid(obj.initDataSet.x_range-xMid,obj.initDataSet.y_range-yMid,obj.initDataSet.z_range-zMid);
            validPoints = find(((xGrid).^2./((obj.ROIr0+6*obj.sigma)^2) + (yGrid).^2./((obj.ROIr1+6*obj.sigma)^2) + (zGrid).^2./((obj.ROIr2+6*obj.sigma)^2))<1);
            finalGrid = zeros(size(xGrid));
            finalGrid(validPoints) = 1;
            finalGrid = reshape(finalGrid,(size(xGrid)));
            finalGrid = imrotate3(finalGrid, obj.ROIAlpha,[1 0 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIBeta,[0 1 0],'crop');
            finalGrid = imrotate3(finalGrid, obj.ROIGamma,[0 0 1],'crop');
            finalGrid = imtranslate(finalGrid, [(obj.ROIx0-xMid)/diffX,(obj.ROIy0-yMid)/diffY,(obj.ROIz0-zMid)/diffZ ]);
            finalGrid = logical(finalGrid);
            pts = find(finalGrid == 1); 
            [xGrid,yGrid,zGrid] = ndgrid(obj.initDataSet.x_range,obj.initDataSet.y_range,obj.initDataSet.z_range);
           
            R = sqrt(xGrid.^2 + yGrid.^2 + zGrid.^2);
            Theta = yGrid./(sqrt(zGrid.^2 + yGrid.^2));
            Phi = xGrid./(sqrt(R.^2 - yGrid.^2));
            ROIR = R(pts); maxR = max(ROIR); minR = min(ROIR);
            ROITheta = Theta(pts); maxTheta = max(ROITheta); minTheta = min(ROITheta);
            ROIPhi = Phi(pts); maxPhi = max(ROIPhi); minPhi = min(ROIPhi);
            
            sizeAz = size(obj.initDataSet.rawData,2);
            sizeEl = size(obj.initDataSet.rawData,3);
            obj.dr = 1/obj.initDataSet.InfoFile.NumSamplesPerMm;         % range (mm)
            obj.rmin = obj.initDataSet.rmin;
            obj.rmax = obj.initDataSet.rmax;
            RVec = obj.rmin:obj.dr:obj.rmax;
            muVec = linspace(sin(obj.thetamin),sin(obj.thetamax), sizeAz);
            nuVec = linspace(sin(obj.phimin),sin(obj.phimax), sizeEl);
           
            
            obj.subRegionRbounds = [minR,maxR];
            obj.subRegionThetabounds = [minTheta,maxTheta];
            obj.subRegionPhibounds = [minPhi,maxPhi];
            [~,minRi] = min(abs(minR-RVec));
            [~,maxRi] = min(abs(maxR-RVec));
            [~,minThetai] = min(abs(minTheta-muVec));
            [~,maxThetai] = min(abs(maxTheta-muVec));
            [~,minPhii] = min(abs(minPhi-nuVec));
            [~,maxPhii] = min(abs(maxPhi-nuVec));
            
            obj.subRegionRboundsi = [minRi,maxRi];
            obj.subRegionThetaboundsi = [minThetai,maxThetai];
            obj.subRegionPhiboundsi = [minPhii,maxPhii];
            rmin = obj.subRegionRbounds(1);
            rmax = obj.subRegionRbounds(2);
            thetamin = obj.subRegionThetabounds(1);
            thetamax = obj.subRegionThetabounds(2);
            phimin = obj.subRegionPhibounds(1);
            phimax = obj.subRegionPhibounds(2);
            rV = obj.subRegionRboundsi(1):obj.subRegionRboundsi(2);
            thetaV = obj.subRegionThetaboundsi(1):obj.subRegionThetaboundsi(2);
            phiV = obj.subRegionPhiboundsi(1):obj.subRegionPhiboundsi(2);
            tempDataSet = USDataClass(obj.initDataSet.rawData,obj.initDataSet.time, obj.initDataSet.InfoFile,rmin,rmax,thetamin,thetamax,phimin,phimax,obj.cartScalingFactor,obj.sigma,obj.interFrameTime);
            tempDataSet.scanConv_Frust(); 
            [~,xMini] = min(abs(tempDataSet.x_range(1)-obj.initDataSet.x_range));
            [~,yMini] = min(abs(tempDataSet.y_range(1)-obj.initDataSet.y_range));
            [~,zMini] = min(abs(tempDataSet.z_range(1)-obj.initDataSet.z_range));
            xRa = xMini:xMini+numel(tempDataSet.x_range)-1;
            yRa = yMini:yMini+numel(tempDataSet.y_range)-1;
            zRa = zMini:zMini+numel(tempDataSet.z_range)-1;
            obj.ROIMapSubregion = obj.ROIMap(xRa,yRa,zRa);
            obj.regionOverlay = zeros(size(obj.ROIMap)); 
            obj.regionOverlay(xRa,yRa,zRa) = 1; 
            obj.subRegionXRange = xRa; 
            obj.subRegionYRange = yRa; 
            obj.subRegionZRange = zRa; 
            obj.subRegionXbounds = [xRa(1), xRa(end)];
            obj.subRegionYbounds = [yRa(1), yRa(end)];
            obj.subRegionZbounds = [zRa(1), zRa(end)];
            obj.xVec_sub = tempDataSet.x_range;
            obj.yVec_sub = tempDataSet.y_range;
            obj.zVec_sub = tempDataSet.z_range;
end