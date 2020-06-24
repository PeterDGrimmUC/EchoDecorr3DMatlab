function outIm = generateDecorrImage(BmodeIm, decorrVals,cutoff)
    assert(size(BmodeIm) == size(decorrVals))
    decorrVals(find(decorrVals < cutoff)) = 0;
    decorrVals = decorrVals - min(decorrVals) / (max(decorrVals) - min(decorrVals));
    h = decorrVals;
    s = decorrVals;
    v = BmodeIm; 
end