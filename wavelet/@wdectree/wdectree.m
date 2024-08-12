function t = wdectree(x,dimData,depth,varargin)
%WDECTREE Constructor for the class WDECTREE.
%   T = WDECTREE(X,DIMDATA,DEPTH,WNAME) returns a wavelet tree T.
%   If X is a vector, the tree is of order 2.
%   When X represents an indexed image, X is an m-by-n matrix.
%   When X represents a truecolor image,X is an m-by-n-by-3 array.
%   In both cases, the tree is of order 4.
%
%   The DWT extension mode is the current one.
%
%   T = WDECTREE(X,DIMDATA,DEPTH,WNAME,DWTMODE) returns a wavelet tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = WDECTREE(X,DIMDATA,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.
%
%   T is a WDECTREE object corresponding to a
%   wavelet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 01-May-2009.
%   Copyright 1995-2020 The MathWorks, Inc.

%===============================================
% Class WDECTREE (parent class: DTREE)
% Fields:
%   dtree - Parent object
%   dimData - Dimension of data.
%   WT_Settings - Structure
%     typeWT  : - type of Wavelet Transform.
%     wname   : Wavelet Name.
%     extMode : DWT extension mode.
%     shift   : DWT shift value.
%     Filters : Structure of filters
%        Lo_D : Low Decomposition filter
%        Hi_D : High Decomposition filter
%        Lo_R : Low Reconstruction filter
%        Hi_R : High Reconstruction filter
%===============================================

% Check arguments.
%-----------------
nargoutchk(0,1);
userdata = {};
WT_Settings = struct(...
    'typeWT','dwt','wname','db1',...
    'extMode','sym','shift',0);

switch nargin
    case 0  % Dummy. Only for loading object!
        x = 0; dimData = 2 ; depth = 0;
        
    case 3  % Use the default Wavelet Transform Settings
        
    otherwise
        narginchk(4,11);
        if isstruct(varargin{1})
            narginchk(4,5);
            WT_Settings = varargin{1};
            if nargin==5 , userdata = varargin{2}; end
        else
            nbVarIN = length(varargin);
            for k=1:2:nbVarIN
                typeArg = lower(varargin{k});
                switch typeArg
                    case 'typewt' ,  WT_Settings.typeWT  = varargin{k+1};
                    case 'wname'  ,  WT_Settings.wname   = varargin{k+1};
                    case 'extmode' , WT_Settings.extMode = varargin{k+1};
                    case 'shift'  ,  WT_Settings.shift   = varargin{k+1};
                end
            end
        end
end

% Tree creation.
%---------------
switch dimData
    case 1
        order = 2;
        typData = '1d';
    case 2
        order = 4;
        if length(size(x))<3 , typData = '2d'; else typData = '2d3';  end
        tmp = WT_Settings.shift;
        if length(tmp)==1 , WT_Settings.shift = [tmp tmp]; end
end
switch WT_Settings.typeWT
    case {'dwt','lwt'}  , spsch = [1 ; zeros(order-1,1)];
    case {'wpt','lwpt'} , spsch = ones(order,1);        
end
d = dtree(order,depth,x,'spsch',spsch,'spflg',0,'ud',userdata);

% Compute Filters.
%-----------------
switch WT_Settings.typeWT
    case {'dwt','wpt'}
        [Lo_D,Hi_D,Lo_R,Hi_R] = wfilters(WT_Settings.wname);
        WT_Settings.Filters = ...
            struct('Lo_D',Lo_D,'Hi_D',Hi_D,'Lo_R',Lo_R,'Hi_R',Hi_R);
        
    case {'lwt','lwpt'}
        WT_Settings.LS = liftwave(WT_Settings.wname);
end
t.typData = typData;
t.dimData = dimData;
t.WT_Settings = WT_Settings;

% Built object.
%---------------
t = class(t,'wdectree',d);
t = expand(t);
