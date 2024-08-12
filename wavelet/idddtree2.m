function x = idddtree2(dt)
%IDDDTREE2 Inverse Real and Complex Double and Double-Density 
%          Dual-Tree 2-D DWT
%   X = IDDDTREE2(DT) returns the reconstructed matrix X 
%   using the decomposition tree DT.
%
%   DT is a structure which contains five fields:
%      type:    type of tree.
%      level:   level of decomposition.
%      filters: the filters for decomposition.
%      cfs:     coefficients of wavelet transform.
%      sizes:   sizes of components. 
%   See DDDTREE2 for more precision about the tree structure.
%
%   The reconstruction filters FRf and Rf are included in
%   the structure DT.
%   FRf and Rf are cell arrays of vectors with: 
%      FRf{k}: First stage filters for tree k (k = 1,2)
%      Rf{k} : Filters for remaining stages on tree k
%
%   See also DDDTREE2, DDDTREE, DTFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Nov-2012.
%   Last Revision: 14-November-2017.
%   Copyright 1995-2020 The MathWorks, Inc.

cfs = dt.cfs;
typetree = dt.type;
L = dt.level;
FRf = dt.filters.FRf;
Rf  = dt.filters.Rf;
switch typetree
    case 'dwt'
    % Inverse 2-D Discrete Wavelet Transform   
        x = cfs{L+1};
        for j = L:-1:1
            x = recFB(x,cfs{j},Rf,Rf);
        end

    case 'realdt'   
    % Inverse 2-D Dual-Tree Discrete Wavelet Transform
        % sum and difference
        for j = 1:L
            for m = 1:3
                A = cfs{j}(:,:,m,1);
                B = cfs{j}(:,:,m,2);
                cfs{j}(:,:,m,1) = (A+B)/sqrt(2);
                cfs{j}(:,:,m,2) = (A-B)/sqrt(2);
            end
        end
        
        % Tree 1 and  Tree 2
        x = 0;
        for k = 1:2
            y = cfs{L+1}(:,:,k);
            for j = L:-1:1
                if j==1 
                    recFILT = FRf{k}; else 
                    recFILT = Rf{k}; 
                end
                y = recFB(y,cfs{j}(:,:,:,k),recFILT);
            end
            x = x+y;
        end
        x = x/sqrt(2);
        
    case 'cplxdt'  
    % Inverse 2-D Dual-Tree Complex Discrete Wavelet Transform  
        for j = 1:L
            for d = 1:3
                % These are the complex coefficients. We want to extract 
                % these first for each orientation.
                A = cfs{j}(:,:,d,1,1);
                B = cfs{j}(:,:,d,2,1);
                C = cfs{j}(:,:,d,2,2);
                D = cfs{j}(:,:,d,1,2);
                % These are in terms of filtering operations
                cfs{j}(:,:,d,1,1) = (A+B)/sqrt(2);
                cfs{j}(:,:,d,2,2) = (A-B)/sqrt(2);
                cfs{j}(:,:,d,1,2) = (C-D)/sqrt(2);
                cfs{j}(:,:,d,2,1) = (C+D)/sqrt(2);
            end
        end
        
        x = 0;
        for k = 1:2
            for n = 1:2
                y = cfs{L+1}(:,:,n,k);
                for j = L:-1:1
                    if j==1
                        recF1 = FRf{k}; recF2 = FRf{n};
                    else
                        recF1 = Rf{k};  recF2 = Rf{n};
                    end
                    y = recFB(y,cfs{j}(:,:,:,n,k),recF1,recF2);
                end
                x = x + y;
            end
        end
        
        % normalization
        x = x/2;
       
    case 'ddt'
    % Inverse 2-D Double-Density Discrete Wavelet Transform
        x = cfs{L+1};
        for j = L:-1:1
            x = recFB3(x,cfs{j},FRf,Rf);
        end
        
    case 'realdddt'
    % Inverse Real 2-D Double-Density Dual-Tree DWT
        % sum and difference
        for j = 1:L
            for m = 1:8
                A = cfs{j}(:,:,m,1);
                B = cfs{j}(:,:,m,2);
                cfs{j}(:,:,m,1) = (A+B)/sqrt(2);
                cfs{j}(:,:,m,2) = (A-B)/sqrt(2);
            end
        end
        
        % Tree 1 and 2
        x = 0;
        for k = 1:2
            y = cfs{L+1}(:,:,k);
            for j = L:-1:1
                if j==1 
                    recFILT = FRf{k}; 
                else
                    recFILT = Rf{k};
                end
                y = recFB3(y,cfs{j}(:,:,:,k),recFILT);
            end
            x = x+y;
        end
        
        % normalization
        x = x/sqrt(2);
                
    case 'cplxdddt'
        for j = 1:L
            for n = 1:2
                for m = 1:8
                    A = cfs{j}(:,:,m,n,1);
                    B = cfs{j}(:,:,m,n,2);
                    cfs{j}(:,:,m,n,1) = (A+B)/sqrt(2);
                    cfs{j}(:,:,m,n,2) = (A-B)/sqrt(2);
                end
            end
        end
        
        x = 0;
        for k = 1:2
            for n = 1:2
                Lo = cfs{L+1}(:,:,n,k);
                for j = L:-1:1
                    if j==1 
                        recF1 = FRf{k};  recF2 = FRf{n};
                    else
                        recF1 = Rf{k};   recF2 = Rf{n}; 
                    end
                    Lo = recFB3(Lo,cfs{j}(:,:,:,n,k),recF1,recF2);
                end
                x = x + Lo;
            end
        end
        
        % normalization
        x = x/2;
