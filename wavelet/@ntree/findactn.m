function [tnrank,nodes] = findactn(t,varargin)
%FINDACTN find active nodes.
%   ST = FINDACTN(T) returns the status for all nodes of T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-98.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
switch nbin
  case 0 , nodes = allnodes(t); type = 'flag'; 
  case 1 , nodes = varargin{1}; type = 'flag';
  case 2 , nodes = varargin{1}; type = varargin{2};
end
order = t.order;
spsch = t.spsch;
nodes  = depo2ind(order,nodes);
tnrank = istnode(t,nodes);
i_loc  = locnumcn(nodes,order);
act    = spsch(i_loc);
i_Root = find(nodes==0);
if ~isempty(i_Root) && order>0 , act(i_Root) = true; end
switch type
  case 'a'      , indic =  act; 
  case 'a_tn'   , indic =  act & (tnrank>0);
  case 'a_ntn'  , indic =  act & (tnrank==0);
  case 'na'     , indic = ~act & (tnrank>0);   % always <==> 'na_tn'
  case 'na_tn'  , indic = ~act; 
  case 'na_ntn' , indic = ~act & (tnrank==0);  % always empty !!
  otherwise     , tnrank(~act) = NaN; return
end
tnrank = tnrank(indic);
nodes  = nodes(indic);
