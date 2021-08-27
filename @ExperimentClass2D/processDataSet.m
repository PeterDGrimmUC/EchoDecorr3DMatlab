function processDataSet(obj,ind)
    switch obj.mode
        case '2D'
            obj.dataSeries{ind}.scanConvert2D();
            obj.dataSeries{ind}.compute2DDecorr_Freq(); 
        case 'biplane'
            obj.dataSeries{ind}.scanConvertBiplane();
            obj.dataSeries{ind}.computeBiplaneDecorr_Freq();
    end
end

