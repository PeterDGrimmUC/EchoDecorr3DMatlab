%%
instrreset
clear g
if (~exist('g'))
    g = serialport('COM8',9600);
end
%%
expNum = 6;
clear outputRaw timeArr
%%
% get params

currDate = date; 
startTime = clock;
configureTerminator(g,127)
% set up exit func
i = 1;
oFile = initFile(strcat('rfDataOut_',currDate,'_',num2str(expNum),'.tsv'));
tArr = [];
timeArr = []; 
while 1
g.flush()
%while(g.NumBytesAvailable < 60*4)
%end
cc = convertStringsToChars(g.readline);
while(length(cc) < 57)
    outputRaw(i) = g.readline;
    cc = convertStringsToChars(outputRaw(i));
end
timeArr(i,:) = clock;
nn = parseOutput(cc);
allDataArr(i) = nn;

writeToFile(oFile,nn)
tArr(i) = nn.t1;
impedanceArr(i) = nn.impedance;
powerArr(i) = nn.currentPower;
%figure(1)
%plot(tArr)
%figure(2)
%plot(impedanceArr);
%figure(3)
%plot(powerArr);
i = i+1;
end
%%
cleanUp(outputRaw, timeArr, currDate,expNum)
%%
function outs=parseOutput(inputLine)
    inputLine = convertStringsToChars(inputLine);
    outp = [];
    outs.t1 = numto14(inputLine(21),inputLine(22))/10;
    outs.t2 = numto14(inputLine(23),inputLine(24))/10;
    outs.t3 = numto14(inputLine(25),inputLine(26))/10;
    outs.t4 = numto14(inputLine(27),inputLine(28))/10;
    outs.targetPower = numto14(inputLine(11),inputLine(12))/10;
    outs.currentPower = numto14(inputLine(15),inputLine(16))/10;
    outs.targetTemp = numto14(inputLine(39),inputLine(40))/10;
    outs.impedance = numto14(inputLine(19),inputLine(20))/10;
    for i = 1:2:length(inputLine)-1
        kk = numto14(inputLine(i),inputLine(i+1));
        outp(i) = kk;
        kk
        i
    end
    
end
function hand = initFile(fName)
    hand1 = fopen(fName,'w')
    fwrite(hand1, 't1\tt2\tt3\tt4\tpow\n')
    hand = hand1;
end
function writeToFile(fileHandle, dStruct)
    outStr = strcat(num2str(dStruct.t1),'\t');
    outStr = strcat(outStr,num2str(dStruct.t2),'\t');
    outStr = strcat(outStr,num2str(dStruct.t3),'\t');
    outStr = strcat(outStr,num2str(dStruct.t4),'\t');
    outStr = strcat(outStr,num2str(dStruct.targetPower),'\n');
    fwrite(fileHandle,outStr)
end
% 21 23 25 27
function cleanUp(outputRaw,timeArr,currDate,expNum)
    save(strcat('outputRaw_exp_',currDate,'_',num2str(expNum),'.mat'),'outputRaw')
    save(strcat('time_exp_',currDate,'_',num2str(expNum),'.mat'),'timeArr')
end