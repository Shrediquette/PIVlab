function varargout = read(t,varargin)
%READ Read values in WPTREE object fields.
%   VARARGOUT = READ(T,VARARGIN) is the most general syntax to read
%   one or more property values from the fields of a WPTREE object.
%
%   The different ways to call the READ function are:
%     PropValue = READ(T,'PropName') or
%     PropValue = READ(T,'PropName','PropParam')
%     Or any combination of previous syntaxes:
%     [PropValue1,PropValue2, ...] = ...
%         READ(T,'PropName1','PropParam1','PropName2','PropParam2',...)
%         PropParam is optional.
%
%   The valid choices for PropName are:
%     'ent', 'ento', 'sizes' (see WPTREE):
%        Without PropParam, PropValue contains the entropy (or optimal
%        entropy or size) of the tree nodes in ascending node
%        index order, or with PropParam = Vector of node indices.
%
%     'cfs': With PropParam = One terminal node index.
%        cfs = READ(T,'cfs',NODE) is equivalent to
%        cfs = READ(T,'data',NODE) and returns the coefficients
%        of the terminal node NODE.
%
%     'entName', 'entPar', 'wavName' (see WPTREE), 'allcfs':
%        Without PropParam.
%        cfs = READ(T,'allcfs') is equivalent to cfs = READ(T,'data').
%        PropValue contains the desired information in ascending node
%        index order of the tree nodes.
%
%     'wfilters' (see WFILTERS):
%        without PropParam or with PropParam = 'd', 'r', 'l', 'h'.
%
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node index or
%             PropParam = Column vector of terminal node indices.
%        In the last case, the PropValue is a cell array.
%        Without PropParam, PropValue contains the coefficients of
%        the tree nodes in ascending node index order.
%
%   Examples:
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%     sAll = read(t,'sizes');
%     sNod = read(t,'sizes',[0,4,5]);
%     eAll = read(t,'ent');
%     eNod = read(t,'ent',[0,4,5]);
%     dAll = read(t,'data');
%     dNod = read(t,'data',[4;5]);
%     [lo_D,hi_D,lo_R,hi_R] = read(t,'wfilters');
%     [lo_D,lo_R,hi_D,hi_R] = read(t,'wfilters','l','wfilters','h');
%     [ent,ento,cfs4,cfs5]  = read(t,'ent','ento','cfs',4,'cfs',5);
%
%   See also DISP, GET, SET, WPTREE, WRITE.

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%    Examples:
%      stnAll = read(t,'tnsizes');
%      stnNod = read(t,'tnsizes',[1,2]);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
k    = 1;
kout = 1;
while k<=nbin
    argNAME = lower(varargin{k});
    switch argNAME
        case {'ent','ento'}
            if isequal(argNAME,'ent') , col = 4; else col = 5; end
            sNod = read(t,'tnsizes',1);
            if length(sNod)>2 , col = col+1; end  % truecolor image
            if k<nbin
                arg = varargin{k+1};
                if ischar(arg) && ~strcmp(arg,'all')
                    arg = 'all';
                else
                    k = k+1;
                end
            else
                arg = 'all';
            end
            varargout{kout} = fmdtree('an_read',t,arg,col);
            kout = kout+1;

        case 'cfs'
            if k<nbin
                arg = varargin{k+1}; k = k+1;
            else
                error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
            end
            varargout{kout} = read(t,'data',arg);
            kout = kout+1;

        case 'allcfs'  , varargout{kout} = read(t,'data');    kout = kout+1;
        case 'entname' , varargout{kout} = t.entInfo.entName; kout = kout+1;
        case 'entpar'  , varargout{kout} = t.entInfo.entPar;  kout = kout+1;
        case 'wavname' , varargout{kout} = t.wavInfo.wavName; kout = kout+1;

        case 'wfilters'
            if k<nbin, arg = varargin{k+1}; else arg = 'last'; end
            switch arg
                case 'd'
                    varargout{kout} = t.wavInfo.Lo_D; kout = kout+1;
                    varargout{kout} = t.wavInfo.Hi_D; kout = kout+1;
                    k = k+1;

                case 'r'
                    varargout{kout} = t.wavInfo.Lo_R; kout = kout+1;
                    varargout{kout} = t.wavInfo.Hi_R; kout = kout+1;
                    k = k+1;

                case 'l'
                    varargout{kout} = t.wavInfo.Lo_D; kout = kout+1;
                    varargout{kout} = t.wavInfo.Lo_R; kout = kout+1;
                    k = k+1;

                case 'h'
                    varargout{kout} = t.wavInfo.Hi_D; kout = kout+1;
                    varargout{kout} = t.wavInfo.Hi_R; kout = kout+1;
                    k = k+1;

                otherwise
                    varargout{kout} = t.wavInfo.Lo_D; kout = kout+1;
                    varargout{kout} = t.wavInfo.Hi_D; kout = kout+1;
                    varargout{kout} = t.wavInfo.Lo_R; kout = kout+1;
                    varargout{kout} = t.wavInfo.Hi_R; kout = kout+1;
                    if isequal(arg,'all') || isequal(arg,'a'), k = k+1; end
            end

        case {'an','sizes','data','tnsizes'}
            field = varargin{k};
            if k<nbin && ...
                  (isnumeric(varargin{k+1}) || isequal(varargin{k+1},'all'))
                arg = varargin{k+1}; k = k+1;
            else
                arg = 'all';
            end
            varargout{kout} = read(t.dtree,field,arg); kout = kout+1;

        otherwise
            error(message('Wavelet:FunctionArgVal:Unknown_Field'));
    end
    k = k+1;
end
