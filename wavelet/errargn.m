function [err,msg] = errargn(ndfct,nbArgin,setOfargin,nbArgout,setOfargout)
%ERRARGN Check function arguments number.
%   ERR = ERRARGN('function',NBARGIN,SETofARGIN,NBARGOUT,SETofARGOUT) or 
%   [ERR,MSG] = ERRARGN('function',NBARGIN,SETofARGIN,NBARGOUT,SETofARGOUT) 
%   returns ERR = 1 if either the number of input NBARGIN or 
%   output (NBARGOUT) arguments of the specified function do not
%   belong to the vector of allowed values (SETofARGIN and
%   SETofARGOUT, respectively). In this case MSG contains an
%   appropriate error message.
%   Otherwise ERRARGN returns ERR = 0 and MSG = [].
%
%   See also ERRARGT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Special case:
% -------------
%  If SETofARGIN is not a numeric array, the number of input arguments
%  is not controlled. The same holds for SETofARGOUT.
%  example:
%    err = errargn('function',3,'var',2,[1:4]);
%    returns err = 0.
%    [err,msg] = errargn('function',2,[1:4],3,'var');
%    returns err = 0 and msg = [].

err = false; msg = [];
if isnumeric(setOfargin)
    if nbArgin < min(setOfargin)
        msg = getWavMSG('MATLAB:narginchk:notEnoughInputs');
        err = true;
    elseif nbArgin > max(setOfargin)
        msg = getWavMSG('MATLAB:narginchk:tooManyInputs');
        err = true;
    else
        err = isempty(find(nbArgin==setOfargin,1));
        if err , msg = getWavMSG('Wavelet:FunctionInput:Invalid_ArgNum'); end
    end
end
if ~err && isnumeric(setOfargout)
    if nbArgout < min(setOfargout)
        msg = getWavMSG('MATLAB:nargoutchk:notEnoughOutputs');
        err = true;
    elseif nbArgout > max(setOfargout)
        msg = getWavMSG('MATLAB:nargoutchk:tooManyOutputs');
        err = true;
    else    
        err = isempty(find(nbArgout==setOfargout,1));
        if err , msg = getWavMSG('Wavelet:FunctionOutput:Invalid_ArgNum'); end
    end    
end
if err && (nargout<2) , errargt(ndfct,msg,'msg'); end
