function [t,nbtn] = dtree(varargin)
%DTREE Constructor for the class DTREE.
%   T = DTREE(ORD,D,X) returns a complete data tree
%   object of order ORD and depth D. The data associated 
%   with the tree T is X.
%
%   With T = DTREE(ORD,D,X,USERDATA) you may set a 
%   userdata field.
%
%   [T,NB] = DTREE(...) returns also the number of
%   terminal nodes (leaves) of T.
%
%   T = DTREE('PropName1',PropValue1,'PropName2',PropValue2,...)
%   is the most general syntax to construct a DTREE object.
%   The valid choices for 'PropName' are:
%     'order' : Order of tree.
%     'depth' : Depth of tree.
%     'data'  : Data associated to the tree.
%     'spsch' : Split scheme for nodes.
%     'ud'    : Userdata field.
%
%   The Split scheme field is an ORD by 1 logical array.
%   The root of the tree may be split and it has ORD children.
%   You may split the j-th child if SPSCH(j) = 1.
%   Each node that you may split has the same property as
%   the root node.
%
%   The function DTREE returns a DTREE object.
%   For more information on object fields, type: help dtree/get.  
%
%   See also NTREE, WTBO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 24-Oct-2014.
%   Copyright 1995-2020 The MathWorks, Inc.

%===============================================
% Class DTREE (Parent objects: NTREE)
% Fields:
%   ntree - Parent object
%   allNI - All Nodes Information
%   terNI - Terminal Nodes Information
%===============================================

% Convert strings to char arrays
if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIn = nargin;
if nbIn > 14  
    error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end
if nbIn==1 && isstruct(varargin{1})
       tmp = varargin{1};
       t = set(dtree,'dataType',[],...
           'allNI',tmp.allNI,'terNI',tmp.terNI,'ntree',tmp.ntree);
    return
end

% Defaults;
order = 2;
depth = 0;
ud    = [];
spsch = true(order,1);
spflg = true;
data  = 0;
dataType = [];

% Check.
argNam = {'order','depth','data','spflg','spsch','dataType','ud'};
argFlg = zeros(length(argNam),1);
k = 1;
while k<=nbIn
   j = find(argFlg==0,1,'first');
   if isempty(j) , break; end
   if ischar(varargin{k}) && (j<8)
       j = find(strcmpi(argNam,varargin{k}));
       if isempty(j)
           if isequal(argFlg(1:3),[1 1 1]') && (k==nbIn)
               j = 7; k = k-1;
           else
               error(message('Wavelet:FunctionArgVal:Invalid_ArgNamVar', varargin{ k }));
           end
       end
       k = k+1;
   elseif isequal(argFlg(1:3),[1 1 1]') && (k==nbIn)
       j = 7;  
   end
   argFlg(j) = 1;
   field = argNam{j};
   eval([field ' = varargin{' sprintf('%0.f',k) '};'])    
   k = k+1;    
end
flagexp = true;

% handle the case in which spflg is a char
if ( ischar(spflg) )
   if ~strcmp(spflg,'expand')
      flagexp = false;
   end
else % handle the case in which it is some other datatype.
   spflg = logical(spflg);
   flagexp = spflg;
   if length(flagexp)~=1
      flagexp = false;
   end
end 

[t,nbtn] = ntree(order,depth,spsch,ud);
obj.dataType = dataType;
obj.allNI = [];
obj.terNI = [];
t = class(obj,'dtree',t);
t = set(t,'wtboInfo',class(t));
t = fmdtree('setinit',t,data);
if flagexp , t = expand(t); end
