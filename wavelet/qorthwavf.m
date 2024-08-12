function [LoDa,LoDb,HiDa,HiDb,LoRa,LoRb,HiRa,HiRb] = qorthwavf(num)
% Kingsbury Q-shift filters
%   [LoDa,LoDb,HiDa,HiDb,LoRa,LoRb,HiRa,HiRb] = QORTHWAVF(NUM) returns the
%   Kingsbury Q-shift filters for the Q-shift complex dual-tree transform.
%   NUM refers to the number of nonzero coefficients (taps) in the filter.
%   Valid options for NUM are 6, 10, 14, 16, and 18. All filters are even
%   length and the tree B filters are the time reverse of the tree A
%   filters.
%   
%   % Example: Obtain the Q-shift filters for the case when there are
%   %   10 nonzero coefficients. Plot the frequency responses of the tree A
%   %   scaling and wavelet filters.
%   [LoDa,LoDb,HiDa,HiDB,LoRa,LoRb,HiRa,HiRb] = qorthwavf(10);
%   fbDWT = dwtfilterbank('Wavelet','Custom','CustomScalingFilter',LoDa,...
%       'CustomWaveletFilter',HiDa);
%   freqz(fbDWT)
%
%   See also dualtree, dualtree2, qbiorthfilt

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253.

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen
narginchk(1,1);
nargoutchk(0,8);
validateattributes(num,{'numeric'},{'positive','scalar','integer'});
coder.varsize('LoDa','LoDb','HiDa','HiDb','LoRa','LoRb','HiRa','HiRb');
LoDa = [];

switch num
    case 6
        
        LoDa = [
            0.035163836571495
            0
            -0.088329424451073
            0.233890320607236
            0.760272369066126
            0.587518297723560
            0
            -0.114301837144249
            0
            0 ];
        
    case 10
        
        LoDa = [
            0.051130405283832
            -0.013975370246889
            -0.109836051665971
            0.263839561058938
            0.766628467793037
            0.563655710127052
            0.000873622695217
            -0.100231219507476
            -0.001689681272528
            -0.006181881892116];
        
    case 14
        
        LoDa = [
            0.003253142763653
            -0.003883211999158
            0.034660346844853
            -0.038872801268828
            -0.117203887699115
            0.275295384668882
            0.756145643892522
            0.568810420712123
            0.011866092033797
            -0.106711804686665
            0.023825384794920
            0.017025223881554
            -0.005439475937274
            -0.004556895628475];
        
    case 16
        
        LoDa = [
            -0.004761611938456
            -0.000446022789262
            -0.000071441973280
            0.034914612306842
            -0.037273895799898
            -0.115911457427441
            0.276368643133032
            0.756393765199037
            0.567134484100133
            0.014637405964473
            -0.112558884257522
            0.022289263266923
            0.018498682724156
            -0.007202677878258
            -0.000227652205898
            0.002430349945149];
        
    case 18
        
        LoDa = [
            -0.002284127440271
            0.001209894163073
            -0.011834794515431
            0.001283456999344
            0.044365221606617
            -0.053276108803047
            -0.113305886362143
            0.280902863222186
            0.752816038087856
            0.565808067396459
            0.024550152433667
            -0.120188544710795
            0.018156493945546
            0.031526377122085
            -0.006628794612430
            -0.002576174306601
            0.001277558653807
            0.002411869456666];
        
    otherwise
        coder.internal.error('Wavelet:dualtree:UnsupportedQ');
        
        
end

LoDb = flip(LoDa);

% For the special case of 6, there are 10 coefficients, but only 6 taps
% are nonzero
if (num == 6)
    na = (0:9)';
    nb = (1:10)';
else
    na = (0:num-1)';
    nb = (1:num)';
end

HiDa = (-1).^na.*flip(LoDa);
HiDb = (-1).^nb.*flip(LoDb);

LoRa = LoDb;
LoRb = LoDa;
HiRa = HiDb;
HiRb = HiDa;
