function o = numto14(num1,num2)
    tt1 = dec2bin(num1);
    tt2 = dec2bin(num2);
    t1 = [];
    t2 = [];
    for kk = 1:numel(tt1)
        t1(kk) = str2num(tt1(kk));
    end
    
    for kk = 1:numel(tt2)
        t2(kk) = str2num(tt2(kk));
    end
    if numel(t1) < 7
        t1 = [zeros(1,7-(numel(t1))),(t1)];
    end
    if numel(t2) < 7
        t2 = [zeros(1,7-(numel(t2))),(t2)];
    end
    t1 = t1(end-6:end);
    t2 = t2(end-6:end);
    t1f = [];
    t2f = [];
    for m = 1:numel(t1)
        t1f(m) = num2str(t1(m));
        t2f(m) = num2str(t2(m));
    end
    o = bin2dec([char(t1f) char(t2f)]);
end