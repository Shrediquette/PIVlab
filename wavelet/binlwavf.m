function [Rf,Df] = binlwavf(wname)
%BINLWAVF Biorthogonal wavelet filters (binary wavelets: Binlets).
%   [RF,DF] = BINLWAVF(W) returns two scaling filters
%   associated with the biorthogonal wavelet specified
%   by the character vector W.
%   W = 'binlNr.Nd' where possible values for Nr and Nd are:
%           Nr = 7  Nd = 9
%   The output arguments are filters:
%           RF is the reconstruction filter
%           DF is the decomposition filter

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% suppress the following line for extension
Nr = 7; Nd = 9;

% for possible extension
% more wavelets in 'Binlets' family
%----------------------------------
if nargin==0
    Nr = 7; Nd = 9;
elseif  isempty(wname)
    Nr = 7; Nd = 9;
else
    if ischar(wname)
        lw = length(wname);
        ab = abs(wname);
        ind = find(ab==46 | 47<ab | ab<58);
        li = length(ind);
        err = 0;
        if li==0
            err = 1;
        elseif ind(1)~=ind(li)-li+1
            err = 1;
        end 
        if err==0  
            wname = str2num(wname(ind));
            if isempty(wname) , err = 1; end
        end
    end     
    if err==0
        Nr = fix(wname); Nd = 10*(wname-Nr);
    else
        Nr = 0; Nd = 0;
    end
end

% suppress the following lines for extension
% and add a test for errors.
%-------------------------------------------
if Nr~=7 , Nr = 7; end
if Nd~=9 , Nd = 9; end

if Nr == 7
   if Nd == 9
      Rf = [-1 0 9 16 9 0 -1]/32;
      Df = [ 1 0 -8 16 46 16 -8 0 1]/64;
   end
end
