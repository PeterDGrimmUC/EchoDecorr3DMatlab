function  runOnlineExperiment(obj)
    numFolders = length(preParseDir(dir(obj.dataFolder)));
    for i = 1:numFolders
        obj.getNextDataSet()
        obj.processDataSet(i); 
    end
    adjDecorrF =@(dat,init) (dat-init)./(1-init);
    switch obj.mode
        case '2D'
            if isempty(obj.cumulativeDecorr)
                obj.cumulativeDecorr = obj.dataSeries{1}.decorr;
            end
            initDecorr = obj.dataSeries{1}.decorr;
            
            obj.adjCumulativeDecorr = adjDecorrF(initDecorr,initDecorr);
            for i = 1:length(cumulativeDecorr)
                adjDecorr = adjDecorrF(obj.dataSeries{i}.decorr,initDecorr); 
                obj.adjCumulativeDecorr = max(obj.adjCumulativeDecorr, adjDecorr);
                obj.cumulativeDecorr = max(obj.cumulativeDecorr,obj.dataSeries{i}.decorr);
            end
        case 'biplane'
            if isempty(obj.cumulativeDecorr)
                obj.cumulativeDecorr{end+1} = obj.dataSeries{1}.decorr{1};
                obj.cumulativeDecorr{end+1} = obj.dataSeries{1}.decorr{2};
            end
            
            for i = 1:length(obj.cumulativeDecorr)
                obj.cumulativeDecorr{1} = max(obj.cumulativeDecorr{1},obj.dataSeries{i}.decorr{1});
                obj.cumulativeDecorr{2} = max(obj.cumulativeDecorr{2},obj.dataSeries{i}.decorr{2});
            end
    end
end


function dirListing = preParseDir(dirListing)
    dirListing=dirListing(~ismember({dirListing.name},{'.','..','Complete'}));
    dirListing=dirListing(arrayfun(@(y) isfolder(fullfile(y.folder,y.name)),dirListing));
end