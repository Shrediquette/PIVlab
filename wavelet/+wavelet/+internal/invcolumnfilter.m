function y = invcolumnfilter(x,ha,hb)
% This function is for internal use only, it may change or be removed in a
% future release.
% y = invcolumnfilter(x,ha,hb);
%

%   Copyright 2019-2020 The MathWorks, Inc.

%#codegen

% Obtain number of rows and columns of x
[Nr,Nc] = size(x);
Nh = numel(ha);


% Half the filter length
% Filter length is even for q-shift filters. This routine is not used for 
% biorthogonal filters
Nh2 = Nh/2;
% Allocate array for output
y = coder.nullcopy(complex(zeros(2*Nr,Nc,'like',x)));


% Reflection of input indices
rowidx = wavelet.internal.reflectIdx(Nr,Nh2);
% Polyphase components of the filters. Note we are following the MATLAB
% 1-based indexing convention for designating odd and even.
hao = coder.nullcopy(zeros([Nh2 1],'like',ha));
hae = coder.nullcopy(zeros([Nh2 1],'like',ha));
hbo = coder.nullcopy(zeros([Nh2 1],'like',hb));
hbe = coder.nullcopy(zeros([Nh2 1],'like',hb));
hao(:) = ha(1:2:Nh);
hae(:) = ha(2:2:Nh);
hbo(:) = hb(1:2:Nh);
hbe(:) = hb(2:2:Nh);

s = 1:4:(Nr*2);
if signalwavelet.internal.iseven(Nh2)
        
    t = 4:2:(Nr+Nh);
    if dot(ha,hb) > 0
        ta = t; 
        tb = t - 1;
    else
        ta = t - 1; 
        tb = t;
    end
    y(s,:,:)   = conv2(x(rowidx(tb-2),:),hae(:),'valid');
    y(s+1,:,:) = conv2(x(rowidx(ta-2),:),hbe(:),'valid');
    y(s+2,:,:) = conv2(x(rowidx(tb),:),hao(:),'valid');
    y(s+3,:,:) = conv2(x(rowidx(ta),:),hbo(:),'valid');
    
    
    
else
    
    t = 3:2:(Nr+Nh-1);
    if dot(ha,hb) > 0
        ta = t; 
        tb = t - 1;
    else
        ta = t - 1;
        tb = t;
    end
        
    s = 1:4:(Nr*2);
    
      
    y(s,:)   = conv2(x(rowidx(tb),:),hao(:),'valid');
    y(s+1,:) = conv2(x(rowidx(ta),:),hbo(:),'valid');
    y(s+2,:) = conv2(x(rowidx(tb),:),hae(:),'valid');
    y(s+3,:) = conv2(x(rowidx(ta),:),hbe(:),'valid');
    

end
    
    

