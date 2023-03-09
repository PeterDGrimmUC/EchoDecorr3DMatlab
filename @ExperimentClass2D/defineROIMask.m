function defineROIPoints(obj)
switch obj.mode
    case '2D'
        obj.defineROIMask2D(); 
    case 'biplane'
        obj.defineROIMaskBiplane();
end
end

