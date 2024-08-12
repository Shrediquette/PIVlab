function varargout = read(t,varargin)
%READ Read values in WDECTREE object fields.
%   VARARGOUT = READ(T,VARARGIN) is the most general syntax to read
%   one or more property values from the fields of a WDECTREE object.
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
%     'cfs': With PropParam = One terminal node index.
%        cfs = READ(T,'cfs',NODE) is equivalent to
%        cfs = READ(T,'data',NODE) and returns the coefficients
%        of the terminal node NODE.
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

% INTERNAL OPTIONS:
%------------------
% 'tnsizes':
%    Without PropParam or with PropParam = Vector of terminal node ranks.
%    The terminal nodes are ordered from left to right.
%    Examples:
%      stnAll = read(t,'tnsizes');
%      stnNod = read(t,'tnsizes',[1,2]);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
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
      case 'cfs'
          if k<nbin
              arg = varargin{k+1}; k = k+1;
          else
              errargt(mfilename,'invalid node index ... ','msg');
              error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
          end
          varargout{kout} = read(t,'data',arg);
          kout = kout+1;

      case 'allcfs'  , varargout{kout} = read(t,'data');    kout = kout+1;
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
          errargt(mfilename,'switch error ... ','msg');
          error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
  end
  k = k+1;
end
