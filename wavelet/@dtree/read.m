function varargout = read(t,varargin)
%READ Read values in DTREE object fields.
%   VARARGOUT = READ(T,VARARGIN) is the most general syntax to read
%   one or more property values from the fields of a DTREE object.
%
%   The different ways to call the READ function are:
%     PropValue = READ(T,'PropName') or
%     PropValue = READ(T,'PropName','PropParam')
%     Or combinations of previous syntax:
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam is optional.
%
%   The valid choices for PropName are:
%     'sizes': with PropParam = Vector of node indices.
%
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node indices or
%             PropParam = Column vector of terminal node indices.
%        In the last case, the PropValue is a cell array.
%
%   Examples:
%     x = (0:0.1:1);
%     t = dtree(2,3,x);
%     t = nodejoin(t,[4;5]);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     stnAll = read(t,'tnsizes');
%     stnNod = read(t,'tnsizes',[4,5]);

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%
% 'an':
%    With PropParam = Vector of nodes indices.
%    NODES = READ(T,'an') returns all nodes of T.
%    NODES = READ(T,'an',NODES) returns the valid nodes of T
%    contained in the vector NODES.
%
%   See also DISP, GET, SET, WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
varargin{nbin+1} = 'all';
k    = 1;
kout = 1;
while k<=nbin
    argNAME = varargin{k};
    switch argNAME
        case {'an','sizes'}
            switch argNAME
                case 'an'    , col = 1;
                case 'sizes' , col = 2:3;
            end
            if ischar(varargin{k+1}) % all nodes
                i_nodes = (1:size(t.allNI,1))';
                if isequal(varargin{k+1},'all') , k = k+1; end
            else
                i_nodes = gidxsint(t.allNI(:,1),varargin{k+1});
                k = k+1;
            end
            varargout{kout} = t.allNI(i_nodes,col);
            kout = kout+1;

        case 'data'
            nextarg = varargin{k+1};
            if ischar(nextarg)
                if isequal(nextarg,'all') , k = k+1; end
                varargout{kout} = t.terNI{2};
            else
                n_rank = istnode(t,nextarg);
                if any(n_rank==0)
                    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
                end
                k = k+1;
                data = fmdtree('tn_read',t,'data',n_rank);
                if length(n_rank)==1
                    varargout{kout} = data{1};
                else
                    varargout{kout} = data;
                end
                kout = kout+1;
            end

        case 'tnsizes'
            % optional next argument:
            % nodes indices in tree structure or 'all'
            %-------------------------------------------
            nextarg = varargin{k+1};
            if ischar(nextarg) && ~strcmp(nextarg,'all')
                nextarg = 'all';
            else
                k = k+1;
            end
            varargout{kout} = fmdtree('tn_read',t,'sizes',nextarg);
            kout = kout+1;

        otherwise
            error(message('Wavelet:FunctionArgVal:Unknown_Field'));
    end
    k = k+1;
end
