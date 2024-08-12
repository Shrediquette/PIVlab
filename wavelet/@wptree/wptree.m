function t = wptree(order,depth,x,wname,type_ent,parameter,userdata)
%WPTREE Constructor for the class WPTREE.
%   T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR) returns
%   a complete wavelet packet tree T.
%
%   ORDER is an integer representing the order of the tree
%   (number of "children" of each non terminal node). It must
%   be equal to 2 or 4.
%
%   If ORDER = 2, T is a WPTREE object corresponding to a 
%   wavelet packet decomposition of the vector (signal) X,
%   at level DEPTH with a particular wavelet WNAME.
%
%   If ORDER = 4, T is a WPTREE object corresponding to a 
%   wavelet packet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.
%
%   ENT_TYPE is a character vector containing the type of entropy
%   and ENT_PAR is an optional parameter used for entropy
%   computation (see WENTROPY, WPDEC or WPDEC2 for more 
%   information).
%
%   T = WPTREE(ORDER,DEPTH,X,WNAME) is equivalent to 
%   T = WPTREE(ORDER,DEPTH,X,WNAME,'shannon').
%
%   With T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR,USERDATA)
%   you may set a userdata field.
%
%   The function WPTREE returns a WPTREE object.
%   For more information on object fields, type: help wptree/get.  
%
%   See also DTREE, NTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

%===============================================
% Class WPTREE (parent objects: DTREE)
% Fields:
%   dtree - Parent object.
%   wavInfo - Structure (wavelet infos)
%     wavName : Wavelet Name.
%     Lo_D    : Low Decomposition filter
%     Hi_D    : High Decomposition filter
%     Lo_R    : Low Reconstruction filter
%     Hi_R    : High Reconstruction filter
%
%   entInfo - Structure (entropy infos)
%     entName : Entropy Name
%     entPar  : Entropy Parameter
%   -----------------------------------------
%   allNI - Array(nbnode,5)  <---  in DTREE
%     [ind,size,ent,ento]
%          ind  = indice
%          size = size of data
%          ent  = Entropy
%          ento = Optimal Entropy
%===============================================

% Check arguments.
%-----------------
if nargin > 3
    wname = convertStringsToChars(wname);
end

if nargin > 4
    type_ent = convertStringsToChars(type_ent);
end

nbIn = nargin;
switch nbIn
    case 0 % Dummy. Only for loading object!
        order = 2 ; depth = 0; x = 1;  wname = 'db1';
        userdata  = []; parameter = 0.0; type_ent  = 'shannon';
    case {1,2,3}
        error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
    case 4 , userdata  = []; parameter = 0.0; type_ent  = 'shannon';
    case 5 , userdata  = []; parameter = 0.0;
    case 6 , userdata  = [];
    case 7 
    otherwise
        error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end
if strcmpi(type_ent,'user')
    if ~ischar(parameter)
        error(message('Wavelet:FunctionArgVal:Invalid_EntNam'));
    end
    type_ent  = ['user' '&' parameter];
    parameter = 0.0;
end

% Tree creation.
%---------------
d = dtree(order,depth,x,'spflg','notexpand',[],userdata);

% Wavelet infos.
%---------------
t.wavInfo.wavName = wname;
[ t.wavInfo.Lo_D,t.wavInfo.Hi_D, ...
  t.wavInfo.Lo_R,t.wavInfo.Hi_R ] = wfilters(wname);

% Entropy infos.
%---------------
t.entInfo.entName = type_ent;
t.entInfo.entPar  = parameter;

% Built object.
%---------------
t = class(t,'wptree',d);
t = set(t,'wtboInfo',class(t));
t = expand(t);
