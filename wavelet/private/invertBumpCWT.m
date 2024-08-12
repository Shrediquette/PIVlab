function xrec = invertBumpCWT(cfs,scales,param,dt)
%   Function to invert CWT obtained using the bump wavelet

%   Copyright 2015-2020 The MathWorks, Inc.

ScType = getScType(scales);
if isempty(param)
    mu = 5;
    sigma = 0.6;
else
    mu = param(1);
    sigma = param(2);
end
bumpwav = @(w)abs(exp(1)*exp(-1./(1-((w-mu)/sigma).^2)))./w;
Cpsi = integral(bumpwav,mu-sigma,mu+sigma);

if strcmpi(ScType,'log')
    a0 = scales(2)/scales(1);
    Wr = 2*log(a0)*(1/Cpsi)*real(cfs);
    xrec = sum(Wr,1);
else
    scales = scales./dt;
    ds = mean(diff(scales));
    repSca = repmat(scales',[1, size(cfs,2)]);
    Wr = 2*ds*(1/Cpsi)*real(cfs./repSca);
    xrec = sum(Wr,1);
end

%---------------------------------------------------------------------
function ScType = getScType(scales)
% Determine if scales are linear or log
DF1 = sum(diff(scales,2));
scaleratio = log(scales/scales(1));
DF2 = sum(diff(scaleratio,2)); 
    if (abs(DF1)<sqrt(eps))
        ScType = 'linear';
    elseif (abs(DF2) < sqrt(eps))
        ScType = 'log';
    
    else
       ScType = 'undetermined';
    
end