end



%-------------------------------------------------------------------------
function x = recFB(Lo,Hi,Rf1,Rf2)
% 2D Reconstruction Filter Bank
%
% INPUT:
%   Lo,Hi - lowpass,highpass subbands
%   Rf1 - Reconstruction filters for the columns
%   Rf2 - Reconstruction filters for the rows
% OUTPUT:
%   x - output array

if nargin < 4 ,Rf2 = Rf1; end

% filter along rows
Lo = local_REC_FB(Lo,Hi(:,:,1),Rf2,2);
Hi = local_REC_FB(Hi(:,:,2),Hi(:,:,3),Rf2,2);

% filter along columns
x = local_REC_FB(Lo,Hi,Rf1,1);
%-------------------------------------------------------------------------
function x = local_REC_FB(Lo,Hi,Rf,d)
% 2D Reconstruction Filter Bank  (along single dimension only)
% 
% Rf - Reconstruction filters
% d  - dimension of filtering

lpf = Rf(:,1);     % lowpass filter
hpf = Rf(:,2);     % highpass filter

if d == 2 , Lo = Lo'; Hi = Hi'; end

N = 2*size(Lo,1);
lf = length(Rf);
x = conv2(dyadup(Lo,0,'r'),lpf) + conv2(dyadup(Hi,0,'r'),hpf);
x(1:lf-2,:) = x(1:lf-2,:) + x(N+(1:lf-2),:);
x = x(1:N,:);
x = wshift('2d',x,[lf/2-1 0]);

if d == 2 , x = x'; end
%-------------------------------------------------------------------------
function x = recFB3(Lo,Hi,Rf1,Rf2)
% 2-D Reconstruction Filter Bank
%
% INPUT:
%     Lo - lowpass subband
%     Hi - ND array containing eight highpass subbands
%   Rf1 - Reconstruction filters for the columns
%   Rf2 - Reconstruction filters for the rows

if nargin < 4 , Rf2 = Rf1; end

% filter along rows
Lr  = Rfb3_2D_A(Lo,Hi(:,:,1),Hi(:,:,2),Rf2,2);
H1r = Rfb3_2D_A(Hi(:,:,3),Hi(:,:,4),Hi(:,:,5),Rf2,2);
H2r = Rfb3_2D_A(Hi(:,:,6),Hi(:,:,7),Hi(:,:,8),Rf2,2);

% filter along columns
x = Rfb3_2D_A(Lr,H1r,H2r,Rf1,1);
%--------------------------------------------------------------------------
function x = Rfb3_2D_A(Lo,H1,H2,Rf,d)
% 2-D Reconstruction Filter Bank (along one dimension only)
%
% INPUT:
%    Lo,H1,H2 - one lowpass and two highpass subbands
%    Rf - Reconstruction filters
%     d - dimension of filtering

Rlpf  = Rf(:,1);    % lowpass filter
Rhpf1 = Rf(:,2);    % first highpass filter
Rhpf2 = Rf(:,3);    % second highpass filter

if d == 2 
   Lo = Lo'; H1 = H1'; H2 = H2';
end

N = 2*size(Lo,1);
len = length(Rf);
x = conv2(dyadup(Lo,0,'r'),Rlpf) + conv2(dyadup(H1,0,'r'),Rhpf1) + ...
    conv2(dyadup(H2,0,'r'),Rhpf2);
x(1:len-2,:) = x(1:len-2,:) + x(N+(1:len-2),:);
x = x(1:N,:);
x = wshift('2d',x,[len/2-1 0]);

if d == 2 ,x = x'; end
%-------------------------------------------------------------------------
