function varargout = cmddenoise(sig,wname,level,sorh,nb_IntVal,thrParams)
%CMDDENOISE Interval dependent denoising 
%   SIGDEN = CMDDENOISE(SIG,WNAME,LEVEL) performs an interval  
%   dependent denoising of the signal SIG, using a wavelet 
%   decomposition at the level LEVEL with a wavelet which 
%   name is WNAME. SIGDEN is the denoised signal.
%
%   General Syntax:
%       [SIGDEN,COEFS,thrParams,int_DepThr_Cell,BestNbOfInt] =
%           CMDDENOISE(SIG,WNAME,LEVEL)
%       [...] = CMDDENOISE(SIG,WNAME,LEVEL,SORH)
%       [...] = CMDDENOISE(SIG,WNAME,LEVEL,SORH,NB_INTER)
%       [...] = CMDDENOISE(SIG,WNAME,LEVEL,SORH,NB_INTER,thrParams)
% 
%       - SORH ('s' or 'h') stands for soft or hard thresholding
%         (see WTHRESH for more details). Default is SORH = 's'.
%       - NB_INTER is an integer giving the number of intervals
%         used for denoising. NB_INTER must be such that 0<=NB_INTER
%         and NB_INTER<=6. The default is computed automatically.
% 
%       - COEFS is a vector containing the wavelet decomposition
%         of SIGDEN.
%       - thrParams is a cell array of length LEVEL such that
%         thrParams{j} is a NB_INTER by 3 array. In this array, each  
%         row contains the lower and upper bounds of the thresholding 
%         interval and the threshold value.
%       - BestNbOfInt is the best number of intervals (computed  
%         automatically).
%       - thrParams{j} is equal to int_DepThr_Cell{NB_INTER} or to
%         int_DepThr_Cell{BestNbOfInt} depending on the inputs of
%         CMDDENOISE.
%
% Example 1:
%     load nbumpr3.mat; sig = nbumpr3;
%     [sden,cfs] = cmddenoise(sig,'sym4',5,'s');
%     subplot(2,1,1); plot(sig,'r'); axis tight
%     hold on; plot(sden,'k');
%     subplot(2,1,2); plot(sden,'k'); axis tight
%
% Example 2:
%     [sden,cfs] = cmddenoise('nbumpr2','sym4',5,'s');
%     load nbumpr2; plot(nbumpr2,'r'); axis tight
%     hold on; plot(sden,'k','LineWidth',2);
%
% Example 3: fixing number of intervals
%     load nblocr1; sig = nblocr1;
%     [sden,cfs] = cmddenoise('nblocr1','db5',5,'s',3);
%     subplot(2,1,1); plot(sig,'r'); axis tight
%     hold on; plot(sden,'k');
%     subplot(2,1,2); plot(sden,'k'); axis tight
%
% Example 4: fixing thresholds
%     % Fine tuning thresholds using the GUI and saving
%     % the thrParams variable which contains the desired
%     % intervals and thresholds:
%     % File --> Save --> De-Noised Signal
%     % Choose for example "Sav_Den_Sig" as file name.
%     % This Mat-File will contain several variables
%     % and particularly: thrParams.
%     load nblocr1; sig = nblocr1;
%     load Sav_Den_Sig
%     [sden,cfs] = cmddenoise('nblocr1','db5',5,'s',3,thrParams);
%     subplot(2,1,1); plot(sig,'r'); axis tight
%     hold on; plot(sden,'k');
%     subplot(2,1,2); plot(sden,'k'); axis tight
%
% See also wdencmp, wden, wthrmngr.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-May-2008.
%   Last Revision: 19-Apr-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 0
    sig = convertStringsToChars(sig);
end

if nargin > 1
    wname = convertStringsToChars(wname);
end

if nargin > 3
    sorh = convertStringsToChars(sorh);
end

if nargin<4 , sorh = 's'; end
if nargin<5 , nb_IntVal = NaN; end
if nargin<6 , thrParams = NaN; end

% Load the signal.
%-----------------
if ischar(sig)
    S = load(sig);
    fn = fieldnames(S);
    sig = S.(fn{1});
end
% Wavelet Analysis.
%------------------
[coefs,longs] = wavedec(sig,level,wname);
siz = size(coefs);
if isequal(siz(2),1), coefs = coefs';end
if ~iscell(thrParams)
    if isnan(thrParams)
        [thrParams,int_DepThr_Cell] = utthrset_cmd(coefs,longs,nb_IntVal);
    else
        TMP = thrParams;
        if isequal(length(TMP),1)
            TMP = TMP(ones(1,level));
        end
        thrParams = cell(1,level);
        for k = 1:level
            thrParams{k} = [1 longs(end) TMP(k)];
        end
    end
end
first = cumsum(longs)+1;
first = first(end-2:-1:1);
tmp = longs(end-1:-1:2);
last = first+tmp-1;
longs_INV = longs(end-1:-1:2);
for k = 1:level
    thr_par = thrParams{k};
    if ~isempty(thr_par)
        cfs = coefs(first(k):last(k));
        nbCFS = longs_INV(k);
        NB_int = size(thr_par,1);
        x = [thr_par(:,1) ; thr_par(NB_int,2)];
        alf = (nbCFS-1)/(x(end)-x(1));
        bet = 1 - alf*x(1);
        x = round(alf*x+bet);
        x(x<1) = 1;
        x(x>nbCFS) = nbCFS;
        thr = thr_par(:,3);
        for j = 1:NB_int
            if j==1 , d_beg = 0; else d_beg = 1; end
            j_beg = x(j)+d_beg;
            j_end = x(j+1);
            j_ind = (j_beg:j_end);
            cfs(j_ind) = wthresh(cfs(j_ind),sorh,thr(j));
        end
        coefs(first(k):last(k)) = cfs;
    end
end
sigden = waverec(coefs,longs,wname);
if exist('int_DepThr_Cell','var')
    varargout = {sigden,coefs,thrParams,int_DepThr_Cell{1},int_DepThr_Cell{2}};
else
    varargout = {sigden,coefs,thrParams};
end

