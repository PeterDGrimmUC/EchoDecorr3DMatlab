function infoOut = getInitInfo(obj)
            % getInitInfo: Get scanner parameters from 'extra data file'
            %
            % Gets data from the 'extra data file', which is created by the
            % scanner script. Contains information about scanner
            % parameters, targets previously set initial data set folder. 
            %
            % Usage:
            %   infoOut = getInitInfo(obj)
            %           inputs:
            %             None
            %           outputs:
            %             infoOut: Data from extra data file
            %               Index 1: Frame rate
            %               Index 2: depth (mm)
            %               Index 3: Azimuth scan angle range (degrees)
            %               Index 4: Azimuth scan angle range (degrees)
            
            infoOut = ones(1,4);
            folderDir = dir(obj.dataFolder);
            folderDir = folderDir([folderDir.isdir]);
            invalidFolders = {'.','..','Complete','ready'};
            binOut = ones(1,numel(folderDir));
            for invalidFoldN = 1:numel(invalidFolders)
                binOut = ~arrayfun(@(x) strcmp(x.name,invalidFolders(invalidFoldN)),folderDir)' & binOut;
            end
            dataSetList = folderDir(binOut); 
            chosenfile = dataSetList(1).name;
            fileName = fullfile(obj.dataFolder,chosenfile,'addParamFile.txt');
            fidAdd = fopen(fileName);
            endOfFile = 0;
            while ~endOfFile
                lineText=fgetl(fidAdd);
                regexString = '(\w+)\W+=\W+(\w+)';
                if lineText==-1
                    endOfFile=1;
                else
                    [mat, tok, ~ ] = regexp(lineText,regexString,'match','tokens', 'tokenExtents');
                    if ~isempty(mat)
                        varName = tok{1};
                        varName = varName{1};
                        varVal = tok{1};
                        varVal = varVal{2};
                        switch varName
                            case 'frameRate'
                                infoOut(1) = str2num(varVal);
                            case 'depth'
                                infoOut(2) = str2num(varVal);
                            case 'phiRange'
                                infoOut(3) = str2num(varVal);
                            case 'thetaRange'
                                infoOut(4) = str2num(varVal);
                            otherwise
                                error('Variable name not valid');
                        end
                    end
                end
            end
            
        end