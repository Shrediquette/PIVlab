function varargout = wtbxmngr(option,varargin)
%WTBXMNGR Wavelet Toolbox manager.
%   WTBXMNGR or WTBXMNGR('version') displays the current
%   version of the Toolbox mode.
%
%   WTBXMNGR('LargeFonts') sets the size of the next created
%   figures in such a way that they can accept Large Fonts.
%
%   WTBXMNGR('DefaultSize') restores the default figure size
%   for the next created figures.
%
%   WTBXMNGR('FigRatio',ratio) changes the size of the next
%   created figures multiplying the default size by "ratio",
%   with 0.75 <= ratio <= 1.25.
%
%   WTBXMNGR('FigRatio') returns the current ratio value.

% INTERNAL OPTIONS:
%-----------------
%   OPTION = 'ini' , 'is_on' , 'get' , 'clear'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Feb-98.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==0 , option = 'version'; end

DWT_Attribute  = getappdata(0,'DWT_Attribute');
WTBX_Glob_Info = getappdata(0,'WTBX_Glob_Info');
Wavelets_Info  = getappdata(0,'Wavelets_Info');

%----------------------%
% Wavelets Structures. %
%------------------------------------------%
% WTBX_Glob_Info is a structure.
% WTBX_Glob_Info = ...
%   struct(...
%     'name'                 char = 'WTBX'
%     'version'              integer
%     'objVersion'           integer
%     'IndexedImageOnly'     boolean = false
%     'ResizeRatioWTBX_Fig'  real = 1.0
%     );
%------------------------------------------%
% Wavelets_Info is a  structure array
% with size = [nb_fam 1]
%
% Wavelet_Struct =
%   struct(...
%     'index'           integer
%     'familyName'      string
%     'familyShortName' string
%     'type'            integer
%     'tabNums'         matrix of string
%     'typNums'         string
%     'file'            string
%     'bounds'          string
%     );
%------------------------------------------%
% DWT_Attribute is a structure.
%   struct(...
%     'extMode'   'sym' , 'zpd' , 'spd' ...
%     'shift1D'   integer
%     'shift2D'   [integer integer]
%     );
%------------------------------------------%
% Def_WGlob_Struct is a  structure  which
% contains "pseudo" Global Variables for
% the Wavelet Toolbox (see MEXTGLOB).
%------------------------------------------%
okInit = ...
    ~isempty(WTBX_Glob_Info) && ...
    ~isempty(Wavelets_Info)  && ...
    ~isempty(DWT_Attribute);

