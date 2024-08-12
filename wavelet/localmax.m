function [y,I,x] = localmax(x,rowInit,reguleFLG)
%LOCALMAX Compute local maxima positions.
%   For a matrix X, LOCALMAX computes and chains the local 
%   maxima along the rows.
%       [Y,I] = LOCALMAX(X,ROWINIT,REGFLAG); or 
%       [Y,I] = LOCALMAX(X,ROWINIT); or
%       [Y,I] = LOCALMAX(X);
%   The default values are: ROWINIT = size(X,1) and REGFLAG = true.
%
%   First, LOCALMAX computes the local maxima positions on each 
%   row of X. Then, starting from the row (ROWINIT-1), LOCALMAX chains
%   the maxima positions along the columns. If p0 is a local maxima 
%   position on the row R0, then p0 is linked to the nearest maxima 
%   position on the row R0+1.
%       Y is a matrix of the same size of X such that:
%       When R = ROWINIT, Y(ROWINIT,j) = j if X(ROWINIT,j) is a local
%       maximum and 0 otherwise.
%       When R < ROWINIT, if X(R,j) is not a local maximum then Y(R,j) = 0.
%       Otherwise if X(R,j) is a local maximum, then Y(R,j) = k,
%       where k is such that: X(R+1,k) is a local maximum and k is the 
%       nearest position of j.
%       I contains the indices of non zero values of Y
%
%   If REGFLAG = true, S = X(ROWINIT,:) is first regularized using
%   the wavelet 'sym4'. Instead of S, the approximation of level 5
%   is used to start the algorithm.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Oct-96.
%   Last Revision: 25-Sep-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

[r,col] = size(x);
if nargin<2
    rowInit = r; reguleFLG = true;
elseif nargin<3
    reguleFLG = true;
end
if isempty(rowInit) || (rowInit<1) || (rowInit>r)
    rowInit = r;
end

% Select the algorithm.
%----------------------
if col<400 , NUM_ALG = 2; else NUM_ALG = 1; end

% Regularization of  x (!?)
%--------------------------
if reguleFLG
    wav = 'sym4';
    lev = 5;
    [cfs,len] = wavedec(x(rowInit,:),lev,wav);
    x(rowInit,:) = wrcoef('a',cfs,len,wav);
end
y = [zeros(r,1) diff(abs(x),1,2)];
y(abs(y)<sqrt(eps)) = 0;
y(y<0) = -1;
y(y>0) = 1;
y = diff(y,1,2);
I = find(y==-2);
y = zeros(size(x));
y(I) = 1;

% Chain maxima - Eliminate "false" maxima.
%-----------------------------------------
ideb = rowInit ; step = -1; ifin = 1;
max_down = find(y(ideb,:));
y(ideb,max_down) = max_down;
if rowInit<2 , return; end

switch NUM_ALG
    case 1
        for jj = ideb+step:step:ifin
            max_curr = find(y(jj,:));
            nb_curr = length(max_curr);
            if ~isempty(max_down)
                Idx = zeros(nb_curr,1);
                for rr = 1:nb_curr
                    V = abs(max_curr(rr)-max_down);
                    [~,kk] = min(V);
                    Idx(rr) = kk;
                end
                
                val_max = max_down(Idx);
                if ~isempty(val_max)
                    y(jj,max_curr) = val_max;
                    max_down = max_curr(val_max~=0);
                end
            else
                max_down = find(y(jj,:));
                jj = jj-1;         %#ok<FXSET>
                if jj<ifin , break; end
            end
        end
        
    case 2
        for jj = ideb+step:step:ifin
            max_curr = find(y(jj,:));
            nb_curr = length(max_curr);
            nb_down = length(max_down);
            
            D = zeros(nb_curr,nb_down);
            for rr = 1:nb_curr
                for cc = 1:nb_down
                    D(rr,cc) = abs(max_curr(rr)-max_down(cc));
                end
            end
            [~,Idx] = min(D,[],2);
            
            val_max = max_down(Idx);
            if ~isempty(val_max)
                y(jj,max_curr) = val_max;
                max_down = max_curr(val_max~=0);
            else
                max_down = find(y(jj,:));
                jj = jj-1;         %#ok<FXSET>
                if jj<ifin , break; end
            end
        end        
end
