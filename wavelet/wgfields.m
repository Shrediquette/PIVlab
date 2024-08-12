function varargout = wgfields(varargin)
%WGFIELDS Get object or structure field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       WGFIELDS(O,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for any object or
%   structure O.
%
%   First, the search is done in O. If it fails, the
%   subobjects and substructures fields are examined.
%
%   VARARGOUT = WGFIELDS(DEPTH,VARARGIN) with the integer DEPTH=>0,
%   restricts the search at the depth DEPTH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.
%   Last Revision 11-April-2014.
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
[tmpOut,okArg] = RecursGetFields(depth,varargin{i_obj},varargin{i_arg:nbin});
varargout = tmpOut;
err = (okArg==0);
err = err(:)';
idxERR = find(err);
if ~isempty(idxERR)
    idxERR = idxERR+i_arg-1;
    msg = {getWavMSG('Wavelet:moreMSGRF:Unknown_FIELD'),varargin{idxERR}};
    wwarndlg(msg,getWavMSG('Wavelet:moreMSGRF:ERR_Field_Names'),'modal');
end

%----------------------------------------------------------------------------%
% Internal Function(s)
%----------------------------------------------------------------------------%
function [tmpOut,okArg] = RecursGetFields(depth,obj,varargin)

nbin = nargin-2;
if isobject(obj)
  obj = struct(obj); end
if nbin>0
    tmpOut = cell(nbin,1);
    okArg  = zeros(nbin,1);
    stFields = fieldnames(obj);
    nbFields = size(stFields,1);
    for k=1:nbin
        vk = lower(varargin{k});
        for j=1:nbFields
            if isequal(vk,lower(stFields{j}))
                okArg(k) = j;
                break
            end
        end
    end
    tmp    = struct2cell(obj);
    indOut = find(okArg);
    tmpOut(indOut) = tmp(okArg(indOut));

    remArg = find(okArg==0);
    nbRem  = length(remArg);
    if nbRem>0
       for j=1:nbFields
           subSt = obj.(stFields{j});
           continu = (isobject(subSt) && ~isempty(subSt)) | (isstruct(subSt) & depth>0);
           if continu
               tmpargs = varargin(remArg);
               [tmpRem,tmpOk] = RecursGetFields(depth-1,subSt,tmpargs{:});
               tmpOut(remArg) = tmpRem;
               okArg(remArg)  = tmpOk;
               remArg = find(okArg==0);
               nbRem = length(remArg);
               if nbRem==0 , break; end
           end
       end
    end
else
    tmpOut = struct2cell(obj);
    nbin   = length(tmpOut);
    okArg  = 1:nbin;
end
