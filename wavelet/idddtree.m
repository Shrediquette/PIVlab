function x = idddtree(dt)
%IDDDTREE Inverse Real and Complex Double and Double-Density 
%         Dual-Tree 1-D DWT
%   X = IDDDTREE(DT) returns the reconstructed vector X 
%   using the decomposition tree DT.
%
%   DT is a structure which contains five fields:
%      type:    type of tree.
%      level:   level of decomposition.
%      filters: the filters for decomposition.
%      cfs:     coefficients of wavelet transform.
%   See DDDTREE for more precision about the tree structure.
%
%   The reconstruction filters FRf and Rf are included in
%   the structure DT.
%   FRf and Rf are cell arrays of vectors with: 
%      FRf{k}: First stage filters for tree k (k = 1,2)
%      Rf{k} : Filters for remaining stages on tree k
%
% See also DDDTREE, DDDTREE2, DTFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Nov-2012.
%   Last Revision: 04-Apr-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

cfs = dt.cfs;
typetree = dt.type;
L = dt.level;
FRf = dt.filters.FRf;
Rf  = dt.filters.Rf;
switch typetree
    case 'dwt'
    % Inverse Discrete 1-D Wavelet Transform
        x = cfs{L+1};
        for j = L:-1:1
            x = recFB(x,cfs{j},Rf);
        end        
        
    case 'cplxdt'  
    % Inverse Dual-tree Complex DWT        
        % Tree 1 and 2
        x = 0;
        for k = 1:2
            y = cfs{L+1}(:,:,k);
            for j = L:-1:1
                if j==1 , recF = FRf{k}; else recF = Rf{k}; end
                y = recFB(y,cfs{j}(:,:,k),recF);
            end
            x = x+y;
        end
        % normalization
        x = x/sqrt(2);
       
    case 'ddt'
    % Inverse Double-Density Discrete 1-D Wavelet Transform
        x = cfs{L+1};
        for j = L:-1:1
            x = recFB3(x,cfs{j},Rf);
        end
                        
    case 'cplxdddt'
    % Inverse 1-D Double-Density Dual-Tree Complex DWT
        % Tree 1 and 2        
        x = 0;
        for k = 1:2
            y = cfs{L+1}(:,:,k);
            for j = L:-1:1
                if j==1 , recF = FRf{k}; else recF = Rf{k}; end
                y = recFB3(y,cfs{j}(:,:,:,k),recF);
            end
            x = x+y;
        end
        % normalization
        x = x/sqrt(2);
end


%-------------------------------------------------------------------------
function x = recFB(Lo,Hi,Rf)
% Reconstruction filter bank
%
% INPUT:
%    Lo - low frequency input
%    Hi - high frequency input
%    Rf - Reconstruction filters
%    Rf(:,1) - lowpass filter (even length)
%    Rf(:,2) - highpass filter (even length)

N = 2*length(Lo);
lf = length(Rf);
Lo = conv(dyadup(Lo,0),Rf(:,1));
Hi = conv(dyadup(Hi,0),Rf(:,2));
x = Lo + Hi;
x(1:lf-2) = x(1:lf-2) + x(N+(1:lf-2));
x = x(1:N);
x = wshift('1d',x,lf/2-1);
%-------------------------------------------------------------------------
function x = recFB3(Lo,Hi,Rf)
% Reconstruction Filter Bank (consisting of three filters)
% 
% INPUT:
%     Lo - low frqeuency input
%     Hi - ND array containing high frequency inputs
%       1) Hi(:,:,1) - first high frequency input
%       2) Hi(:,:,2) - second high frequency input
%     Rf - Reconstruction filters
%    Rf(:,1) - lowpass filter (even length)
%    Rf(:,2) - first highpass filter (even length)
%    Rf(:,3) - second highpass filter (even length)

N = 2*length(Lo);
lf = length(Rf);
Lo = conv(dyadup(Lo,0),Rf(:,1));
H1 = conv(dyadup(Hi(:,:,1),0),Rf(:,2));
H2 = conv(dyadup(Hi(:,:,2),0),Rf(:,3));
x = Lo + H1 + H2;
x(1:lf-2) = x(1:lf-2) + x(N+(1:lf-2));
x = x(1:N);
x = wshift('1d',x,lf/2-1);
%-------------------------------------------------------------------------




