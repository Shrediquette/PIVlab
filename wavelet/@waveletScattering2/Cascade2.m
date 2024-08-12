function [U_phi,U_psi] = Cascade2(U,phift,psift,filtparams,type,OSFactor,optpath)
% U{nwt+1},numrot,filters,filterparams{nwt+1},type,OSFactor
% This function is for internal use only. It may change or be removed in
% a future release.

%   Copyright 2018-2020 The MathWorks, Inc.

U_phi = struct('coefficients',[],'meta',[]);
U_psi = struct('coefficients',[],'meta',[]);
phi.images = {};
psi.images = {};
phi.meta.resolution = [];
phi.meta.bandwidth = [];
phi.meta.path = U.meta.path;
psi.meta.resolution = [];
psi.meta.bandwidth = [];
psi.meta.path = [];
psi.meta.psi3db = [];
psi.coefficients = {[]};
startidx = 1;

for kk = 1:length(U.coefficients)
    % Determine which wavelet filters are used in scattering transform
    validwav = waveletScattering2.frequencyoverlap(U.meta.resolution(kk),filtparams);
    
    if U.meta.path(end,kk) ~= 0 && optpath
        validwav = waveletScattering2.optimizePath(validwav,U.meta.psi3db(kk),filtparams);
    end
    [phicoefs,psicoefs,phi_meta,psi_meta] = ...
        waveletScattering2.wavelet2D(U.coefficients{kk},...
        U.meta.resolution(kk),phift,psift,filtparams,validwav,U.meta.path(:,kk),type,OSFactor);
    phi.coefficients{kk} = phicoefs;
    phi.meta.resolution = [phi.meta.resolution  phi_meta.resolution];
    phi.meta.bandwidth = [phi.meta.bandwidth  phi_meta.bandwidth];
    if ~isempty(validwav)
        
        psi.coefficients(startidx:startidx+numel(validwav)-1) = psicoefs;
        psi.meta.resolution = [psi.meta.resolution  psi_meta.resolution];
        psi.meta.bandwidth = [psi.meta.bandwidth  psi_meta.bandwidth];
        psi.meta.path = [psi.meta.path  psi_meta.path];
        psi.meta.psi3db = [psi.meta.psi3db  psi_meta.psi3db];
        startidx = startidx+numel(validwav);
    end   
    
   
    
end

if ~isempty(psi.coefficients)
    U_psi.coefficients = psi.coefficients;
    U_psi.meta = psi.meta;
    U_psi.meta.OSFactor = U.meta.OSFactor;
%     U_psi.meta.dsfilter = psi.meta.dsfilter;
    U_phi.coefficients = phi.coefficients;
    U_phi.meta = phi.meta;
end




