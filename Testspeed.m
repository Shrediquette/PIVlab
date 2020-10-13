%Testing calculation speeds for PIVlab. Feel free to share your results and your configuration on the PIVlab forums (http://pivlab.blogspot.de/p/forum.html)
clear all
close all
clc
disp('This script performs the four most time consuming calculations in PIVlab')
disp('and measures the time to complete them.')
disp('...testing calculation speed, please wait...')
%%
dccspeed=zeros(1,128);
    disp('...testing DCC...')
for j=1:128
    if mod(j,1.28)==0
    fprintf('%d%%\n',(round(j/128*100)));drawnow;
    end
    %A=rand(64,64)*255;
    %B=rand(128,128)*255;
    A=rand(j,j)*255;
    B=rand(j*2,j*2)*255;
    tic
    for i=1:5
        %for i=1:250
        %C= conv2(B,rot90(conj(A),2),'valid'); %full line of code
        Atemp=conj(A);
        Atemp=rot90(Atemp,2);
        C=conv2(B,Atemp,'valid');
    end
    dccspeed(j)=toc/i*1000;
 
end
%%
dftspeed=zeros(1,128);
    disp('...testing DFT...')
for j=1:128
    if mod(j,1.28)==0
    fprintf('%d%%\n',(round(j/128*100)));drawnow;
    end
    
    A=round(rand(j,j)*255);
    B=round(rand(j,j)*255);
    tic
    for i=1:100
        %C =fftshift(real(ifft2(conj(fft2(A)).*fft2(B)))); %full line of code
        Atemp=fft2(A);
        Atemp=conj(Atemp);
        Btemp=fft2(B);
        Atemp=(Atemp.*Btemp);
        Atemp=ifft2(Atemp);
        Atemp=real(Atemp);
        C=fftshift(Atemp);
    end
    dftspeed(j)=toc/i*1000;
end
%%
disp('...testing linear window deformation...')
A=679:743;
B=(71:135)';
C=round(rand(65,65)*255);
D=repmat(680:743,64,1)+rand(64,64);
E=repmat((72:135)',1,64)+rand(64,64);
tic
for i = 1:6000
    F=interp2(A,B,double(C),D,E,'*linear');
end
linspeed=toc/i*1000;
%%
disp('...testing spline window deformation...')
tic
for i = 1:1600
    F=interp2(A,B,double(C),D,E,'*spline');
end
splspeed=toc/i*1000;
disp('...finished')
%%
disp('----------------------------------------')
disp('Your results (time per operation):')
disp(['mean DCC calculation speed:   ' num2str(mean(dccspeed)) ' ms'])
disp(['mean DFT calculation speed:   ' num2str(mean(dftspeed)) ' ms'])
disp(['Linear interpolation speed:   ' num2str(linspeed) ' ms'])
disp(['Spline interpolation speed:   ' num2str(splspeed) ' ms'])
ax=plotyy([1:128],dccspeed,[1:128],dftspeed);
title('Calculation speed [ms] of DCC and DFT')
xlabel('interrogation window size [px]')
ylabel(ax(1), 'DCC speed [ms]');
ylabel(ax(2), 'DFT speed [ms]');
%% Williams results
%{
Acer Switch5
Intel Core i5-7200U CPU @ 2.50GHz
8 GB RAM
64 bit Win 10 Home
MATLAB 8.6.0.267246 (R2015b)

mean DCC calculation speed:   10.2573 ms
mean DFT calculation speed:   0.59817 ms
Linear interpolation speed:   0.28329 ms
Spline interpolation speed:   0.87221 ms
%}