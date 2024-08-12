function varargout = dddtreecfs(option,dt,varargin)
%DDDTREECFS Extract or reconstruct dual-tree coefficients.
%   OUT = DDDTREECFS(OPTION,DT,OUTPUTSPEC,OUTPUTINDICES, ...) reconstructs
%   or extracts coefficients from the tree DT. 
%   If OPTION is equal to 'r' reconstructions are done else,
%   if OPTION is equal to 'e' extractions are done.
%
%   Valid options for OUTPUTSPEC are:
%       'lowpass' , 'scale' , 'ind' , 'cumind'
%
%   The data type of OUT depends on the specified value of OUTPUTSPEC.
%
%   When OUTPUTSPEC is equal to 'lowpass', OUTPUTINDICES is not allowed. If
%   OPTION is equal to 'r', OUT is a signal or an image of the same size as
%   the original input to DDDTREE or DDDTREE2. OUT is reconstructed from
%   the scaling (lowpass) coefficients.
%
%   If OPTION is equal to 'e', OUT is a structure array with the same
%   fields as DT. All coefficients arrays are filled with zeros except for
%   the scaling coefficients.
%
%   When OUTPUTSPEC is equal to 'scale', OUTPUTINDICES is a cell array of
%   positive scalars which are the indices of extracted or reconstructed
%   cells in DT.cfs. 
%
%   If OPTION is equal to 'r', OUT is a cell array equal in length to the
%   number of elements in OUTPUTINDICES. The elements of OUT are signals or
%   images of the same size as the original input to DDDTREE or DDDTREE2.
%
%   If OPTION is equal to 'e', OUT is a cell array containing
%   NUMEL(OUTPUTINDICES) structure arrays with the same fields as DT.
%
%   When OUTPUTSPEC is equal to 'ind' or 'cumind', OUTPUTINDICES must be
%   a cell array of row vectors representing node positions in
%   the tree.
%
%   For each vector, the first component gives the index of
%   the node (the index of the cell in the cell array DT.cfs).
%   The remaining part of the vector gives the indices
%   in the N-D array contained in the cell.
%
%   When OUTPUTSPEC is 'ind', OUT is a cell array of signals or images, the
%   sizes of which depend on OPTION ('r' or 'e'). When OUTPUTSPEC is
%   'cumind' and OPTION equals 'r', OUT is a signal or an image of the same
%   size as the original input to DDDTREE or DDDTREE2.
%
%   if OPTION = 'e', OUT is cell array of structure arrays with the same
%   fields as DT.
%
%   OUT = DDDTREECFS(...,'plot') plots the selected coefficients or
%   reconstructions. The 'plot' argument may be in any position after DT
%   input.
%
%   See DDDTREE or DDDTREE2 for more information on tree components.
%
%   Examples 1:
%   % For a one-dimensional signal of length 1x1024, analyzed at scale 4,
%   % depending on tree type, the analysis coefficients are distributed
%   % as follows:
%   % 'dwt'      {[1 512]     ... [1 64]      [1 64]}
%   % 'cplxdt'   {[1 512 2]   ... [1 64 2]    [1 64 2]}
%   % 'ddt'      {[1 512 2]   ... [1 64 2]    [1 64]}
%   % 'cplxdddt' {[1 512 2 2] ... [1 64 2 2]  [1 64 2]}
%
%          % For a 'cplxdt' dual-tree dt:
%          [~,sig] = wnoise('doppler',10,4);
%          dt = dddtree('cplxdt',sig,4,'dtf1');
%
%          XR = dddtreecfs('r',dt,'plot','ind',{[1 1];[5 2];[3 1];[4 2]});
%          % XR is a cell array of four signals with 1024 samples.
%
%          XR = dddtreecfs('e',dt,'plot','ind',{[1 1];[5 2];[3 1];[4 2]});
%          % XR is a cell array of 4 signals with respective length:
%          % 512, 64, 128,64.
%
%          % In both cases, the node [5 2] corresponds to the lowpass
%          % component.
%
%          % Using 'cumind' instead of 'ind', XR is a signal of length 1024
%          % in the first case, and a 'cplxdt' dual-tree in the second one
%          XR = dddtreecfs('r',dt,'plot','cumind',{[1 1];[5 2];[3 1];[4 2]});
%          XR = dddtreecfs('e',dt,'plot','cumind',{[1 1];[5 2];[3 1];[4 2]});
%
%   Examples 2:
%   % For a two-dimensional image of size 256x256, analyzed at level 2,
%   % depending on tree type, the analysis coefficients are distributed
%   % as follows:
%   % 'dwt'       {[128 128 3]      [64 64 3]      [64 64]}
%   % 'realdt'    {[128 128 3 2]    [64 64 3 2]    [64 64 2]}
%   % 'cplxdt'    {[128 128 3 2 2]  [64 64 3 2 2]  [64 64 2 2]}
%   % 'realdddt'  {[128 128 8 2]    [64 64 8 2]    [64 64 2]}
%   % 'cplxdddt'  {[128 128 8 2 2]  [64 64 8 2 2]  [64 64 2 2]}
%   % 'ddt'       {[128 128 8]      [64 64 8]      [64 64]}
%
%         % For a 'cplxdddt' dual-tree dt:
%         load mask
%         dt = dddtree2('cplxdddt',X,2, 'dddtf1');
%
%         XR = dddtreecfs('r',dt,'plot','scale',{1;3});
%         % XR is a cell array of 2 (256x256) images.
%         % The second one contains the low frequencies.
%
%         XR = dddtreecfs('e',dt,'plot','scale',{1;3});
%         % XR is a cell array of 2 'cplxdddt' dual-tree.
%
%         XR = dddtreecfs('r',dt,'plot','ind', ...
%                       {[3 1 1];[3 2 1];[3 1 2];[3 2 2]});
%         XR = dddtreecfs('e',dt,'plot','ind', ...
%                       {[3 1 1];[3 2 1];[3 1 2];[3 2 2]});
%         % XR is returns a cell array of 4 images. If OPT ='r'
%         % the sizes are 256x256, if OPT ='e' the sizes are 64x64.
%         % In both cases, 4 lowpass components are obtained.
%
%   See also DDDTREE, DDDTREE2, IDDDTREE, IDDDTREE2, PLOTDT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Feb-2013.
%   Last Revision: 22-Apr-2013.
%   Copyright 1995-2020 The MathWorks, Inc.


