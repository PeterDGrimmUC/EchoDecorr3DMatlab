function Dm = read_lbdump_wrapc(filename)
% function Dm = read_lbdump(filename)
% function to read data memory dump by dui "lbdump" tool into Dm structure
% Inputs:
%   filename - string of filename, may include path information
% rcl

Dm.H = [];
Dm.data = [];

% read file according to known formatting per data type
fid = fopen(filename,'r');  
while 1,
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if strcmp(tline,'DataHdr'),
        mdfhdr = fscanf(fid,'%X%X%X%X%X%X%X');
        mdfdat = fscanf(fid,'$%X:%X\r\n',[2,mdfhdr(1)]).';
        headerType = mdfdat(1,2);
        dataType = mdfdat(2,2);
        ndim = mdfdat(3,2);
        sz = mdfdat(4:end,2).';
        if headerType ~= 1,
            error('upsupported header type detected');
        end
        if dataType == 0 || dataType == 2 || dataType == 4,
                cols = 1; % hww, ddm, cpe
        elseif dataType == 1 || dataType == 3,
                cols = 2; % adm, acd
        else
            error('unsupported data type detected');
        end
        if ndim ~= length(sz),
            error('incongruity of data header size detected');
        end
        break
    end
end

fclose(fid);
%%
mFile = memmapfile(filename);
endFound = false; 
for n = length(mFile.data):-1:1
    if mFile.data(n) == 58 % colon
        endIndex = n-1;
        endFound = true; 
    end
    if endFound && mFile.data(n) == 36 % dollar sign
        startIndex = n+1; 
        break
    end
end
t1 = 2 + hex2dec(char(mFile.data(startIndex:endIndex))');
[Dm.data,~] = read_lbdump_c(mFile.data',t1);
Dm.data = reshape(Dm.data,sz(2:end));
%%

% load spatial dimension sizes into header
Dm.H.rsz = size(Dm.data,1);
Dm.H.psz = size(Dm.data,2);
Dm.H.qsz = size(Dm.data,3);

% find an associated info file and read the data
infoFilename=[filename(1:end-12) 'info.txt'];
addInfoFilename=[filename(1:end-31) 'addParamFile.txt']
fid=fopen(infoFilename);
addFid = fopen(addInfoFilename)
if fid==-1 
    warning('failed to open info file')
    Dm.Info = struct([]);
else
    % pass back all information from info file in separate structure
    Dm.Info=readInfoFile(fid,addFid,Dm.H);  
    % get date
    fid=fopen(infoFilename);
    notEnd = true;
    n = 1;
    while notEnd
        currLine = fgetl(fid);
        if currLine ~= -1
           lineArr{n} = currLine;
        else
            notEnd = false;
        end
        n = n+1;

    end
    try 
        dateArr = strsplit(lineArr{end},'-');
        [M D Y H MI S MS]  = dateArr{:};
        try
            Dm.startTime = datetime(str2num(Y),str2num(M),str2num(D),str2num(H),str2num(MI),str2num(S),str2num(MS));
        catch
            Dm.startTime = strcat(Y,'-',M,'-',D,'-',H,'-',MI,'-',S,'-',MS);
        end
    catch
       display('unable to extract date') 
    end
    % end get date
    % populated imageformer expected header variables
    Dm.H.dr = 1/Dm.Info.NumSamplesPerMm;
    Dm.H.dt = Dm.H.dr/0.77;
    
    fclose(fid);
end

% shift according to BufWritePtrFrames to make frames temporaly continuous
% Note, scripts to populate BufWritePtrFrames are tenuous at best, so don't be fooled by these
% lines in the read script making you think you're guarenteed temporal continuity
if isfield(Dm,'Info') && isfield(Dm.Info,'BufWritePtrFrames'),
    if Dm.Info.BufWritePtrFrames == 0,
        disp('I found field Dm.Info.BufWritePtrFrames=0, so no circshift performed, zero means you are lucky and the buffer is already continous, or you used UI freeze instead of rtcFreeze and the ptr was reset before you dumped');
    else
        Dm.data = circshift(Dm.data,[0,0,0,-Dm.Info.BufWritePtrFrames]);
    end
end

% subfunction -------------------------------------------------------------
function headerStruct=readInfoFile(fid,fidAdd,headerStruct)

knownVariables.name={'BufSizeInLines','NumLinesPerPGroup',...
    'NumLinesPerSlice','NumRangeSamples','NumSlices',...
    'NumSlicesPerSubFrame','NumSlicesPerSweep','NumSamplesPerMm',...
    'NumFramesPerBuf','BufWritePtrFrames','feStreamId',...
    'NumLinesPerFrame'};
knownVariables.format={'hex','hex','hex','hex','hex','hex','hex','dec','hex','hex','hex','hex'};
numVariables=numel(knownVariables.name);
if numVariables~=numel(knownVariables.format)
    error('List of known variables is inconsistent!')
end

endOfFile=0;
% Step through all lines
while ~endOfFile
    lineText=fgetl(fid);
    if lineText==-1
        endOfFile=1;
    else
        % Look for = sign
        pos=strfind(lineText,'=');
        if ~isempty(pos)
            % Divide line into name and value
            leftStr=sscanf(lineText(1:pos-1),'%s');
            rightStr=sscanf(lineText(pos+1:end),'%s');
            if ~isempty(leftStr)
                entry=find(strcmp(leftStr,knownVariables.name));
                if ~isempty(entry)
                    name=leftStr;
                    switch knownVariables.format{entry}
                        case 'hex'
                            if strcmp(rightStr(1:2),'0x') || strcmp(rightStr(1:2),'0X'),
                                rightStr = rightStr(3:end);
                            end
                            value=hex2dec(rightStr);
                        case 'dec'
                            value=str2num(rightStr);
                    end
                    if isempty(value)
                        warning(sprintf('Value for variable %s could not be read from file',name))
                    else
                        headerStruct=setfield(headerStruct,name,value);
                    end
                end
            end
        end
    end
end
endOfFile = 0
try
while ~endOfFile
    lineText=fgetl(fidAdd);
    regexString = '(\w+)\W+=\W+(\w+)';
    if lineText==-1
        endOfFile=1;
    else
        [mat, tok, exp ] = regexp(lineText,regexString,'match','tokens', 'tokenExtents');
        if ~isempty(mat)
            varName = tok{1};
            varName = varName{1};
            varVal = tok{1};
            varVal = varVal{2};
            switch varName
                case 'frameRate'
                    headerStruct = setfield(headerStruct,'framerate',str2num(varVal));
                case 'depth'
                    headerStruct = setfield(headerStruct,'depth',str2num(varVal));
                case 'phiRange'
                    headerStruct = setfield(headerStruct,'phiRange',str2num(varVal));
                case 'thetaRange'
                    headerStruct = setfield(headerStruct,'thetaRange',str2num(varVal));
                otherwise
                    %error('Variable name not valid');
            end
        end
    end
end
catch
    display('Could not parse additional info file')
end
