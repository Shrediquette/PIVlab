function t = write(t,varargin)
%WRITE Write values in WDECTREE object fields.
%   T = write(T,'cfs',NODE,COEFS) writes coefficients for the
%   terminal node NODE.
%
%   T = write(T,'cfs',N1,CFS1,'cfs',N2,CFS2, ...) writes coefficients
%   for the terminal nodes N1, N2, ...
%
%   Caution:
%     The coefficients values has to have the suitable sizes.
%     Use S = READ(T,'sizes',NODE) or S = READ(T,'sizes',[N1;N2; ... ])
%     to get those sizes.
%
%   Examples:
%     % Create a wavelet packets tree.
%     x = rand(1,512);
%     WT_Settings = struct('typeWT','dwt','wname','db1',...
%            'extMode','sym','shift',0);
%     t = wdectree(x,2,3,WT_Settings);
%     t = wdtjoin(t,[4;5]);
%     plot(t);
%
%     % Write values.
%     sNod = read(t,'sizes',[4,5]);
%     cfs4 = zeros(sNod(1,:));
%     cfs5 = zeros(sNod(2,:));
%     t = write(t,'cfs',4,cfs4,'cfs',5,cfs5);
%
%   See also DISP, GET, READ, SET.

%   INTERNAL OPTIONS :
%----------------------
%   The valid choices for PropName are:
%     'ent', 'ento', 'sizes':
%        Without PropParam or with PropParam = Vector of nodes indices.
%     'cfs':  with PropParam = One node indices.
%     'allcfs', 'entName', 'entPar', 'wavName': without PropParam.
%     'wfilters':
%        without PropParam or with PropParam = 'd', 'r', 'l', 'h'.
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node indices or
%             PropParam = Vector terminal node indices.
%        In the last case, the PropValue is a cell array.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbin = length(varargin);
k = 1;
while k<=nbin
    argNAME = lower(varargin{k});
    switch argNAME
        case 'cfs'
            if k>=nbin-1
                errargt(mfilename,'invalid number of arguments ... ','msg');
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
            end
            t = write(t,'data',varargin{k+1:k+2});
            k = k+1;

        case 'allcfs'  , t = write(t,'data',varargin{k+1});
        case 'wavname'
            t.wavInfo.wavName = varargin{k+1};
            [t.wavInfo.Lo_D,t.wavInfo.Hi_D, ...
             t.wavInfo.Lo_R,t.wavInfo.Hi_R] = wfilters(varargin{k+1});

        case 'data'
            if k<nbin-1 && isnumeric(varargin{k+2})
                t.dtree = write(t.dtree,'data',varargin{k+1:k+2});
                k = k+1;
            else
                t.dtree = write(t.dtree,'data',varargin{k+1});
            end

        otherwise
            errargt(mfilename,'switch error ... ','msg');
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
    end
    k = k+2;
end
