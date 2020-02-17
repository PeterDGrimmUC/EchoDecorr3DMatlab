%clear
%testMat = randn(100,100,100);
%l = testMat
testMat = cumDec; 
l = logical(lesion3DGrid);
[xLength,yLength,zLength] = size(l);
mu = .01;
kernelDim = [7,7,7];
kernel = randn(kernelDim);
[xKern, yKern, zKern] = size(kernel);
mse = @(x,y) sum( (x- y).^2, 'All');
xOff = floor(xKern/2); 
yOff = floor(yKern/2); 
zOff = floor(zKern/2); 
epoch = 1;
n = 1; 
while true
    for x = xKern:(xLength-xKern)
        for y = yKern:(yLength-yKern)
            for z = zKern:(zLength-zKern)
                xRa = x-xOff:x+xOff; 
                yRa = y-yOff:y+yOff; 
                zRa = z-zOff:z+zOff; 
                l_prime = sum(testMat(xRa,yRa,zRa).*kernel,'All');
                e = l(x,y,z) - l_prime;
                dK = 2 * mu * e*testMat(xRa,yRa,zRa);
                kernel = kernel  + dK; 
                
            end
        end
    end
    if (mod(epoch-1,10) == 0)
        err(n) = mse(convn(testMat, kernel,'same'), l);
        n = n+1
        plot(err)
        drawnow; 
    end
    epoch = epoch + 1; 
end


%%
for n = 1:size(l,3)
    imagesc(testMat(:,:,n));
    pause(.1);
end