% Check inputs.
validateattributes(dt,{'struct'},{'nonempty'},'DDDTREECFS','DT');
validateattributes(option,{'string','char'},{'nonempty'},'DDDTREECFS','OPTION');


if nargin > 0
    option = convertStringsToChars(option);
    option = validatestring(option,{'e','r'},'DDDTREECFS','OPTION');
end

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end



nbIN = length(varargin);
option = lower(option(1));
flag_PLOT = false;
optRec = '';
idxNode = [];
if nbIN>0
    k = 1;
    while k<=nbIN
        if ischar(varargin{k})
            ArgNAM = lower(varargin{k});
        else
            error(message('Wavelet:FunctionArgVal:Invalid_Input'));
        end
        if k<nbIN
            ArgVAL = varargin{k+1};
            if ischar(ArgVAL) 
                lower(ArgVAL);
            end
        end
        k = k+2;
        switch ArgNAM
            case 'plot'    
                k = k-1; 
                flag_PLOT = true;
            case 'ind'     
                optRec = ArgNAM; 
                idxNode = ArgVAL;
            case 'cumind'  
                optRec = ArgNAM; 
                idxNode = ArgVAL;
            case 'scale'   
                optRec = ArgNAM; 
                idxNode = ArgVAL;
            case 'lowpass' 
                optRec = ArgNAM; 
                if any(cell2mat(cellfun(@(x)iscell(x),varargin,'uni',false)))
                    error(message('Wavelet:FunctionInput:OutputIndicesLowPass'));
                end
                k = k-1;
                
            otherwise
                error(message('Wavelet:FunctionArgVal:Invalid_Input'));
        end
    end
end
flag2D = any(strcmp(fieldnames(dt),'sizes'));

