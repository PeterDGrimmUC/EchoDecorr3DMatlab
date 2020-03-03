t0 = 0; 
t1 = 5*10^-6;
f0 = 5*10^6; 
f1 = 9*10^6;
fs = f1 * 10;
t = t0:1/fs:t1; 
x = chirp(t,f0,t1,f1);
figure(1)
plot(t*10^6,x)
xlabel('t (\mus)')
ylabel('Amplitude')
title('Chirp Signal')
%plot((1:length(x))*(fs/length(x))*10^-6,abs(fft(x)))
%%
gPuls = gauspuls(t,7*10^6,.5);
figure(2)
plot(t*10^6,gPuls)
xlabel('t (\mus)')
ylabel('Amplitude')
title('Gaussian Pulse')
%%
convedSig = conv(x,gPuls,'same');
figure(3)
plot(t*10^6,convedSig)
xlabel('t (\mus)')
ylabel('Amplitude')
title('Modulated Pulse')
%%
matchedSig = abs(xcorr(convedSig,x));
figure(4)
plot(matchedSig)
xlabel('t (s)')
ylabel('Amplitude')
title('Matched Signal')