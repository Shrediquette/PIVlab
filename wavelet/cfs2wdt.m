function [t,X] = cfs2wdt(WT_Settings,size_of_DATA,tn_of_TREE,order,CFS)
%CFS2WDT Wavelet decomposition tree construction from coefficients.
%
%   See also WDECTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Mar-2003.
%   Last Revision: 21-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

% Computing dummy data and tree depth.
%-------------------------------------
if length(size_of_DATA)==1
    size_of_DATA = [1 size_of_DATA];
end
dummy_DATA = zeros(size_of_DATA);
switch order
    case 2 , dimData = 1;
    case 4 , dimData = 2;
end
    
% Building the tree.
%-------------------
t = wdectree(dummy_DATA,dimData,1,WT_Settings);
tn = leaves(t);
nodes_to_SPLIT = setdiff(tn,tn_of_TREE);
while ~isempty(nodes_to_SPLIT)
    for k = 1:length(nodes_to_SPLIT)
        t = wdtsplit(t,nodes_to_SPLIT(k));
    end
	tn = leaves(t);
	nodes_to_SPLIT = setdiff(tn,tn_of_TREE);    
end   

% Restoring the coefficients.
%----------------------------
if nargin>4
    dummy_CFS = read(t,'data');
    if isequal(size(dummy_CFS),size(CFS))
        t = write(t,'data',CFS);
    end
end
if nargout<2 , return; end

% Computing the original data.
%-----------------------------
X = wdtrec(t);  
