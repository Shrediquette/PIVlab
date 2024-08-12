function varargout = wtreemgr(option,t,varargin)
%WTREEMGR NTREE object manager.
%   VARARGOUT = WTREEMGR(OPTION,T,VARARGIN)
%   Allowed values for OPTION and associated uses are
%   described in the functions listed in the See also section:
%
%   'order'    : Order of tree.
%   'depth'    : Depth of tree.
%   'leaves'   : Terminal nodes.
%   'tnodes'   : Terminal nodes.
%   'noleaves' : Not Terminal nodes.
%   'allnodes' : All nodes.
%   'isnode'   : Is node.
%   'istnode'  : Lop "is terminal node".
%   'nodeasc'  : Node ascendants.
%   'nodedesc' : Node descendants.
%   'nodepar'  : Node parent.
%   'ntnode'   : Number of terminal nodes.
%
%    See also ALLNODES, ISNODE, ISTNODE, LEAVES, NODEASC, NODEDESC,
%             NODEPAR, NOLEAVES, NTNODE, TNODES, TREEDPTH, TREEORD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

if isStringScalar(option)
    option = convertStringsToChars(option);
end

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

switch option
    case {'order','depth'} , varargout{1} = t.(option);
    
    case 'leaves' 
        order = t.order;
        tn  = t.tn;
        K = (1:length(tn))';
        if nargin>2
            flagdps = varargin{1};
            switch flagdps
                case {'s','sort'}
                  [tn,K] = sort(tn); [~,K] = sort(K);

                case {'sdp','dps','sortdp','dpsort'}
                  [tn,K] = sort(tn); [~,K] = sort(K);
                  [tn(:,1),tn(:,2)] = ind2depo(order,tn);

                case {'dp'}
                  [tn(:,1),tn(:,2)] = ind2depo(order,tn);
            end
        end
        varargout = {tn,K};
  
    case 'tnodes'
        if nargin==2 , outType = 'sort'; else outType = 'sortdp'; end
        [varargout{1},varargout{2}] = wtreemgr('leaves',t,outType);

    case 'noleaves'    
        if nargin==2 , flagdp = false; else flagdp = true; end 
        varargout{1} = descendants(t,0,'not_tn',flagdp);

    case 'allnodes'
        order = t.order;
        depth = t.depth;
        varargout{1}    = t.tn;
        if (length(varargout{1})==1) && (depth==0) , return; end
        if nargin==2 , flagdp = false; else flagdp = true; end
        varargout{1} = ascendants(varargout{1},order,depth,flagdp);
        
    case 'isnode'
        order = t.order;
        depth = t.depth;
        allN  = t.tn;
        if (depth~=0)
            flagdp = false;
            allN = ascendants(allN,order,depth,flagdp);
        end
        nodes = depo2ind(order,varargin{1});
        if numel(nodes)<=1
            if find(allN==nodes), varargout{1} = true;
            else varargout{1} = false;
            end
        else
            varargout{1} = ismember(nodes,allN);
        end

    case 'istnode'
        order = t.order;
        tn    = t.tn;
        nodes = depo2ind(order,varargin{1});
        [~,varargout{1}] = ismember(nodes,tn);

    case 'nodeasc'
        order = t.order;
        node  = depo2ind(order,varargin{1});
        d = ind2depo(order,node);
        if nargin==3 , flagdp = false; else flagdp = true; end
        varargout{1} = flipud(ascendants(node,order,d,flagdp));

    case 'nodedesc'
        if nargin==3 , flagdp = false; else flagdp = true; end
        varargout{1} = descendants(t,varargin{1},'all',flagdp);

    case 'nodepar'
        order = t.order;
        node  = depo2ind(order,varargin{1});
        par   = floor((node-1)/order);
        if nargin==4 , [par(:,1),par(:,2)] = ind2depo(order,par); end
        varargout{1} = par; 

    case 'ntnode'
        tn = t.tn';
        varargout{1} = length(tn);

    otherwise
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end
