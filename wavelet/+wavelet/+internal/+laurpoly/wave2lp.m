function [Hs,Gs,Ha,Ga,PRCond,AACond] = wave2lp(wname,PmaxHS,AddPOW)
%WAVE2LP Laurent polynomials associated to a wavelet.
%   [Hs,Gs,Ha,Ga] = WAVE2LP(W) returns the four Laurent polynomials
%   associated to the wavelet which name is W (see LIFTWAVE).
%   The pairs (Hs,Gs) and (Ha,Ga) are the synthesis and the analysis
%   pair respectively.
%   The H-polynomials (G-polynomials) are "low pass" ("high pass")
%   polynomials.
%   For an orthogonal wavelet, Hs = Ha and Gs = Ga.
%
%   See also laurpoly.

%   In addition, [...,PRCond,AACond] = WAVE2LP(W) computes the
%   perfect reconstruction (PRCond) and the anti-aliasing (AACond)
%   conditions (see PRAACOND).
%
%   [...] = WAVE2LP(W,PmaxHS) lets specify the maximum power of
%   Hs. PmaxHS must be an integer. The default value is zero.
%
%   [...] = WAVE2LP(...,AddPOW) lets change the default maximum
%   power of Gs: PmaxGS = PmaxHS + length(Gs) - 2, adding the
%   integer AddPOW. The default value for AddPOW is zero.
%   AddPOW must be an even integer to preserve the perfect
%   condition reconstruction.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2021 The MathWorks, Inc.

switch nargin
    case 0
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case 1 , AddPOW = 0; PmaxHS = 0;
    case 2 , AddPOW = 0;
end
% Accept string input and convert to char
if isStringScalar(wname)
    wname = convertStringsToChars(wname);
elseif isstring(wname) && ~isStringScalar(wname)
    error(message('Wavelet:FunctionInput:StringScalar','W'));
end

tw = wavetype(wname);
if ~isequal(lower(tw),'unknown')
    wn = wname(1:2);
    switch wn
        case {'co','db','sy'} , mode = 'orthfilt';  % orthogonal wavelet.
        case {'bi','rb'}      , mode = 'biorfilt';  % biorthogonal wavelet.
        otherwise , mode = 'liftscheme';
    end
else
    mode = 'unknown';
end

switch mode
    case 'liftscheme'  % lazy wavelet and others ...
        LS = liftwave(wname);
        [Hs,Gs,Ha,Ga] = wavelet.internal.laurpoly.ls2lp(LS);
        
    case 'orthfilt'   % orthogonal wavelet.
        LoR = wfilters(wname,'r');
        [Ha,Ga,Hs,Gs] = wavelet.internal.laurpoly.filters2lp('orth',LoR,PmaxHS,AddPOW);
        
    case 'biorfilt'    % biorthogonal wavelet.
        first = wname(1);
        switch first
            case 'b' , [Rf,Df] = biorwavf(wname);
            case 'r' , [Rf,Df] = rbiowavf(wname);
        end
        %------------------------------------------------------
        % === Comment if Modification of biorwavf (July 2003) ===
        if isequal(wname,'bior6.8') || isequal(wname,'rbio6.8')
            Df = -Df;
        end
        %------------------------------------------------------
        % Special case for bior3.X and rbio3.X.
        if nargin<3 && wname(5)=='3' , AddPOW = 1; end
        %------------------------------------------------------
        LoR = sqrt(2)*Rf;
        LoD = sqrt(2)*Df;
        [Ha,Ga,Hs,Gs] = wavelet.internal.laurpoly.filters2lp('bior',LoR,LoD,PmaxHS,AddPOW);
        
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_WavNamVar', wname))
end
if nargout>4
    [PRCond,AACond] = wavelet.internal.laurpoly.praacond(Hs,Gs,Ha,Ga);
end
