function x = recons(t,node,x,sizes,edges) %#ok<INUSL>
%RECONS Reconstruct wavelet packet coefficients.
%   Y = RECONS(T,N,X,S,E) reconstructs the 
%   wavelet packet coefficients X associated with
%   the node N of the wavelet packet tree T,
%   using sizes S and the edges values E.
%   S contains the size of datas associated with
%   each ascendant of N.
%   The children of a node F are numbered from left 
%   to right: [0, ... , ORDER-1].
%   The edge value between F and a child C is the
%   child number.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Get DWT_Mode
dwtATTR = dwtmode('get');

order = treeord(t);
Lo_R  = t.wavInfo.Lo_R;
Hi_R  = t.wavInfo.Hi_R;
nb_up = length(edges);
f     = zeros(nb_up,length(Lo_R));
switch order
    case 2
        K = find(edges==0);
        if ~isempty(K) , f(K,:) = Lo_R(ones(size(K)),:); end
        K = find(edges==1);
        if ~isempty(K) , f(K,:) = Hi_R(ones(size(K)),:); end
        for k=1:nb_up
            s = max(sizes(k,:));
            x = upsconv1(x,f(k,:),s,dwtATTR);
        end

    case 4
        g = f;
        K = find(edges==0);
        if ~isempty(K)
            f(K,:) = Lo_R(ones(size(K)),:);
            g(K,:) = Lo_R(ones(size(K)),:);
        end
        K = find(edges==1);
        if ~isempty(K)
            f(K,:) = Hi_R(ones(size(K)),:);
            g(K,:) = Lo_R(ones(size(K)),:);
        end
        K = find(edges==2);
        if ~isempty(K)
            f(K,:) = Lo_R(ones(size(K)),:);
            g(K,:) = Hi_R(ones(size(K)),:);
        end
        K = find(edges==3);
        if ~isempty(K)
            f(K,:) = Hi_R(ones(size(K)),:);
            g(K,:) = Hi_R(ones(size(K)),:);
        end
        for k=1:nb_up
            s = sizes(k,:);
            x = upsconv2(x,{f(k,:),g(k,:)},s,dwtATTR);
        end
end