switch lower(option)
    case 'ini'
        if okInit , return; end
        tblx = ver('wavelet');
        if isempty(WTBX_Glob_Info)
            WTBX_Glob_Info.name       = 'WTBX';
            WTBX_Glob_Info.version    = char(tblx(1).Version);
            WTBX_Glob_Info.objVersion = 1;
            WTBX_Glob_Info.IndexedImageOnly = false;
            WTBX_Glob_Info.ResizeRatioWTBX_Fig = 1;
            setappdata(0,'WTBX_Glob_Info',WTBX_Glob_Info);
        end
        Wavelets_Info = wavemngr('load');
        if isempty(getappdata(0,'DWT_Attribute'))
            DWT_Attribute = dwtmode('load');
        end
        if nargout>0
            varargout = {WTBX_Glob_Info,Wavelets_Info,DWT_Attribute};
        end
        
    case 'is_on'
        varargout{1} = okInit;
        
    case 'get'
        if ~okInit , WTBX_Glob_Info = wtbxmngr('ini'); end
        nbout   = nargout;
        nbin    = nargin-1;
        for k=1:min([nbin,nbout])
            switch varargin{k}
                case 'AppName'
                    varargout{k} = [WTBX_Glob_Info.name '_V' ...
                        WTBX_Glob_Info.version];     %#ok<*AGROW>
                case 'name'       , varargout{k} = WTBX_Glob_Info.name;
                case 'version'    , varargout{k} = WTBX_Glob_Info.version;
                case 'objVersion' 
                    okObj = ~isempty(what('@wptree'));
                    varargout{k} = WTBX_Glob_Info.objVersion & okObj;
                case 'IndexedImageOnly'
                    varargout{k} = WTBX_Glob_Info.IndexedImageOnly;
                case 'ResizeRatioWTBX_Fig'
                    varargout{k} = WTBX_Glob_Info.ResizeRatioWTBX_Fig;
                case 'wavelets'   , varargout{k} = Wavelets_Info;
                case 'dwtAttrb'   , varargout{k} = DWT_Attribute;
            end
        end
        
    case 'truecolor' , WTBX_Glob_Info.IndexedImageOnly = false;
        
    case 'version'
        nameVers = wtbxmngr('get','version');
        nameVers = ['V' nameVers];
        if nargin<2
            dispMessage(nameVers);
        end
        if nargout>0 , varargout{1} = nameVers; end
        
    case {'largefonts','defaultsize'}
        if isequal(lower(option),'largefonts')
            CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
            StdScrPixPerInch = 96;
            RatScrPixPerInch = CurScrPixPerInch / StdScrPixPerInch;
        else
            RatScrPixPerInch = 1;
        end
        wtbxmngr('figratio',RatScrPixPerInch);
        
    case 'figratio'
        current_FigRATIO = wtbxmngr('get','ResizeRatioWTBX_Fig');
        if isempty(varargin)
            varargout{1} = current_FigRATIO;
            return;
        end
        ResizeRatioWTBX_Fig = varargin{1};
        if isempty(ResizeRatioWTBX_Fig) , ResizeRatioWTBX_Fig = 1; end
        dispMSG = 0;  % No display for correct value
        OK = length(ResizeRatioWTBX_Fig)==1 && isnumeric(ResizeRatioWTBX_Fig) && ...
            isreal(ResizeRatioWTBX_Fig);
        if OK
            if     ResizeRatioWTBX_Fig<0.75 , ResizeRatioWTBX_Fig = 0.75; dispMSG = 1;
            elseif ResizeRatioWTBX_Fig>1.25 , ResizeRatioWTBX_Fig = 1.25; dispMSG = 2;
            end
        else
            dispMSG = 3;
            ResizeRatioWTBX_Fig = current_FigRATIO;
        end
        WTBX_Glob_Info = getappdata(0,'WTBX_Glob_Info');
        WTBX_Glob_Info.ResizeRatioWTBX_Fig = ResizeRatioWTBX_Fig;
        setappdata(0,'WTBX_Glob_Info',WTBX_Glob_Info);
        if dispMSG>0
            msg = {...
                getWavMSG('Wavelet:moreMSGRF:Invalid_Fig_Ratio'), ...
                getWavMSG('Wavelet:moreMSGRF:Choose_Fig_Ratio'), ...
                getWavMSG('Wavelet:moreMSGRF:Current_Fig_Ratio', ...
                num2str(ResizeRatioWTBX_Fig))};
            warndlg(msg)
        elseif dispMSG==0
            ST = dbstack;
            if length(ST)<2
                msg = getWavMSG('Wavelet:moreMSGRF:MSG_Fig_Ratio', ...
                    num2str(ResizeRatioWTBX_Fig));
                msgbox(msg)
            end
        end
        
    case 'clear'
        if isappdata(0,'WTBX_Glob_Info') , rmappdata(0,'WTBX_Glob_Info'); end
        wavemngr('clear');
        mextglob('clear');
end


%-------------------------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------------------------%
function dispMessage(wtbxVers)

% Display Extension Mode.
msg = getWavMSG('Wavelet:moreMSGRF:WTBX_Version',wtbxVers);

switch wtbxVers
    case {'v1','V1','v2','V2','v3','V3'}
        msg = getWavMSG('Wavelet:moreMSGRF:Obsolete_WTBX_Version');
end
sizeMSG = size(msg);
nbLINES = sizeMSG(1);
lenMSG  = sizeMSG(2);
n = lenMSG+8;
b = '  ';
c = '*';
s = c(ones(1,n));
c  = c(ones(1,nbLINES),:); b  = b(ones(1,nbLINES),:);
msg1 = char(' ',s,[c c b msg b c c],s,' ');
clc;
disp(msg1);
%-------------------------------------------------------------------------%
