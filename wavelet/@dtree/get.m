function varargout = get(t,varargin)
%GET Get DTREE object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the DTREE
%   object T.
%
%   [...] = GET(T) returns all the field contents of T.
%
%   The valid choices for 'FieldName' are:
%     'ntree' : ntree parent object
%     'allNI' : All nodes Infos
%     'terNI' : Terminal nodes Infos
%     -------------------------------------------------------------------
%      For FieldName = 'allNI', FieldValue allNI is a NBnodes by 3 array 
%      such that:
%      allNI(N,:) = [ind,size(1,1),size(1,2)]
%          ind  = index of the node N
%          size = size of data associated with the node N
%     -------------------------------------------------------------------
%      For FieldName = 'terNI', FieldValue terNI is a 1 by 2 cell 
%      array such that:
%      terNI{1} is an NB_TerminalNodes by 2 array such that:
%         terNI{1}(N,:) is the size of coefficients associated with
%         the N-th terminal node. The nodes are numbered from left
%         to right and from top to bottom. The root index is 0.
%      terNI{2} is a row vector containing the previous 
%      coefficients stored row-wise in the above specified order.  
%     -------------------------------------------------------------------
%
%   Or fields in NTREE parent object:
%     'wtbo'  : wtbo parent object
%     'order' : Order of tree
%     'depth' : Depth of tree
%     'spsch' : Split scheme for nodes
%     'tn'    : Array of terminal nodes of tree
%
%   Or fields in WTBO parent object:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Examples:
%     t = dtree(3,2);
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%     [o,allNI,tn] = get(t,'order','allNI','tn');
%
%   See also DISP, READ, SET, WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 15-Mar-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
if nbin==0 , varargout = struct2cell(struct(t))'; return; end
varargout = cell(nbin,1);
for k=1:nbin
    field = varargin{k};
    try
        varargout{k} = t.(field);
    catch ME %#ok<NASGU>
        varargout{k} = get(t.ntree,field);
    end
end
