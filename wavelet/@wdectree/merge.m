function x = merge(t,node,tnd)
%MERGE Merge (recompose) the data of a node.
%   X = MERGE(T,N,TNDATA) recomposes the data X 
%   associated to the node N of the data tree T,
%   using the data associated to the children of N.
%
%   TNDATA is a cell array (ORDER x 1) or (1 x ORDER)
%   such that TNDATA{k} contains the data associated to
%   the k-th child of N.
%
%   The method uses IDWT (respectively IDWT2) for
%   one-dimensional (respectively two-dimensional) data.
%
%   This method overloads the DTREE method.
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 20-Dec-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

s = read(t,'sizes',node);
[order,typeWT] = get(t,'order','typeWT');
switch typeWT
    case {'dwt','wpt'}
        [shift,extMode,Lo_R,Hi_R] = get(t,'shift','extMode','Lo_R','Hi_R');        
        switch order
            case 2  
                x = idwt(tnd{1},tnd{2},...
                    Lo_R,Hi_R,max(s),'mode',extMode,'shift',shift);
            case 4 
                x = idwt2(tnd{1},tnd{2},tnd{3},tnd{4},...
                    Lo_R,Hi_R,s,'mode',extMode,'shift',shift);
        end
 
    case {'lwt','lwpt'}
        typeDEC = typeWT(2:3);
        LS = t.WT_Settings.LS;
        switch order
            case 2 
                x = ilwt(tnd{1},tnd{2},LS,1,'typeDEC',typeDEC);
            case 4 
                x = ilwt2(tnd{1},tnd{2},tnd{3},tnd{4},LS,1,'typeDEC',typeDEC);
        end        
end
