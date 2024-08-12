function [O,err] = wsfields(varargin)
%WSFIELDS Set object or structure field contents.
%
%   O = WSFIELDS(O,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...)
%   sets the contents of the specified fields for any object or
%   structure O.
%
%   First, the search is done in O. If it fails, the
%   subobjects and substructures fields are examined.
%
%   VARARGOUT = WSFIELDS(DEPTH,VARARGIN) with the integer DEPTH=>0,
%   restricts the search at the depth DEPTH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

nbin  = nargin;
if isobject(varargin{1})
    depth = Inf;
    i_obj = 1;
    i_arg = 2;

elseif isstruct(varargin{1})
    depth = Inf;
    i_obj = 1;
    i_arg = 2;

else
    if ischar(varargin{1})
        depth = Inf;
    else
        depth = varargin{1};		
    end
    i_obj = 2;
    i_arg = 3;
end
[O,okArg] = RecursSetFields(depth,varargin{i_obj},varargin{i_arg:nbin});
err = (okArg==0);
err = err(:)';
idxERR = find(err);
if ~isempty(idxERR)
    idxERR = 2*idxERR-1+i_arg-1;
    msg = {getWavMSG('Wavelet:moreMSGRF:Unknown_FIELD'),varargin{idxERR}};
    wwarndlg(msg,getWavMSG('Wavelet:moreMSGRF:ERR_Field_Names'),'modal');
end


%----------------------------------------------------------------------------%
% Internal Function(s)
%----------------------------------------------------------------------------%
function [O,okArg] = RecursSetFields(depth,obj,varargin)

nbin   = nargin-2;
nbinD2 = nbin/2;
O = obj;
if isobject(obj) , obj = struct(obj); end

okArg = zeros(nbinD2,1);
stFields = fieldnames(obj);
nbFields = size(stFields,1);
for k=1:2:nbin
    vk = lower(varargin{k});
    for j=1:nbFields
       if isequal(vk,lower(stFields{j}))
           [O,err] = OneFieldSetting(O,stFields{j},varargin{k+1});
           if ~err , okArg((k+1)/2) = j; end
           break
       end
    end
end
remArg = find(okArg==0);
nbRem  = length(remArg);
if nbRem>0
    for j=1:nbFields
       subSt = obj.(stFields{j});
       continu = isobject(subSt) | (isstruct(subSt) & depth>0);
       if continu
           remArgTMP = [2*remArg-1,2*remArg];
           remArgTMP = sort(remArgTMP(:));
           tmpargs = varargin(remArgTMP);
           [subSt,tmpOk] = RecursSetFields(depth-1,subSt,tmpargs{:});
           sumOK = sum(tmpOk);
           if sumOK>0
               [O,err] = OneFieldSetting(O,stFields{j},subSt);
               if ~err
                   okArg(remArg) = tmpOk;
                   remArg = find(okArg==0);
                   nbRem = length(remArg);
                   if nbRem==0 , break; end
               end
           end
       end
    end
end
%----------------------------------------------------------------------------%
function [O,err] = OneFieldSetting(O,fieldName,fieldValue)

err = 0;
if isobject(O)
    try
        O = set(O,fieldName,fieldValue);
    catch ME  %#ok<NASGU>
        err = 1;
    end
elseif isstruct(O)
   O.(fieldName) = fieldValue;
else
    error(message('Wavelet:FunctionArgVal:Invalid_FieldSet'));
end
%----------------------------------------------------------------------------%
