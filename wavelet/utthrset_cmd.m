function varargout = utthrset_cmd(coefs,longs,nb_IntVal)
%UTTHRSET_CMD Define interval dependent thresholds.
%   For a given wavelet decomposition (C,L) (see WAVEDEC),
%   UTTHRSET_CMD computes the intervals and the thresholds
%   used for an interval dependent denoising.
%
%	[THRPAR,INT_DepThr] = UTTHRSET_CMD(C,L) returns
%   THRPAR is a cell array which length is the level of the
%   wavelet decomposition. For the level k, THRPAR{k} is an L-by-3 
%   array such that THRPAR{k}(i,1) and THRPAR{k}i,2) are the end 
%   points of the ith interval and THRPAR{k}(i,3) is the corresponding
%   threshold.
%   The variable int_DepThr contains the interval locations
%   and the threshold values for a number of intervals from 1 to 6.
%   THRPAR corresponds to the best choice of the number of intervals. 
%
%   [THRPAR,INT_DepThr] = UTTHRSET_CMD(C,L,NBint) let you choose
%   the number of intervals.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-2008.
%   Last Revision: 13-Oct-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

details = wrepcoef(coefs,longs);
maxTHR = max((abs(details)),[],2)';

level = size(details,1);
nb_Max_Int = 6;
if nargin<3 , nb_IntVal = NaN; end

% Computing Intervals.
%=====================

% Extract the detail of order 1.
%-------------------------------
det = details(1,:);
xdata = 1:length(det);

% Replacing 2% of biggest values of by the mean.
%-----------------------------------------------
x = sort(abs(det));
v2p100 = x(fix(length(x)*0.98));
det(abs(det)>v2p100) = mean(det);
lenDet = length(det);

% Finding breaking points.
%-------------------------
d = 10;
if lenDet>1024
    ratio = ceil(lenDet/1024);
    [~,nb_Opt_Rupt,Xidx] = wvarchg(det(1:ratio:end),nb_Max_Int,d);
    Xidx = min(ratio*Xidx,lenDet);
else
    [~,nb_Opt_Rupt,Xidx] = wvarchg(det,nb_Max_Int,d);
end
nb_Opt_Int = nb_Opt_Rupt+1;
if isnan(nb_IntVal) , nb_IntVal = nb_Opt_Int; end

% Computing denoising structure.
%-------------------------------
% Ensure that there are no zeros on the lower diagonal entries.

[row,col] = find(~Xidx);
idx = find(~Xidx);
lowertriang = row>=col;
Xidx(idx(lowertriang>0)) = 1;

Xidx = [zeros(size(Xidx,1),1) Xidx];
norma = sqrt(2)*thselect(det,'minimaxi');
% sqrt(2) comes from the fact that if x is a white noise
% of variance 1 the reconstructed detail_1 of x is of
% variance 1/sqrt(2)
int_DepThr = cell(1,nb_Max_Int);
for nbint = 1:nb_Max_Int
    for j = 1:nbint
        sig = median(abs(det(Xidx(nbint,j)+1:Xidx(nbint,j+1))))/0.6745;
        thr = norma*sig;
        int_DepThr{nbint}(j,:) = ...
            [Xidx(nbint,j) , Xidx(nbint,j+1), thr];
    end
    int_DepThr{nbint}(1,1) = 1;
    int_DepThr{nbint}(:,[1 2]) = xdata(int_DepThr{nbint}(:,[1 2]));
end
int_DepThr_Cell = {int_DepThr,nb_Opt_Int};
thrParams = cell(1,level);
intervals = int_DepThr{nb_IntVal};
for k=1:level
    thrPAR = intervals;
    TMP = min(thrPAR(:,3),maxTHR(k));
    thrPAR(:,3) = TMP;
    thrParams{k} = thrPAR;
end

varargout = {thrParams,int_DepThr_Cell};
