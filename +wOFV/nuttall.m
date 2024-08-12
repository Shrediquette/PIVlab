function w=nuttall(L,sflag)

%Construct a Nuttall window of length L. L must be a positive integer. 
%sflag is either 'sym' for a symmetric window (default) or 'per' for 
%periodic. This version creates a narrower Nuttall window than L, such that
%the outer 17 points on each side get essentially removed, this is to help
%with edge effects during wOFA/wOFV processing

if nargin==1
    sflag='sym';
end

a0=.355768;
a1=.487396;
a2=.144232;
a3=.012604;

L=L-32;

switch sflag
    case 'sym'
        n=(0:ceil(L/2)-1)';

        w=a0-a1*cos(2*pi*n/(L-1))+a2*cos(4*pi*n/(L-1))-a3*cos(...
            6*pi*n/(L-1));
        %Symmetric extension
        if rem(L,2)==0
            w=[w;wOFV.revvec(w)];
        else
            w=[w;wOFV.revvec(w(1:end-1))];
        end
        
    case 'per'
        L=L+1;
        
        n=(0:ceil(L/2)-1)';

        w=a0-a1*cos(2*pi*n/(L-1))+a2*cos(4*pi*n/(L-1))-a3*cos(...
            6*pi*n/(L-1));
        %Symmetric extension and truncation
        if rem(L,2)==0
            w=[w;wOFV.revvec(w(2:end))];
        else
            w=[w;wOFV.revvec(w(2:end-1))];
        end
end

w=[w(1)*ones(16,1);w;w(end)*ones(16,1)];