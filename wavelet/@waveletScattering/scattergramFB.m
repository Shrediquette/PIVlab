function [img,freqidx,t,parentidx] = scattergramFB(S,parent,type,fb)
% This function is for internal use only. It may change or be removed in
% a future release.
%
% img = scattergramFB(SF,parent)

%   Copyright 2018-2022 The MathWorks, Inc.
if any(strcmpi(S.Properties.VariableNames,'signals'))
    sz = cellfun(@(x)size(x,2),S.signals);
    if all(sz ~=1)
        error(message('Wavelet:scattering:ndscattergram'));
    end
else
    sz = cellfun(@(x)size(x,2),S.coefficients);
    if all(sz ~=1)
        error(message('Wavelet:scattering:ndscattergram'));
    end
end
switch type
    case 'scattering'
        % For scattering, there should be just one value.
        [Npts,timeidx] = max(cellfun(@(x)size(x,1),S.signals));
        parentidx = [];
        freqidx = [];
        % We won't find the parent if there is no parent, this will be of S{1}.
        % Also for S{2}, the parent is 0
        if ~isempty(parent)
            parentidx = find(S.path(:,end-1)== parent);
            freqidx = S.path(parentidx,end);
        end
        if ~isempty(parentidx)
            coefficients = cellfun(@(x)(interpft(x,Npts)),...
                S.signals(parentidx),'UniformOutput',false);
        elseif isempty(parentidx)
            coefficients = cellfun(@(x)(interpft(x,Npts)),...
                S.signals,'UniformOutput',false);
        end
        if fb > 1 && isempty(parentidx)
            [coefficients,freqidx] = meancfs(coefficients,S.path(:,end));
        end
        t.time = 0:Npts-1;
        t.resolution = S.resolution(timeidx);
      case 'wavelet'
        [Npts,timeidx] = max(cellfun(@(x)size(x,1),S.coefficients));
        parentidx = [];
        freqidx = [];
        % We won't find the parent if there is no parent, this will be of S{1}.
        % Also for S{2}, the parent is 0
        if ~isempty(parent)
            parentidx = find(S.path(:,end-1) == parent);
            freqidx = S.path(parentidx,end);
        end
        if ~isempty(parentidx)
            coefficients = cellfun(@(x)(interpft(x,Npts)),...
                S.coefficients(parentidx),'UniformOutput',false);
        elseif isempty(parentidx)
            coefficients = cellfun(@(x)(interpft(x,Npts)),...
                S.coefficients,'UniformOutput',false);
        end
        if fb > 1 && isempty(parentidx)
            [coefficients,freqidx] = meancfs(coefficients,S.path(:,end));
        end
        t.time = 0:Npts-1;
        t.resolution = S.resolution(timeidx);
end
img = [coefficients{:}].';

%-------------------------------------------------------------------------
function [avgcfs,upath] = meancfs(cfs,path)
% Find the number of bandpass frequencies in the specified filter bank
% First we find the number of unique frequencies
upath = unique(path);
Npath = numel(upath);
avgcfs = cell(Npath,1);
for nf = 1:Npath
    tmpcfs = mean([cfs{path == upath(nf)}].');
    avgcfs{nf} = tmpcfs(:);
end








