%Testing calculation speeds for PIVlab. Feel free to share your results and your configuration on the PIVlab forums (http://pivlab.blogspot.de/p/forum.html)
clear all
close all
clc
try
    delete(gcp('nocreate'))
catch
end
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

%%
disp('...checking parallel computing availability...')
try
    ppool=parpool;
    if ppool.Connected == 1
        parallel_avail=1;
    else
        parallel_avail=0;
    end
catch
    parallel_avail=0;
end
if parallel_avail==1
    disp('...testing parallel computing performance...')
    tic
    %parallel
    parfor k=1:50
        for j=1:10000
            A=round(rand(64,64)*255);
            B=round(rand(64,64)*255);
            C =fftshift(real(ifft2(conj(fft2(A)).*fft2(B)))); %full line of code
        end
    end
    parallel_speed=toc;
    %serial
    tic
    for k=1:50
        for j=1:1000 %10x less tests for serial
            A=round(rand(64,64)*255);
            B=round(rand(64,64)*255);
            C =fftshift(real(ifft2(conj(fft2(A)).*fft2(B)))); %full line of code
        end
    end
    serial_speed=toc*10;
end
disp('...finished')
%%
disp('----------------------------------------')
disp('Your results (time per operation):')
disp(['mean DCC calculation speed:   ' num2str(mean(dccspeed)) ' ms'])
disp(['mean DFT calculation speed:   ' num2str(mean(dftspeed)) ' ms'])
disp(['Linear interpolation speed:   ' num2str(linspeed) ' ms'])
disp(['Spline interpolation speed:   ' num2str(splspeed) ' ms'])
if parallel_avail==1
    disp(['Speed increase with parallel computing:   ' num2str(round(serial_speed/parallel_speed,1)) 'x'])
end
ax=plotyy([1:128],dccspeed,[1:128],dftspeed);
title('Calculation speed [ms] of DCC and DFT')
xlabel('interrogation window size [px]')
ylabel(ax(1), 'DCC speed [ms]');
ylabel(ax(2), 'DFT speed [ms]');
