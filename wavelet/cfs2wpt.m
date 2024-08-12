function [t,X] = cfs2wpt(wname,size_of_DATA,tn_of_TREE,order,CFS)
%CFS2WPT Wavelet packet tree construction from coefficients.
%   CFS2WPT builds a wavelet packet tree and the related 
%   analyzed signal or image.
%
%   [T,X] = CFS2WPT(WNAME,SIZE_OF_DATA,TN_OF_TREE,ORDER,CFS) returns
%   a wavelet packet tree T and the related analyzed signal or image X.
%
%     WNAME is the name of the wavelet used for the analyze.
%     SIZE_OF_DATA is the size of the analyzed signal or image.
%     TN_OF_TREE is the vector containing the terminal node 
%     indices of the tree.
%     ORDER is 2 for a signal and 4 for an image.
%     CFS is a vector, which contains the coefficients used to
%     reconstruct the original signal or image.
%
%   CFS is optional. When CFS2WPT is used without the CFS input 
%   parameter, the wavelet packet tree structure (T) is generated but
%   all the tree coefficients are null (this implies that X is null). 
%
%   Example:
%     load detail
%     t = wpdec2(X,2,'sym4');
%     cfs = read(t,'allcfs');
%     noisyCfs = cfs + 40*rand(size(cfs));
%     noisyT = cfs2wpt('sym4',size(X),tnodes(t),4,noisyCfs);
%     plot(noisyT)
%
%     t = cfs2wpt('sym4',[1 1024],[3 9 10 2]',2);
%     sN = read(t,'sizes',[3,9]);
%     sN3 = sN(1,:); sN9 = sN(2,:);
%     cfsN3 = ones(sN3);
%     cfsN9 = randn(sN9);
%     t = write(t,'cfs',3,cfsN3,'cfs',9,cfsN9);
%     plot(t)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Aug-2001.
%   Last Revision: 19-Dec-2001.
%   Copyright 1995-2020 The MathWorks, Inc.

% Computing dummy data and tree depth.
%-------------------------------------
if nargin > 0
    wname = convertStringsToChars(wname);
end

if length(size_of_DATA)==1
    size_of_DATA = [1 size_of_DATA];
end
dummy_DATA = zeros(size_of_DATA);
[d,~] = ind2depo(order,tn_of_TREE);
depth_of_TREE = max(d);

% Building the tree.
%-------------------
switch order
    case 2 ,t  = wpdec(dummy_DATA,1,wname);    
    case 4 ,t  = wpdec2(dummy_DATA,1,wname);
end
tn = leaves(t);
nodes_to_SPLIT = setdiff(tn,tn_of_TREE);
while ~isempty(nodes_to_SPLIT)
    for k = 1:length(nodes_to_SPLIT)
        t = wpsplt(t,nodes_to_SPLIT(k));
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
    else
        
    end
end
if nargout<2 , return; end

% Computing the original data.
%-----------------------------
switch order
    case 2 , X = wprec(t);    
    case 4 , X = wprec2(t);
end
