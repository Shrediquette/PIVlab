function [LoDz,HiDz,LoRz,HiRz,PRCond,AACond] = wave2lp(wname,PmaxHS,AddPOW)
%WAVE2LP Laurent polynomials associated to a wavelet.
%   [LoDz,HiDz,LoRz,HiRz] = WAVE2LP(W) returns the four Laurent polynomials
%   associated with the wavelet specified by the string W. W must be one of
%   the wavelet names supported by LIFTINGSCHEME. The pairs (LoRz,HiRz) and
%   (LoDz,HiDz) are associated with the synthesis and analysis filters,
%   respectively. For an orthogonal wavelet, 
%       LoRz = reflect(LoDz) and 
%       HiRz = reflect(HiDz).
%
%   [...,PRCond,AACond] = WAVE2LP(W) returns the perfect reconstruction
%   (PRCond) and the anti-aliasing (AACond) conditions. PRCond and AACond
%   are Laurent polynomials. The conditions are as follows:
%      PRCond(z) = LoRz(z) * LoDz(z)  + HiRz(z) * HiDz(z)
%      AACond(z) = LoRz(z) * LoDz(-z) + HiRz(z) * HiDz(-z)
%
%   The pairs (LoRz,HiRz) and (LoDz,HiDz) are associated with perfect
%   reconstruction filters if and only if:
%      PRCond(z) = 2 and AACond(z) = 0.
%
%   If PRCond(z) = 2 * z^d, a delay is introduced in the reconstruction
%   process.
%
%   [...] = WAVE2LP(W,PmaxLoRz) specifies the maximum order of the Laurent
%   polynomial LoRz. PmaxLoRz must be an integer (default is 0).
%
%   [...] = WAVE2LP(...,AddPOW) sets the maximum order of the Laurent
%   polynomial HiRz such that 
%       PmaxHiRz = PmaxLoRz + length(HiRz.Coefficients) - 2 + AddPOW,
%   where 
%       PmaxHiRz is the maximum order of the Laurent polynomial HiRz,
%       PmaxLoRz is the maximum order of the Laurent polynomial LoRz,
%       AddPOW is an integer (default is 0). 
%   Note that AddPOW must be an even integer to preserve the perfect
%   reconstruction condition.
%
%   %Example: Obtain the perfect reconstruction (PRCond) and the
%   %   anti-aliasing (AACond) conditions for the Haar wavelet. Confirm 
%   %   PRCond and AACond have the expected values.
%   [LoDz,HiDz,LoRz,HiRz,PRCond,AACond] = wave2lp('db1');
%   (PRCond == laurentPolynomial('Coefficients',2))
%   (AACond == laurentPolynomial('Coefficients',0))
%
%   See also laurentPolynomial, laurentMatrix, filters2lp.

%   Copyright 1995-2021 The MathWorks, Inc.

%#codegen

switch nargin
    case 0
        coder.internal.error('Wavelet:FunctionInput:NotEnough_ArgNum');
    case 1 , AddPOW = 0; PmaxHS = 0;
    case 2 , AddPOW = 0;
end

% Accept string input and convert to char
if isStringScalar(wname)
    wname = convertStringsToChars(wname);
elseif isstring(wname) && ~isStringScalar(wname)
    coder.internal.error('Wavelet:FunctionInput:StringScalar','W');
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
        [LoRz,HiRz,LoDz,HiDz] = ls2lp(LS);
        if nargout>4
            [PRCond,AACond] = wavelet.internal.lifting.praacond(LoRz,HiRz,LoDz,HiDz);
        end
        
    case 'orthfilt'   % orthogonal wavelet.
        LoR = wfilters(wname,'r');
        if nargout>4
            [LoDz,HiDz,LoRz,HiRz,PRCond,AACond] = filters2lp({LoR},PmaxHS,AddPOW);
        else
            [LoDz,HiDz,LoRz,HiRz] = filters2lp({LoR},PmaxHS,AddPOW);
        end
        
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
        if nargin<3 && wname(5)=='3' 
            AddPOW = 1; 
        end
        %------------------------------------------------------
        LoR = sqrt(2)*Rf;
        LoD = sqrt(2)*Df;
        
        if nargout>4
            [LoDz,HiDz,LoRz,HiRz,PRCond,AACond] = filters2lp({LoR,LoD},PmaxHS,AddPOW);
        else
            [LoDz,HiDz,LoRz,HiRz] = filters2lp({LoR,LoD},PmaxHS,AddPOW);
        end
        LoDz = reflect(LoDz);
        HiDz = reflect(HiDz);
        
    otherwise
        coder.internal.error('Wavelet:FunctionArgVal:Invalid_WavNamVar', wname);
end

