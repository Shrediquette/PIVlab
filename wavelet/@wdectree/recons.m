function x = recons(t,node,x,sizes,edges) %#ok<INUSL>
%RECONS Reconstruct wavelet coefficients.
%   Y = RECONS(T,N,X,S,E) reconstructs the 
%   wavelet packet coefficients X associated with the node N
%   of the wavelet tree T, using sizes S and the edges values E.
%   S contains the size of data associated with
%   each ascendant of N.
%   The children of a node F are numbered from left 
%   to right: [0, ... , ORDER-1].
%   The edge value between F and a child C is the child number.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 21-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

[order,typeWT] = get(t,'order','typeWT');
nb_up = length(edges);
switch typeWT
    case {'dwt','wpt'}
        [shift,extMode,Lo_R,Hi_R] = get(t,'shift','extMode','Lo_R','Hi_R');
        f = zeros(nb_up,length(Lo_R));
        switch order
            case 2
                K = find(edges==0);
                if ~isempty(K) , f(K,:) = Lo_R(ones(size(K)),:); end
                K = find(edges==1);
                if ~isempty(K) , f(K,:) = Hi_R(ones(size(K)),:); end
                for k=1:nb_up
                    s = max(sizes(k,:));
                    x = upsconv1(x,f(k,:),s,extMode,shift);
                end
                
            case 4
                dwtATTR = struct('extMode',extMode,...
                    'shift1D',shift,'shift2D',shift);
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
                    x = upsconv2(x,{f(k,:),g(k,:)},sizes(k,:),dwtATTR);                    
                end
        end
            
    case {'lwt','lwpt'} %%%   #### Under Development ####
        switch order
            case 2 
            case 4 
        end        
end
