function ready = checkNextDataSetReady(obj)
    dirListing = preParseDir(dir(obj.dataFolder));
    ready = ~isempty(dirListing);
end
function dirListing = preParseDir(dirListing)
    dirListing=dirListing(~ismember({dirListing.name},{'.','..','Complete'}));
    dirListing=dirListing(arrayfun(@(y) isfolder(fullfile(y.folder,y.name)),dirListing));
end
