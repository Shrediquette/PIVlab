function varargout = get(t,varargin)
%GET Get WPTREE object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the WPTREE
%   object T.
%   For the fields that are objects or structures, you
%   may get subfield contents (see example below).
%
%   [...] = GET(T) returns all the field contents of T.
%
%   The valid choices for 'FieldName' are:
%     'dtree'   : dtree parent object
%     'wavInfo' : Structure (wavelet infos)
%        'wavName' - Wavelet Name
%        'Lo_D'    - Low Decomposition filter
%        'Hi_D'    - High Decomposition filter
%        'Lo_R'    - Low Reconstruction filter
%        'Hi_R'    - High Reconstruction filter
%
%     'entInfo' : Structure (entropy infos)
%        'entName' - Entropy Name
%        'entPar'  - Entropy Parameter
%
%   Or fields in DTREE parent object:
%     'ntree' : ntree parent object
%     'allNI' : All nodes Infos
%     'terNI' : Terminal nodes Infos
%     -------------------------------------------------------------------
%      For FieldName = 'allNI', FieldValue allNI is a NBnodes by 5 array 
%      such that:
%      allNI(N,:) = [ind,size(1,1),size(1,2),ent,ento]
%          ind  = index of the node N
%          size = size of data associated with the node N
%          ent  = Entropy of the node N
%          ento = Optimal Entropy the node N
%     -------------------------------------------------------------------
%      For FieldName = 'terNI', FieldValue terNI is a 1 by 2 cell
%      array such that:
%      terNI{1} is an NB_TerminalNodes by 2 array such that:
%         terNI{1}(N,:) is the size of coefficients associated with
%         the Nth terminal node. The nodes are numbered from left 
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
%     x = rand(1,1000);
%     t = wpdec(x,2,'db2');
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%     [o,allNI,tn] = get(t,'order','allNI','tn');
%     [o,wavInfo,allNI,tn] = get(t,'order','wavInfo','allNI','tn');
%     [o,tn,Lo_D,EntName] = get(t,'order','tn','Lo_D','EntName');
%     [wo,nt,dt] = get(t,'wtbo','ntree','dtree');
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
okArg = ones(1,nbin);
for k=1:nbin
    field = varargin{k};
    try
      varargout{k} = t.(field);
    catch ME %#ok<NASGU>
      varargout{k} = get(t.dtree,field);
      if isequal(varargout{k},'errorWTBX') , okArg(k) = 0; end
    end    
end
notOk = find(okArg==0);
if ~isempty(notOk)
    [varargout{notOk}] = getwtbo(t,varargin{notOk});
end
