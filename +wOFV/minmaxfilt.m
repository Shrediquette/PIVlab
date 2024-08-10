function Ifilt=minmaxfilt(Iraw,lfilt)

%Performs a local min/max filter for pre-processing PIV-type images.
%Iraw is the raw image to be processed and lfilt is the total length of the
%filter

Ires0=Iraw-imerode(Iraw,strel('square',lfilt));
Ires1=imdilate(Iraw,strel('square',lfilt));
Ires2=imdilate(Iraw,strel('square',10*lfilt-9));

Ifilt=Ires0.*Ires2./Ires1;