nbR = 1;
if ~isempty(idxNode)
    
    nbR = length(idxNode);
    len = zeros(1,nbR);
    for k = 1:nbR , len(k) = length(idxNode{k}); end
    switch optRec
        case 'ind'
            checkOutputIndices(optRec,idxNode,dt.level,cellfun(@size,dt.cfs,'uni',false));
            XR = cell(1,nbR);
            for k = 1:nbR
                dt_TMP = zerocfsdt(dt);
                idx = idxNode{k};
                num = idx(1);
                idx(1) = [];
                if isempty(idx) , idx(1) = 1; end
                idx = num2cell(idx);
                dt_TMP.cfs{num}(:,:,idx{:}) = dt.cfs{num}(:,:,idx{:});
                switch option
                    case 'r'
                        if ~flag2D
                            XR{k} = idddtree(dt_TMP);
                        else
                            XR{k} = idddtree2(dt_TMP);
                        end
                    case 'e'
                        if ~isempty(idx)
                            XR{k} = dt.cfs{num}(:,:,idx{:});
                        else
                            XR{k} = dt.cfs{num};
                        end
                end
            end
            
        case 'cumind'
            checkOutputIndices(optRec,idxNode,dt.level,cellfun(@size,dt.cfs,'uni',false));
            dt_TMP = zerocfsdt(dt);
            for k = 1:nbR
                idx = idxNode{k};
                num = idx(1);
                idx(1) = [];
                if isempty(idx) 
                    idx(1) = 1;
                end
                idx = num2cell(idx);
                dt_TMP.cfs{num}(:,:,idx{:}) = dt.cfs{num}(:,:,idx{:});
            end
            switch option
                case 'r'
                    if ~flag2D
                        XR = idddtree(dt_TMP);
                    else
                        XR = idddtree2(dt_TMP);
                    end
                case 'e'
                    XR = dt_TMP;
            end
            
        case 'scale'
            checkOutputIndices(optRec,idxNode,dt.level,cellfun(@size,dt.cfs,'uni',false));
            for k = 1:nbR
                dt_TMP = zerocfsdt(dt);
                num = idxNode{k};
                dt_TMP.cfs{num} = dt.cfs{num};
                switch option
                    case 'r'
                        if ~flag2D
                            XR{k} = idddtree(dt_TMP);
                        else
                            XR{k} = idddtree2(dt_TMP);
                        end
                    case 'e'
                        XR{k} = dt_TMP;
                end
            end
    end
    
elseif isequal(optRec,'lowpass')
    
    Depth = dt.level;
    dt_TMP = zerocfsdt(dt);
    dt_TMP.cfs{Depth+1} = dt.cfs{Depth+1};
    switch option
        case 'r'
            if ~flag2D
                XR = idddtree(dt_TMP);
            else
                XR = idddtree2(dt_TMP);
            end
        case 'e'
            XR = dt_TMP;
    end
    
else
    optRec = '';
    if ~flag2D 
        XR = idddtree(dt); 
    else
        XR = idddtree2(dt);
    end
end

if nargout>0 , varargout{1} = XR; end


