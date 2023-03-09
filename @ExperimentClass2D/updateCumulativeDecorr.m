function updateCumulativeDecorr(obj)
    adjDecorrF =@(dat,init) (dat-init)./(1-init);
    switch obj.mode
        case '2D'
            initDecorr = obj.initDataSet.decorr;
            if isempty(obj.cumulativeDecorr)
                obj.cumulativeDecorr = obj.dataSeries{1}.decorr;
                obj.adjCumulativeDecorr = adjDecorrF(initDecorr,initDecorr);
                initMeanDecorrSeries(obj); 
            end
            adjDecorr = adjDecorrF(obj.dataSeries{end}.decorr,initDecorr); 
            obj.adjCumulativeDecorr = max(obj.adjCumulativeDecorr, adjDecorr);
            obj.cumulativeDecorr = max(obj.cumulativeDecorr,obj.dataSeries{end}.decorr);
            updateDecorrSeries(obj,obj.dataSeries{end}.decorr,adjDecorr, obj.cumulativeDecorr,obj.adjCumulativeDecorr);
        case 'biplane'
            initDecorr = {};
            adjDecorr = {};
            initDecorr{end+1} = obj.initDataSet.decorr{1};
            initDecorr{end+1} = obj.initDataSet.decorr{2};
            if isempty(obj.cumulativeDecorr)
                obj.cumulativeDecorr{end+1} = obj.dataSeries{1}.decorr{1};
                obj.cumulativeDecorr{end+1} = obj.dataSeries{1}.decorr{2};
                obj.adjCumulativeDecorr{end+1} = adjDecorrF(initDecorr{1},initDecorr{1});
                obj.adjCumulativeDecorr{end+1} = adjDecorrF(initDecorr{2},initDecorr{2});
                initMeanDecorrSeries(obj); 
            end
            adjDecorr{end+1} = adjDecorrF(obj.dataSeries{end}.decorr{1},initDecorr{1}); 
            adjDecorr{end+1} = adjDecorrF(obj.dataSeries{end}.decorr{2},initDecorr{2}); 
            obj.adjCumulativeDecorr{1} = max(obj.adjCumulativeDecorr{1}, adjDecorr{1});
            obj.adjCumulativeDecorr{2} = max(obj.adjCumulativeDecorr{2}, adjDecorr{2});
            obj.cumulativeDecorr{1} = max(obj.cumulativeDecorr{1},obj.dataSeries{end}.decorr{1});
            obj.cumulativeDecorr{2} = max(obj.cumulativeDecorr{2},obj.dataSeries{end}.decorr{2});
            
            updateDecorrSeries(obj,obj.dataSeries{end}.decorr,adjDecorr, obj.cumulativeDecorr,obj.adjCumulativeDecorr);
    end
end
function initMeanDecorrSeries(obj)
    switch obj.mode
        case '2D'
            obj.meanDecorrSeries = []; 
            obj.meanDecorrSeriesAdj = [];
            obj.meanDecorrSeriesROI = [];
            obj.meanDecorrSeriesROIAdj = [];
        case 'biplane'
            obj.meanDecorrSeries = {[],[]}; 
            obj.meanDecorrSeriesAdj = {[],[]};
            obj.meanDecorrSeriesROI = {[],[]};
            obj.meanDecorrSeriesROIAdj = {[],[]};
    end
end
function updateDecorrSeries(obj, dec,decAdj,cumDec,cumDecAdj)
    switch obj.mode
        case '2D'
            obj.meanDecorrSeries(end+1) = mean(cumDec(:)); 
            obj.meanDecorrSeriesAdj(end+1) = mean(decAdj(:));
            obj.meanDecorrSeriesROI(end+1) = mean(cumDec(obj.ROIPoints));
            obj.meanDecorrSeriesROIAdj(end+1) = mean(cumDecAdj(obj.ROIPoints));
        case 'biplane'
            plane1ds = obj.meanDecorrSeries{1}; 
            plane2ds = obj.meanDecorrSeries{2};
            
            plane1dsa = obj.meanDecorrSeriesAdj{1}; 
            plane2dsa = obj.meanDecorrSeriesAdj{2};
            
            plane1dsr = obj.meanDecorrSeriesROI{1};
            plane2dsr = obj.meanDecorrSeriesROI{2};
            
            plane1dsar = obj.meanDecorrSeriesROIAdj{1};
            plane2dsar = obj.meanDecorrSeriesROIAdj{2};
            
            dec1 = dec{1};
            dec2 = dec{2};
            
            decAdj1 = decAdj{1};
            decAdj2 = decAdj{2};
            
            cumDec1 = cumDec{1};
            cumDec2 = cumDec{2};
            
            cumDecAdj1 = cumDecAdj{1};
            cumDecAdj2 = cumDecAdj{2};
            
            plane1ds(end+1) = mean(cumDec1(:));
            plane2ds(end+1) = mean(cumDec2(:)); 
            
            plane1dsa(end+1) = mean(decAdj1(:));
            plane2dsa(end+1) = mean(decAdj2(:)); 
            
            plane1dsr(end+1) = mean(cumDec1(obj.ROIPoints{1}));
            plane2dsr(end+1) = mean(cumDec2(obj.ROIPoints{2})); 
            
            plane1dsar(end+1) = mean(cumDecAdj1(obj.ROIPoints{1}));
            plane2dsar(end+1) = mean(cumDecAdj2(obj.ROIPoints{2})); 
            
            obj.meanDecorrSeries = {plane1ds,plane2ds};
            obj.meanDecorrSeriesAdj = {plane1dsa,plane2dsa};
            obj.meanDecorrSeriesROI = {plane1dsr,plane2dsr};
            obj.meanDecorrSeriesROIAdj = {plane1dsar,plane2dsar};
            
    end
end
