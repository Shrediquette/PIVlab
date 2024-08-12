function tnd = split(t,node,x,varargin) %#ok<INUSL>
%SPLIT Split (decompose) the data of a terminal node.
%   TNDATA = SPLIT(T,N,X) decomposes the data X 
%   associated to the terminal node N of the 
%   wavelet tree T.
%
%   TNDATA is a cell array (ORDER x 1) such that TNDATA{k}
%   contains the data associated to the k-th child of N.
%
%   The method uses DWT (respectively DWT2) for
%   one-dimensional (respectively two-dimensional) data.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 22-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.
 
[~,order,typeWT] = get(t,'dataType','order','typeWT');
tnd = cell(order,1);
switch typeWT
    case {'dwt','wpt'}
        [shift,extMode,Lo_D,Hi_D] = get(t,'shift','extMode','Lo_D','Hi_D');
        switch order
            case 2  
                [tnd{1},tnd{2}] = ...
                    dwt(x,Lo_D,Hi_D,'mode',extMode,'shift',shift);
            case 4 
                [tnd{1},tnd{2},tnd{3},tnd{4}] = ...
                    dwt2(x,Lo_D,Hi_D,'mode',extMode,'shift',shift);
        end
    case {'lwt','lwpt'}
        typeDEC = typeWT(2:3);
        LS = t.WT_Settings.LS;
        switch order
            case 2 
                [tnd{1},tnd{2}] = lwt(x,LS,1,'typeDEC',typeDEC);
            case 4 
                [tnd{1},tnd{2},tnd{3},tnd{4}] = lwt2(x,LS,1,'typeDEC',typeDEC);
        end        
end