if flag_PLOT
    typeTree = dt.type;
    % NS = getWavMSG('Wavelet:dualtree:Type_of_Tree',upper(typeTree));
    NS = upper(typeTree);
    if ~flag2D   % One dimensional dual-tree
        if ~isempty(idxNode) && isequal(optRec,'ind')
            figure('Name',NS,'Color','w');
            for k = 1:nbR
                subplot(nbR,1,k); plot(XR{k},'r'); axis tight
                num_STR = int2str(cat(2,idxNode{k,:}));
                num_STR(num_STR==' ') = '';
                xlabel(['C_{' num_STR '}'])
            end
        else
            if isstruct(XR)
                plotdt(XR)
            else
                if ~isempty(idxNode)
                    TS = [];
                    for k = 1:nbR
                        TS = [TS , '[' int2str(idxNode{k,:}) '] , '];  %#ok<*AGROW>
                    end
                    TS(end-2:end) = '';
                    TS = getWavMSG('Wavelet:dualtree:Nodes_Of_Tree',TS);
                else
                    TS = '';
                end
                flagFIG = false;
                if iscell(XR)
                    if isstruct(XR{1})
                        plotdt(XR{1})
                    else
                        XR = XR{1};
                        flagFIG = true;
                    end
                else
                    flagFIG = true;
                end
                if flagFIG
                    figure('Name',NS,'Color','w');
                    plot(XR,'r');
                    if ~isequal(optRec,'lowpass')
                        xlab = getWavMSG('Wavelet:dualtree:Recons_signal');
                    else
                        xlab = getWavMSG('Wavelet:dualtree:Recons_signal_LOW');
                    end
                    xlabel(xlab)
                    title(TS);
                    axis tight;
                end
                
            end
        end
    else
        if ~isequal(typeTree,'dwt')
            ROW = floor(sqrt(nbR));
            COL = ceil(sqrt(nbR));
            if ROW*COL<nbR , ROW = ROW + 1; end
        else
            if nbR>2
                COL = 3; ROW = ceil(nbR/3);
            else
                COL = nbR; ROW = 1;
            end
        end
        if ~isempty(idxNode)
            if iscell(XR)
                nbR = length(XR);
                if isstruct(XR{1})
                    for k = 1:nbR 
                        plotdt(XR{k}); 
                    end
                else
                    figure('Name',NS,'Color','w','Units','normalized',...
                        'Position',[0.3 0.3 0.5 0.6],'Colormap',gray(220));
                    for k = 1:nbR
                        subplot(ROW,COL,k);
                        if iscell(XR) 
                            imagesc(XR{k}); 
                        else
                            imagesc(XR);
                        end
                        axis tight
                        num_STR = int2str(cat(2,idxNode{k,:}));
                        num_STR(num_STR==' ') = '';
                        xlabel(['C_{' num_STR '}'])
                    end
                end
            elseif isstruct(XR)
                plotdt(XR)
            else
                figure('Name',NS,'Color','w','Units','normalized',...
                    'Position',[0.3 0.3 0.5 0.6],'Colormap',gray(220));
                for k = 1:nbR
                    subplot(ROW,COL,k);
                    if iscell(XR) 
                        imagesc(XR{k}); 
                    else
                        imagesc(XR); 
                    end
                    axis tight
                    num_STR = int2str(cat(2,idxNode{k,:}));
                    num_STR(num_STR==' ') = '';
                    xlabel(['C_{' num_STR '}'])
                end
            end
        else
            if isstruct(XR)
                plotdt(XR)
            else
                if ~isempty(idxNode)
                    TS = [];
                    for k = 1:nbR
                        TS = [TS , '[' int2str(idxNode{k,:}) '] , '];  %#ok<*AGROW>
                    end
                    TS(end-2:end) = '';
                    TS = getWavMSG('Wavelet:dualtree:Nodes_Of_Tree',TS);
                else
                    TS = '';
                end
                figure('Name',NS,'Color','w','Units','normalized', ...
                    'Position',[0.3 0.3 0.5 0.6],'Colormap',gray(220));
                imagesc(XR); axis tight;
                if ~isequal(optRec,'lowpass')
                    xlab = getWavMSG('Wavelet:dualtree:Recons_image');
                else
                    xlab = getWavMSG('Wavelet:dualtree:Recons_image_LOW');
                end
                xlabel(xlab)
                title(TS);
            end
        end
    end
end

%--------------------------------------------------------------------------
function dtOut = zerocfsdt(dt)

dtOut = dt;
for k = 1:1+dt.level
    dtOut.cfs{k} = zeros(size(dt.cfs{k}));
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function checkOutputIndices(type,values,level,cfsSizes)

validateattributes(values,{'cell'},{'nonempty'},'DDDTREECFS','OUTPUTINDICES');
TFempty = cellfun(@(x)isempty(x),values);
TFfinite = cell2mat(cellfun(@(x)all(isfinite(x)),values,'uni',false));
if strcmpi(type,'scale')
    TFrow = cellfun(@(x)isscalar(x),values);
    % Cover 'ind' and 'cumind' cases
else
    TFrow = cellfun(@(x)isrow(x),values);
end
if any(TFempty) || ~all(TFfinite) || ~all(TFrow)
    error(message('Wavelet:FunctionInput:OutputIndicesInvalid'));
end
% Check all the "level" values in the cell array
LevElem = cellfun(@(x)x(1),values);
% Extract indices for coefficient vectors or matrices, for 'scale', these
% should be empty
cfsElems = cellfun(@(x)x(2:end),values,'uni',false);
% Make sure the level index is correct. They are including the lowpass
% filter as the level+1 index.
% Same as numel(dt.cfs)
InBounds = LevElem <= level+1;
if ~all(InBounds)
    error(message('Wavelet:FunctionInput:OutputIndicesLevRange',level+1));
end
% Remove data dimensions
if ~strcmpi(type,'scale')
    for kk = 1:numel(LevElem)
       sztmp = cfsSizes{LevElem(kk)};
       % First two elements are image size or vector size
       sztmp(1:2) = [];
       cfstmp = cfsElems{kk};
       if prod(cfstmp) > prod(sztmp)
           error(message('Wavelet:FunctionInput:OutputIndicesCFSRange',prod(cfstmp),prod(sztmp)));
       end
       
    end
end







