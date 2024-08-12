function [S,U] = scatteringTransform(self,x)
%Wavelet 1-D scattering transform with metadata
%   S = scatteringTransform(SN,X) returns the wavelet 1-D scattering
%   transform of X with metadata for the scattering network, SN. X is a
%   real-valued vector, matrix, or 3-D array. If X is a vector, the number
%   of samples in X must match the SignalLength property of SN. If X is a
%   matrix or 3-D array, the number of rows in X must match the
%   SignalLength property of SN. S is an NO-by-1 cell array of MATLAB
%   tables where NO is the number of orders in the scattering transform.
%   The i-th element of S contains the scattering transform coefficients
%   with metadata for the (i-1)-th order.
%
%   Each MATLAB table in S contains the following variables:
%
%       signals: A cell array of scattering coefficients. Each element of
%       signals is a Ns-by-Nchannel-by-Nbatch array where Ns is the number
%       of scattering coefficients.
%
%       path: The scattering path used to obtain the scattering
%       coefficients. path is a row vector with one column for each element
%       of the path. The scalar 0 denotes the original data. Positive
%       integers in the L-th column denote the corresponding wavelet filter
%       in the (L-1)-th filter bank. Wavelet bandpass filters are ordered
%       by decreasing center frequency.
%
%       bandwidth: The bandwidth of the scattering coefficients. If you
%       specify a sampling frequency in the scattering network, the
%       bandwidth is in hertz. If you do not specify a sampling frequency,
%       the bandwidth is in cycles/sample.
%
%       resolution: The log2 resolution of the scattering coefficients.
%
%   [S,U] = scatteringTransform(SN,X) returns the scalogram coefficients in
%   an NO-by-1 cell array of MATLAB tables. The i-th element of U are the
%   scalogram coefficients for the i-th row of S. Each element of U is
%   Nu-by-Nchannel-by-Nbatch where Nu is the number of scalogram
%   coefficients for each path.
%
%   Each MATLAB table in U contains the following variables:
%
%       coefficients: A cell array of scalogram coefficients. Each element
%       of coefficients is an Nu-by-Nchannel-by-Nbatch array. Note that 
%       U{1} contains the original data in the coefficients variable.
%
%       path: The scattering path used to obtain the scalogram
%       coefficients. path is a row vector with one column for each element
%       of the path. The scalar 0 denotes the original signal. Positive
%       integers in the L-th column denote the corresponding wavelet filter
%       in the (L-1)-th filter bank. Wavelet bandpass filters are ordered
%       by decreasing center frequency.
%
%       bandwidth: The bandwidth of the scalogram coefficients. If you
%       specify a sampling frequency in the scattering decomposition
%       network, the bandwidth is in hertz. If you do not specify a
%       sampling frequency, the bandwidth is in cycles/sample.
%
%       resolution: The log2 resolution of the scalogram coefficients.
%
%
%   % Example: Obtain the scattering transform of an ECG signal sampled
%   %   at 180 Hz.
%
%   load wecg;
%   sn = waveletScattering('SignalLength',numel(wecg),...
%       'SamplingFrequency',180);
%   [S,U] = scatteringTransform(sn,wecg);

% Copyright 2018-2022 The MathWorks, Inc.

%#codegen

narginchk(2,3)
nargoutchk(0,3);
[Stmp,Utmp] = self.featureMatrix(x);
FSfac = self.SamplingFrequency/(2*pi);
Ntables = coder.const(length(Utmp));
phiftsup = ...
    self.filterparams{1}.phiftsupport*FSfac;
philog2res = min(-self.filterparams{1}.philog2ds+self.OversamplingFactor,0);
sizeScat = size(Stmp(1,:,:,:));
tmpSignals = cell(Ntables,1);
tmpPhiBW = cell(Ntables,1);
tmpPhiRes = cell(Ntables,1);

for ii = 1:Ntables
    tmpSignals{ii} = repmat({zeros(sizeScat,'like',Stmp)},self.npaths(ii),1);
    tmpPhiBW{ii} = repmat(phiftsup,self.npaths(ii),1);
    tmpPhiRes{ii} = repmat(philog2res,self.npaths(ii),1);
end

pathstart = 1;
cumpath = cumsum(self.npaths);
Ncol = size(Stmp,2);
Nchan = size(Stmp,3);
Nbatch = size(Stmp,4);

for ii = 1:Ntables
    idx = pathstart:cumpath(ii);
    Nsignal = numel(idx);
    tmpSignalMat = Stmp(idx,:,:,:);
    tmpCell = codermat2cell(tmpSignalMat,Nsignal,Ncol,Nchan,Nbatch);
    tmpSignals{ii} = tmpCell;
    pathstart = pathstart+self.npaths(ii);
end


% The following is heterogenous cell array
coder.varsize('coefficients');
coefficients = cell(3,1);
for ii = 1:Ntables
    coefficients{ii} = Utmp{ii};
end


S = cell(Ntables,1);
for ii = 1:Ntables
    S{ii} = table(tmpSignals{ii},self.currpaths{ii}.path,tmpPhiBW{ii},...
        tmpPhiRes{ii},'VariableNames',{'signals','path','bandwidth',...
        'resolution'});
end

U = cell(Ntables,1);
for ii = 1:Ntables
    if ii == 1
        tmpUbw = 1;
        Ubw = tmpUbw;
        
    else
        tmpPath = self.currpaths{ii}.path;
        N = size(tmpPath,2);
        [~,~,irepeat] = unique(tmpPath(:,N));
        tmpUbw = (self.filterparams{ii-1}.psiftsupport.*FSfac)';
        Ubw = tmpUbw(irepeat);
    end
    U{ii} = table(Utmp{ii},self.currpaths{ii}.path,Ubw,...
        self.currpaths{ii}.log2res,'VariableNames',...
        {'coefficients','path','bandwidth','resolution'});
end


function tmpCell = codermat2cell(mat,Nsignal,Ncol,Nchan,Nbatch)
tmpCell = cell(Nsignal,1);
for ii = 1:Nsignal
    tmpCell{ii} = reshape(mat(ii,:,:,:),[Ncol, Nchan, Nbatch, 1]);
end








