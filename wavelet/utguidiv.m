function varargout = utguidiv(option,varargin)
%UTGUIDIV Utilities for testing inputs for different "TOOLS" files.
%   VARARGOUT = UTGUIDIV(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-May-98.
%   Last Revision 01-Nov-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

switch option
    case 'ini'
        winAttrb = [];
        optval   = varargin{1};
        switch nargin
            case 2
                if ~ischar(optval)
                    winAttrb = optval; optval = 'create';
                end
            otherwise
                if isequal(optval,'create') ,  winAttrb = varargin{2}; end
        end
        varargout = {optval,winAttrb};
        
    case 'WTB_DemoPath'
        testfile = varargin{1};
        dum = which('sumsin.mat','-all');
        pathname = fileparts(dum{1});
        pathname = which([pathname filesep testfile]);
        if ~isempty(pathname)
            ind = strfind(pathname,testfile);
            pathname = pathname(1:ind-1);
        end
        varargout{1} = pathname;       
        
    case {'test_load','test_save'}
        mask = varargin{2};
        txt  = sprintf(varargin{3});
        switch option
            case 'test_load' , [filename,pathname] = uigetfile(mask,txt);
            case 'test_save' , [filename,pathname] = uiputfile(mask,txt);
        end
        ok = 1;
        if isempty(filename) || isequal(filename,0) , ok = 0; end        
        varargout = {filename,pathname,ok};
        
    case {'load_sig','load_dem1D'}
        fig  = varargin{1};
        switch option
            case 'load_sig'
                mask = varargin{2};
                if isequal(mask,'Signal_Mask')
                    mask = {...
                        '*.mat;*.wav;*.au' , getWavMSG('Wavelet:moreMSGRF:Save_DLG_SIG_DW1D');
                        '*.*' , getWavMSG('Wavelet:moreMSGRF:Save_DLG_ALL')};
                    
                end
                txt  = varargin{3};
                [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
                
            case 'load_dem1D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        
        % default.
        %---------
        sigInfos = struct(...
            'pathname',pathname, ...
            'filename',filename, ...
            'filesize',0,  ...
            'name','',     ...
            'size',0       ...
            );
        sig_Anal = [];
        
        if ok
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitLoad'));
            [sigInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename); %#ok<ASGLU>
            sigInfos.filesize = getFileSize(fullName);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    if isequal(fileStruct(k).class,'double')
                        siz = fileStruct(k).size;
                        if min(siz)==1 && max(siz)>1
                            err = 0;
                            sigInfos.name = fileStruct(k).name;
                            break
                        end
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        sig_Anal = eval(sigInfos.name);
                    catch ME %#ok<NASGU>
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                [sig_Anal,err,msg] = load_1D_NotMAT(pathname,filename);
                if ~isempty(msg) , numMSG = msg; end
            end
            if ~err
                err = ~isreal(sig_Anal);
                if err , numMSG = 4; end
            end        
            if err ,  dispERROR_1D(fig,sigInfos.filename,numMSG); end
            ok = ~err;
        end
        if ok
            if size(sig_Anal,1)>1 , sig_Anal = sig_Anal'; end
            sigInfos.size = length(sig_Anal);        
        end
        varargout = {sigInfos,sig_Anal,ok};
        
    case {'direct_load_sig'}
        pathname = varargin{2};
        filename = varargin{3};
        [sig_Anal,err] = load_1D_NotMAT(pathname,filename);
        ok = ~err;
        varargout = {sig_Anal,ok};
        
    case {'load_img','load_dem2D'}
        fig  = varargin{1}; 
        switch option
            case 'load_img'       
                mask = varargin{2};
                txt  = varargin{3};
                [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
                
            case 'load_dem2D'
                pathname = varargin{2};
                filename = varargin{3};
                ok = 1;
        end
        default_nbcolors = varargin{4};
        if length(varargin)>4
            optIMG = varargin{5};
        else
            optIMG = 'none'; 
        end
        
        % default.
        %---------
        imgInfos = struct(...
            'pathname',pathname, ...    
            'filename',filename, ...
            'filesize',0,   ...    
            'name','',      ...
            'true_name','', ...
            'type','mat',   ...
            'self_map',0,   ...
            'size',[0 0]    ...
            );
        X = []; map = [];
        
        if ok
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitLoad'));
            [imgInfos.name,ext,fullName,fileStruct,err] = ...
                getFileINFO(pathname,filename); %#ok<ASGLU>
            imgInfos.filesize = getFileSize(fullName);
            if ~err
                err = 1;
                for k = 1:length(fileStruct)
                    [mm,idxMin] = min(fileStruct(k).size);
                    if mm>3
                        err = 0;
                        imgInfos.true_name = fileStruct(k).name;
                        break
                     
                    elseif  mm==3 && idxMin==3 && ...
                            length(fileStruct(k).size)==3
                        err = 0;
                        imgInfos.true_name = fileStruct(k).name;
                        break
                    end
                end
                if ~err
                    try
                        load(fullName,'-mat');
                        imgInfos.type = 'mat';
                        X = eval(imgInfos.true_name);
                        if ~exist('map','var')
                            map = [];
                        end
                        [X,err] = convertImage(optIMG,X,imgInfos.type,map);
                    catch ME    %#ok<NASGU>
                        err = 1; numMSG = 1;
                    end
                else
                    numMSG = 2;
                end
            else
                numMSG = 1;
                try
                    [X,map,imgFormat,~,err] = ...
                        load_2D_NotMAT(pathname,filename,optIMG);
                    if ~err
                        % The following line was suppressed the 21 Jul 2012
                        % if ~isa(X,'uint8') 
                        %     mi = min(X(:)); 
                        %     if mi<1 , X = X-mi+1; end
                        % end
                        if isempty(map) && isequal(imgFormat,'mat')
                            ma  = max(X(:));
                            map = pink(ma);
                            X   = wcodemat(X,ma);
                        end
                        [~,name,ext] = fileparts(filename);
                        imgInfos.type = imgFormat;
                        imgInfos.name = [name,ext];
                        imgInfos.true_name = 'X';
                        err = 0;
                    else
                        numMSG = 3;
                    end
                catch ME
                    numMSG = ME.message;
                end
            end
            if ~err
                err = ~isreal(X);
                if err , numMSG = 4; end
            end
            ok = ~err;
            if ~err
                imgInfos.self_map = ~isempty(map);
                if ~imgInfos.self_map
                    mi = round(min(X(:)));
                    ma = round(max(X(:)));
                    if mi<=0 , ma = ma-mi+1; end
                    ma  = min([default_nbcolors,max([2,ma])]);
                    map = pink(double(ma));
                end
                sX = size(X);
                sX(1:2) = sX([2,1]);
                imgInfos.size = sX;
            else
                dispERROR_2D(fig,imgInfos.filename,numMSG);
            end
        end
        
        varargout = {imgInfos,X,map,ok};

    case {'direct_load_img'}
        pathname = varargin{2};
        filename = varargin{3};
        if length(varargin)>3 , optIMG = varargin{4}; else optIMG = 'none'; end
        [X,map,imgFormat,colorType,err] = ...
            load_2D_NotMAT(pathname,filename,optIMG);
        varargout = {X,map,imgFormat,colorType,err};
        
    case 'load_var'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        vars = varargin{4};
        [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
        if ok
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitLoad'));
            try
                err = 0;
                load([pathname filename],'-mat');
                for k = 1:length(vars)
                    var = vars{k};
                    if ~exist(vars{k},'var') , err = 1; break; end
                end
                if err
                    msg = getWavMSG('Wavelet:moreMSGRF:VarNotFound',var);
                end
            catch ME    %#ok<NASGU>
                err = 1;
                msg = getWavMSG('Wavelet:dw1dRF:ErrFile',filename);
            end
            if err
                wwaiting('off',fig);
                errordlg(msg,getWavMSG('Wavelet:commongui:LoadERROR'),'modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
        
    case 'load_wpdec'
        fig  = varargin{1};
        mask = varargin{2};
        txt  = varargin{3};
        ord  = varargin{4};
        [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
        if ok
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitLoad'));
            fullName = fullfile(pathname,filename);
            try
                err = 0;
                load(fullName,'-mat');
                if ~exist('tree_struct','var')
                    err = 1; var = 'tree_struct';
                elseif ~exist('data_struct','var')
                    if ~isa(tree_struct,'wptree')
                        err = 1; var = 'data_struct';
                    end
                end
                if ~err
                    order = treeord(tree_struct);
                    err = ~isequal(ord,order);
                    if err
                        msg = getWavMSG('Wavelet:moreMSGRF:ErrDimDecAnal',ord);
                    end
                else
                    msg = getWavMSG('Wavelet:moreMSGRF:VarNotFound',var);
                end
            catch ME    %#ok<NASGU>
                err = 1;
                msg = getWavMSG('Wavelet:dw1dRF:ErrFile',filename);
            end
            if err
                wwaiting('off',fig);
                errordlg(msg,getWavMSG('Wavelet:commongui:LoadERROR'),'modal');
                ok = 0;
            end
        end
        varargout = {filename,pathname,ok};
        
    case 'load_comp_img'
        fig  = varargin{1}; 
        mask = varargin{2};
        txt  = varargin{3};
        [filename,pathname,ok] = utguidiv('test_load',fig,mask,txt);
        % default_nbcolors = varargin{4};

        % default.
        %---------
        imgInfos = struct(...
            'pathname',pathname,'filename',filename,  ...
            'filesize',0, ...
            'name','','true_name','','type','mat',    ...
            'self_map',0, 'size',[0 0]);
        X = []; map = [];
        if ok
            wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitLoad'));
            fullName = fullfile(pathname,filename);
            imgInfos.filesize = getFileSize(fullName);
            [PATHSTR,name,ext] = fileparts(fullName); %#ok<ASGLU>
            try
                X = wtcmngr('read',fullName);
                type = ext(2:end);
                imgInfos.type = type;
                mi = min(X(:));
                if mi<1 , X = X-mi+1; end
                if isempty(map)
                    ma  = round(double(max(X(:))));
                    map = pink(ma);
                    if ismatrix(X) , X = wcodemat(X,ma); end
                end
                imgInfos.('size') = size(X);
                imgInfos.('self_map') = map;
                imgInfos.name = [name ext];
                imgInfos.('true_name') = 'X';                
            catch ME    %#ok<NASGU>
                ok = false;
            end
        end
        varargout = {imgInfos,X,map,ok};
        
    case 'save_img'
        dlgTitle = varargin{1};
        if isempty(dlgTitle)
            dlgTitle = getWavMSG('Wavelet:moreMSGRF:SaveImage_as'); 
        end
        fig = varargin{2}; 
        X   = varargin{3};
        wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitSave'));
                
        % Get file name.
        %---------------
        [filename,pathname,FilterIndex] = uiputfile( ...
            {'*.mat','MAT-files (*.mat)';'*.mat','MAT-files [Colored Image] (*.mat)'; ...
            '*.jpg','Joint Photographic Experts Group files (*.jpg)'; ...
            '*.pcx','Windows Paintbrush files (*.pcx)'; ...
            '*.tif','Tagged Image File Format files (*.tif)'; ...
            '*.bmp','Windows Bitmap files (*.bmp)'; ...
            '*.hdf','Hierarchical Data Format files (*.hdf)'; ...
            '*.png','Portable Network Graphics  (*.png)'; ...
            '*.pbm','Portable Bitmap filees (*.pbm)'; ...
            '*.pgm','Portable Graymap files (*.pgm)'; ...
            '*.ppm','Portable Pixmap files (*.ppm)'; ...
            '*.ras','Sun Raster files (*.ras)'; ...
            '*.xwd','X Window Dump (*.xwd)'; ...
            '*.*',  'All Files (*.*)'}, ...
            dlgTitle, 'Untitled.mat');
        OKsave = ~(isempty(filename) || isequal(filename,0));
        if FilterIndex==2
            
        end
        if OKsave
            BW_Flag = ismatrix(X);
            if BW_Flag
                default_nbcolors = 255;
                map = cbcolmap('get',fig,'self_pal');
                if isempty(map)
                    mi = round(min(X(:)));
                    ma = round(max(X(:)));
                    if mi<=0 , ma = ma-mi+1; end
                    ma  = min([default_nbcolors,max([2,ma])]);
                    map = pink(double(ma));
                end
                varCell_to_Save = {'X','map'};
            else
                X = uint8(X);
                varCell_to_Save = {'X'};
            end
            
            % Saving file.
            %--------------
            [name,ext] = strtok(filename,'.');
            if isempty(ext) || isequal(ext,'.')
                ext = '.mat'; filename = [name ext];
            end
            try
                if isequal(ext,'.mat')
                    nbIN = length(varargin);
                    if nbIN>3
                        for k = 4:2:nbIN
                            numstr = int2str(k+1);
                            eval([varargin{k} ' =  varargin{' numstr '};']);
                            varCell_to_Save = ...
                                [varCell_to_Save,varargin{k}]; %#ok<AGROW>
                        end
                    end
                    save([pathname filename],varCell_to_Save{:});
                else
                    if exist('map','var')
                        imwrite(X,map,[pathname,filename],ext(2:end));
                    else
                        imwrite(X,[pathname,filename],ext(2:end));
                    end
                end
            catch ME	%#ok<NASGU>
                OKsave = false;
                errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
            end
        end
        varargout = {OKsave,pathname,filename};
        wwaiting('off',fig);
end


%--------------------------------------------------------------------------
function [name,ext,fullName,fileStruct,err] = getFileINFO(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.');
if ~isempty(ext) , ext = ext(2:end); end
try
    [fileStruct,err] = wfileinf(fullName);
catch ME    %#ok<NASGU>
    err = 1; fileStruct = [];
end
%--------------------------------------------------------------------------
function dispERROR_1D(fig,filename,numMSG)

if isnumeric(numMSG)
    switch numMSG
        case 1 , strMSG = getWavMSG('Wavelet:dw1dRF:ErrFile',filename);
        case 2 , strMSG = getWavMSG('Wavelet:moreMSGRF:Load_MSG_SIG',filename);
        case 3 , strMSG = getWavMSG('Wavelet:commongui:ErrLoadFile_2',filename);
        case 4 , strMSG = getWavMSG('Wavelet:commongui:ErrLoadFile_4',filename);
    end
    if numMSG>1
        msg = {sprintf(strMSG,filename) , ' '};
    else
        msg = sprintf(strMSG,filename);
    end
else
    msg = numMSG;
end
wwaiting('off',fig);
errordlg(msg,getWavMSG('Wavelet:dw1dRF:LoadSigErr'),'modal');
%--------------------------------------------------------------------------
function dispERROR_2D(fig,filename,numMSG)

if isnumeric(numMSG)
    switch numMSG
        case 1 , msg = getWavMSG('Wavelet:commongui:ErrLoadFile_2',filename);
        case 2 , msg = getWavMSG('Wavelet:moreMSGRF:Load_MSG_IMG',filename);
        case 3 , msg = getWavMSG('Wavelet:moreMSGRF:Load_MSG_Ind_IMG',filename);
        case 4 , msg = getWavMSG('Wavelet:commongui:ErrLoadFile_4',filename);
    end
    msg = {sprintf(msg,filename) , ' '};
else
    msg = numMSG;
end
wwaiting('off',fig);
errordlg(msg,getWavMSG('Wavelet:moreMSGRF:Load_IMG_ERR'),'modal');
%--------------------------------------------------------------------------
function [sig,err,msg] = load_1D_NotMAT(pathname,filename)

fullName = fullfile(pathname,filename);
[name,ext] = strtok(filename,'.'); %#ok<ASGLU>
if ~isempty(ext) , ext = ext(2:end); end
sig = []; err = 1; msg = '';
switch lower(ext)
case {'wav', 'flac','mp3','m4a','mp4','ogg','au'}
    try 
        sig = audioread(fullName); 
        err = 0;
    catch ME
        msg = ME.message; 
    end
end
if ~err && size(sig,1)>1 , sig = sig'; end          
%--------------------------------------------------------------------------
function [X,map,imgFormat,colorType,err] = ...
    load_2D_NotMAT(pathname,filename,optIMG)

[name,ext,fullName] = getFileINFO(pathname,filename); %#ok<ASGLU>
imgFileType = getimgfiletype('Cell');
switch ext
    case imgFileType
        info = imfinfo(fullName,ext);
    otherwise
        info = imfinfo(fullName);
end
if length(info)>1 , info = info(1); end
imgFormat = info.Format;
colorType = lower(info.ColorType);

[X,map] = imread(fullName,ext);
[X,err] = convertImage(optIMG,X,colorType,map);
%--------------------------------------------------------------------------
function [X,err] = convertImage(optIMG,X,colorType,map)

conv2BW = wtbxmngr('get','IndexedImageOnly');
QuestionToConvert = true;

% For Automatic demos
%--------------------
ST = dbstack; 
CST = struct2cell(ST);
CST = CST(2,:);
if isempty(optIMG)
    optIMG = 'BW';
elseif any(strcmp('dguidw2d',CST)) 
    optIMG = 'FORCE';
end

switch optIMG
    case 'mdwt2' , X = double(X); err = 0; return;
        
    case {'BW','forceBW'}
        QuestionToConvert = false;
        if (length(size(X))<3)
            err = 0;
            X = double(X);
            return;
        end
        conv2BW = true;

    case {'COL','forceCOL'}
        QuestionToConvert = false;

    case {'FORCE'}
        QuestionToConvert = false;
        conv2BW = true;
end

err = 0;
if QuestionToConvert
    ColorIMG = any(strcmp({'rgb','truecolor','mat'},colorType)) | ...
                (~isempty(map) && ~isequal(map(:,1),map(:,2)));
    if ~conv2BW && ColorIMG
        switch colorType
            case {'rgb','truecolor'}
                quest = getWavMSG('Wavelet:moreMSGRF:Load_RGB_IMG');
            case {'mat','indexed'}
                quest = getWavMSG('Wavelet:moreMSGRF:Load_IND_IMG');
        end
        Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
        Str_No =  getWavMSG('Wavelet:commongui:Str_No');
        Answer_Quest = questdlg(quest, ...
            getWavMSG('Wavelet:moreMSGRF:Loading_Image'),Str_Yes,Str_No,Str_Yes);
        if strcmpi(Answer_Quest,Str_No) , conv2BW = true; end
    end
else
    ColorIMG = false;
end

if conv2BW
    try
        X = double(round(0.299*X(:,:,1) + 0.587*X(:,:,2) + 0.114*X(:,:,3)));
    catch ME %#ok<NASGU>
        switch colorType
            case {'indexed','grayscale','mat'}
            otherwise , err = 1;
        end        
    end
else
    if length(size(X))<3
        convFLAG = true;
        if  (isequal(class(X),'uint8') || isequal(class(X),'logical')) ...
             && ~isequal(optIMG,'COL') && ~ColorIMG
            X = double(X);
            convFLAG = false;
        end
        
        nbCOL = size(map,1);
        % The following line was suppressed the 21 Jul 2012
        % if min(X(:))<1 || nbCOL>255, X = X + 1; end  

        % The grayscale images are converted in true color images.
        if convFLAG
        % The following line was added the 26 Oct 2012
            if min(X(:))<1 || nbCOL>255, X = X + 1; end              
            maxX = max(X(:));
            if nbCOL==0
                map = pink(maxX);
            elseif nbCOL<maxX
                map = [map ; map(nbCOL*ones(1,maxX-nbCOL),:)];
            end
            IMAP = 256*map;
            Z = cell(1,3);
            for k = 1:3
                tmp = zeros(size(X));
                tmp(:) = IMAP(X(:),k);
                Z{k} = tmp;
            end
            X = uint8(cat(3,Z{:}));
        end
    end
end
%--------------------------------------------------------------------------
function filesize = getFileSize(fullName)

fid  = fopen(fullName);
[dummy,filesize] = fread(fid); %#ok<ASGLU>
fclose(fid);
%--------------------------------------------------------------------------
