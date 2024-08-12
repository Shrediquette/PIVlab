function [LoD,HiD,LoR,HiR] = qbiorthfilt(name)
% First-level dual-tree biorthogonal filters
%   [LoD,HiD,LoR,HiR] = QBIORTHFILT(NAME) returns the first-level
%   biorthogonal filters for Kingsbury's Q-shift complex dual-tree
%   transform. NAME is a scalar string or char array. Valid options for
%   NAME are 'nearsym5_7', 'nearsym13_19', 'antonini', and 'legall'.
%
%   %Example: Obtain the LeGall (5,3) biorthogonal filters. Plot the 
%   % frequency response of the synthesis filters to level 3 using 
%   % DWTFILTERBANK. Because the biorthogonal filters are not even 
%   % length, extend appropriately to match powers of z.
%   [LoD,HiD,LoR,HiR] = qbiorthfilt('legall');
%   wavf(:,1) = [0 0 HiD' 0];
%   wavf(:,2) = [0 HiR'];
%   scal(:,1) = [0 LoD'];
%   scal(:,2) = [0 0 LoR' 0];
%   fbDWT = dwtfilterbank('Wavelet','Custom','CustomScalingFilter',...
%       scal,'CustomWaveletFilter',wavf,'Level',3,'FilterType',...
%       'synthesis');
%   freqz(fbDWT)
%
%   See also qorthwavf, dualtree, dualtree2, dualtree3

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253. 


% Copyright 2019-2020 The MathWorks, Inc.
%#codegen

narginchk(1,1);
nargoutchk(0,4);

validBiorth = {'nearsym5_7','nearsym13_19','antonini','legall'};
name = validatestring(name,validBiorth,'qbiorthfilt','name');
coder.varsize('LoD','HiD','LoR','HiR');


switch name
    
    case 'nearsym5_7'
        
        LoD = [
            -0.050000000000000
            0.250000000000000
            0.600000000000000
            0.250000000000000
            -0.050000000000000];
        
        
        HiD = [
            0.010714285714286
            -0.053571428571429
            -0.260714285714286
            0.607142857142857
            -0.260714285714286
            -0.053571428571429
            0.010714285714286];
        
    case 'nearsym13_19'
        
        LoD = [
            -0.001757812500000
            0
            0.022265625000000
            -0.046875000000000
            -0.048242187500000
            0.296875000000000
            0.555468750000000
            0.296875000000000
            -0.048242187500000
            -0.046875000000000
            0.022265625000000
            0
            -0.001757812500000];
        
        HiD = [
            -0.000070626395089
            0
            0.001341901506696
            -0.001883370535714
            -0.007156808035714
            0.023856026785714
            0.055643136160714
            -0.051688058035714
            -0.299757603236607
            0.559430803571429
            -0.299757603236607
            -0.051688058035714
            0.055643136160714
            0.023856026785714
            -0.007156808035714
            -0.001883370535714
            0.001341901506696
            0
            -0.000070626395089];
        
        
    case 'antonini'
        LoD = [
            0.026748757410810
            -0.016864118442875
            -0.078223266528991
            0.266864118442873
            0.602949018236359
            0.266864118442877
            -0.078223266528988
            -0.016864118442875
            0.026748757410810];
        
        HiD = [
            0.045635881557125
            -0.028771763114249
            -0.295635881557128
            0.557543526228502
            -0.295635881557123
            -0.028771763114253
            0.045635881557126];        
        
        
        
    case 'legall'
        
        LoD = [
            -0.125000000000000
            0.250000000000000
            0.750000000000000
            0.250000000000000
            -0.125000000000000];
        
        HiD = [
            -0.250000000000000
            0.500000000000000
            -0.250000000000000];     
  otherwise
        % To define LoD and HiD on all execution paths for codegen
        LoD = [];
        HiD = [];
        
        
        
end

Llow = numel(LoD);
n = (0:Llow-1)';
HiR = (-1).^n.*LoD;
Lhigh = numel(HiD);
m = (1:Lhigh)';
LoR = (-1).^m.*HiD;


