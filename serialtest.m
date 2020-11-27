byteRate = g.BaudRate/2/8; % No idea why, but data rate is half of what would be expected from the baud rate
g.flush
startTime = datetime(); 
pause(10); 
dat = g.read(g.NumBytesAvailable,'char'); 
outDat = parseSerialBlock(dat, startTime,byteRate);
milliseconds(diff([outDat.time]))

function outDat = parseSerialBlock(datIn,startTime,byteRate)
    packetStartInds = find(datIn==127);
    packetLengths = diff(packetStartInds);
    currTime = startTime + seconds(packetStartInds(1)/byteRate);
    for currPacket = 1:length(packetStartInds)-1
        if packetLengths(currPacket) == 60
            outDat(currPacket) = parseOutput(datIn(packetStartInds+1:packetStartInds+60),currTime);
        else
            outDat(currPacket) = createDummyDat(currTime);
        end
        currTime = currTime + seconds(packetLengths(currPacket)/byteRate);
    end
    outDat(end) = createDummyDat(currTime);
end

function outs=parseOutput(inputLine,tStamp)
    inputLine = convertStringsToChars(inputLine);
    outs.t1 = numto14(inputLine(21),inputLine(22))/10;
    outs.t2 = numto14(inputLine(23),inputLine(24))/10;
    outs.t3 = numto14(inputLine(25),inputLine(26))/10;
    outs.t4 = numto14(inputLine(27),inputLine(28))/10;
    outs.targetPower = numto14(inputLine(11),inputLine(12))/10;
    outs.currentPower = numto14(inputLine(15),inputLine(16))/10;
    outs.targetTemp = numto14(inputLine(39),inputLine(40))/10;
    outs.impedance = numto14(inputLine(19),inputLine(20))/10;
    outs.time = tStamp; 
end

function outs = createDummyDat(tStamp)
    outs.t1 = NaN;
    outs.t2 = NaN;
    outs.t3 = NaN;
    outs.t4 = NaN;
    outs.targetPower = NaN;
    outs.currentPower = NaN;
    outs.targetTemp = NaN;
    outs.impedance = NaN;
    outs.time = tStamp; 
end