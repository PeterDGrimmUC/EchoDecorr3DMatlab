call = @(fun,par) fun(par{:});
cellget = @(cell, index) cell{index};
applyF = @(f,x) f(x);
iff = @(test, truefn, falsefn, truePar, falsePar) call( ...
    cellget({falsefn, truefn}, test + 1), ... % functions
    cellget({falsePar, truePar}, test + 1) ... % params
);
iif = @(test, truefn, truePar,falsefn, falsePar) call( ...
    cellget({falsefn, truefn}, test + 1), ... % functions
    cellget({falsePar, truePar}, test + 1) ... % params
);
iswitchClosure = @(funcs)@(choice)funcs{choice};
map = @(expr, datIn) iff(iscell(datIn),...
                      @(expr,datIn) cellfun(expr,datIn,'UniformOutput',0),...
                      @(expr,datIn) arrayfun(expr,datIn,'UniformOutput',0),...
                      {expr,datIn},{expr,datIn});
mapU = @(expr, datIn) cell2mat(map(expr,datIn))';
dirSpec = @(targ) indexat(dir(targ),find(arrayfun(@(x)x.name(1)~='.', dir(targ)))); % remove files starting in .
dirPath = @(targ) fullfile(targ.folder,targ.name);
% find files matching regex
dirRegexInd = @(targetFolder,exprin) ...
            cell2mat(arrayfun(@(x) ~isempty(regexp(x.name,exprin,'once')), dir(targetFolder),'UniformOutput',0))';
dirRegex = @(targetFolder,exprin) indexat(dir(targetFolder), dirRegex(targetFolder, exprin));
mapIgnore=@(expr,datIn) mapIgnoreF(expr,datIn);
filterMap=@(f,x)indexatC(x,map(f,x));
replaceElm = @(datIn,index,newVals) replaceElmF(datIn,index,newVals);
invmap=@(datIn,funcs) map(@(x)x(datIn),funcs);
lcfun=@(outFunc,datIn,funcTerms)@(outFunc,datIn)outFunc();
flatten=@(x)x(:);
indexat = @(expr, index) expr(index);
indexatC = @(expr, index) expr(cell2mat(index));
%%
sci_note=@(x)applyF(@(z) strcat(),floor(log10(x)));
valAtSpec = @(rocObj, specVal) valAtSpecH(rocObj, specVal,@(x) log10(x));
TPf = @(obs,pred) sum((obs==true) & (pred == true));
FPf = @(obs,pred) sum((obs==false) & (pred == true));
FNf = @(obs,pred) sum((obs==true) & (pred == false));
TNf = @(obs,pred) sum((obs==false) & (pred == false));
diceF = @(obs,pred) 2 * TPf(obs,pred) / (2 * TPf(obs,pred) + FPf(obs,pred)+FNf(obs,pred));
%%
ste = @(x) std(x)/sqrt(length(x));
tAvgF=@(x) (x.t2+x.t3+x.t4)/2;
cartDistROC=@(x)((x.xr).^2+(1-x.yr).^2);
ptROCI=@(x,y) find(min(abs(log10(x.labels)-y))==abs(log10(x.labels)-y));
optimalPtROCI=@(x) (find(cartDistROC(x)==min(cartDistROC(x))));
optimalPtSens=@(x) x.yr(optimalPtROCI(x));
optimalPtSpec=@(x) 1-x.xr(optimalPtROCI(x));
ptSens=@(x,y) x.yr(ptROCI(x,y));
ptSpec=@(x,y) 1-x.xr(ptROCI(x,y));
ptVal=@(x,y) x.labels(ptROCI(x,y));
optimalPtVal=@(x) x.labels(1+optimalPtROCI(x));
ptROC=@(x,y) struct('sens',ptSens(x,y),'spec',ptSpec(x,y),'value',log10(ptVal(x,y)));
optimalROC=@(x) struct('sens',optimalPtSens(x),'spec',optimalPtSpec(x),'value',log10(optimalPtVal(x)));
unravel=@(x)x(:);
unravelAt=@(x,y)x(y);
mapreduce=@(x,y) mapReduceH(x,y);
%%
ndgridMultT=@(c)ndgridMultH(c);
maxind=@(d)maxindh(d);
function out=valAtSpecH(rocObj, specVal,f)
    specInd=find((1-rocObj.xr)>specVal);
    specInd = specInd(1);
    sensVal = rocObj.yr(specInd);
    specVal = 1-rocObj.xr(specInd);
    val= f(rocObj.labels(specInd));
    out=struct('val',val,'sens',sensVal,'spec',specVal);
end
%%
function output=mapIgnoreF(expr,datIn)
    output=cell(1,length(datIn));
    if iscell(datIn)
    for x=1:length(datIn)
        try
            output{x} = expr(datIn{x});
        catch
            
        end
    end
    else
    for x=1:length(datIn)
        try
            output{x} = expr(datIn(x));
        catch
        end
    end
    
    end
end
function output=replaceElmF(datIn,index,newVals)
    output=datIn;
    output(index)=newVals;
end
function output=ndgridMultH(cellsIn)
    [a,b,c]=ndgrid(cellsIn{1},cellsIn{2},cellsIn{3});
    output=a.*b.*c;
end
function output=maxindh(datIn)
    [~,output]=max(datIn);
end
function output=mapReduceH(funIn, datIn)
    if iscell(datIn)
        callFunc = @(x,y) x{y};
    else
        callFunc = @(x,y) x(y);
    end
    output=funIn(callFunc(datIn,length(datIn)-1),callFunc(datIn,length(datIn)));
    for i = length(datIn)-2:-1:1
        output=funIn(callFunc(datIn,i),output);
    end
end
