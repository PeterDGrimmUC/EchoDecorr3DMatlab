classdef SerialClass
    %SERIALCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serialObj; 
        RFGenData; 
        byteRate;
        startTime;
    end
    
    methods
        function obj = SerialClass(targetSerialPort,baudRate)
            %SERIALCLASS Construct an instance of this class
            %   wrapper for rf generator serial interface
            obj.serialObj = serialport(targetSerialPort,baudRate);
            obj.byteRate = obj.serialObj.BaudRate/2/8; 
            obj.RFGenData = [];
        end
        
        function obj = resetSerial(obj,targetSerialPort, baudRate)
            delete(obj.serialObj);
            obj.serialObj = serialport(targetSerialPort,baudRate);
            obj.byteRate = obj.serialObj.BaudRate/2/8; 
        end
        
        function obj = initSerialBlocks(obj)
            obj.serialObj.flush(); 
            obj.startTime = datetime();
        end
        
        function obj = getSerialBlock(obj)
            % Read data from serial port
            dat = obj.serialObj.read(obj.serialObj.NumBytesAvailable,'char');
            % set time 
            obj.startTime = datetime();
            % parse data
            outDat = SerialClass.parseSerialBlock(dat, obj.startTime,obj.byteRate);
            % add to set
            obj.RFGenData = [obj.RFGenData, outDat];
        end
    end
    methods (Static)
        function outDat = parseSerialBlock_dummy(datIn,startTime,byteRate)
            packetStartInds = find(datIn==127);
            packetLengths = diff(packetStartInds);
            currTime = startTime + seconds(packetStartInds(1)/byteRate);
            for currPacket = 1:length(packetStartInds)-1
                if packetLengths(currPacket) == 60
                    outDat(currPacket) = serialClass.parseOutput(datIn(packetStartInds+1:packetStartInds+60),currTime);
                else
                    outDat(currPacket) = serialClass.createDummyDat(currTime);
                end
                currTime = currTime + seconds(packetLengths(currPacket)/byteRate);
            end
            outDat(end) = createDummyDat(currTime);
        end
        
        function outDat = parseSerialBlock(datIn,startTime,byteRate)
            packetStartInds = find(datIn==127);
            packetLengths = diff(packetStartInds);
            currTime = startTime + seconds(packetStartInds(1)/byteRate);
            for currPacket = 1:length(packetStartInds)-1
                if packetLengths(currPacket) == 60
                    outDat(currPacket) = serialClass.parseOutput(datIn(packetStartInds+1:packetStartInds+60),currTime);
                end
                currTime = currTime + seconds(packetLengths(currPacket)/byteRate);
            end
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
    end
end

