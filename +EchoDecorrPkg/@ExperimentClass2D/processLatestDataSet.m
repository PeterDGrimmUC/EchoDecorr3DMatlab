function processLatestDataSet(obj)
    switch obj.mode
        case '2D'
            obj.dataSeries{end}.scanConvert2D();
            obj.dataSeries{end}.compute2DDecorr_Freq();
            obj.updateCumulativeDecorr(); 
        case 'biplane'
            obj.dataSeries{end}.scanConvertBiplane();
            obj.dataSeries{end}.computeBiplaneDecorr_Freq();
            obj.updateCumulativeDecorr();
    end
end

