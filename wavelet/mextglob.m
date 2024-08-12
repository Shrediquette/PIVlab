function varargout = mextglob(option,varargin)
%MEXTGLOB Module of extended objects globals.
%   VARARGOUT = MEXTGLOB(OPTION,VARARGIN)
%
%   OPTION : 'ini' , 'pref' , 'clear'
%            'get' , 'set'  , 'is_on'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.17.4.14 $

Def_WGlob_Struct = getappdata(0,'Def_WGlob_Struct');
initFLAG = isempty(Def_WGlob_Struct);

switch option
    case 'is_on' , varargout{1} = ~initFLAG; return
    case 'clear'  
        if isappdata(0,'Def_WGlob_Struct')
            rmappdata(0,'Def_WGlob_Struct');
        end
        return
    case {'ini','pref'}
        if ~initFLAG
            if nargin==1 , return; end
            old_prefMode = Def_WGlob_Struct.initMode;
            if isequal(old_prefMode,varargin{1}); return; end
        else
            if nargin==1 , varargin{1} = 'default'; end
        end
        allPrefMode = cat(2,{'d','y','r','g','b','k','w'},...
            {'oldDefaut','default','black','white'},...
            num2cell(-1:17) , {'s','std','test'});

        prefMode = 'default';
        if nargin>1
            modeToTest = varargin{1};
            if ~isempty(modeToTest)
                for k = 1:length(allPrefMode)
                    if isequal(modeToTest,allPrefMode{k})
                        prefMode = modeToTest;
                        break
                    end
                end
            end
        end
        varargin{1} = prefMode;
        Def_WGlob_Struct = Get_Def_WGlob_Struct(varargin{:});
        setappdata(0,'Def_WGlob_Struct',Def_WGlob_Struct);
        if nargout>0 , varargout{1} = Def_WGlob_Struct; end

    case 'get'
        if initFLAG , Def_WGlob_Struct = mextglob('ini'); end
        sizes  = Def_WGlob_Struct.sizes;
        colors = Def_WGlob_Struct.colors;
        nbout  = nargout;
        nbin   = nargin-1;
        for k=1:min([nbin,nbout])
            switch varargin{k}
                case 'InitMode'        , ...
                        varargout{k} = Def_WGlob_Struct.initMode; %#ok<*AGROW>
                case 'Terminal_Prop'   , varargout{k} = sizes.termProp;
                case 'ShiftTop_Fig'    , varargout{k} = sizes.figShiftTop;
                case 'Def_Btn_Height'  , varargout{k} = sizes.btnHeight;
                case 'Def_Btn_Width'   , varargout{k} = sizes.btnWidth;
                case 'Def_Txt_Height'  , varargout{k} = sizes.txtHeight;
                case 'Pop_Min_Width'   , varargout{k} = sizes.popWidth;
                case 'Sli_YProp'       , varargout{k} = sizes.sliYProp;
                case 'X_Spacing'       , varargout{k} = sizes.xSpacing;
                case 'Y_Spacing'       , varargout{k} = sizes.ySpacing;
                case 'bdXLSpacing'     , varargout{k} = sizes.bdXLSpacing;
                case 'bdXRSpacing'     , varargout{k} = sizes.bdXRSpacing;
                case 'bdYSpacing'      , varargout{k} = sizes.bdYSpacing;
                case 'posLX_Txtinaxe'  , varargout{k} = sizes.posLX_Txtinaxe;
                case 'posRX_Txtinaxe'  , varargout{k} = sizes.posRX_Txtinaxe;
                case 'X_Graph_Ratio'   , varargout{k} = sizes.X_Graph_Ratio;
                case 'Win_WH_Ratio'    , varargout{k} = sizes.Win_WH_Ratio;
                case 'Win_Height'      , varargout{k} = sizes.Win_Height;
                case 'Win_Width'       , varargout{k} = sizes.Win_Width;
                case 'Win_Position'    , varargout{k} = sizes.Win_Position;
                case 'Cmd_Width'       , varargout{k} = sizes.Cmd_Width;
                case 'Fra_Width'       , varargout{k} = sizes.Fra_Width;
                case 'Def_AxeFontSize' , varargout{k} = sizes.axeFontSize;
                case 'Def_TxtFontSize' , varargout{k} = sizes.txtFontSize;
                case 'Def_UicFontSize' , varargout{k} = sizes.uicFontSize;
                case 'Def_UicFtWeight' , varargout{k} = sizes.uicFontWeight;
                case 'Def_AxeFtWeight' , varargout{k} = sizes.axeFontWeight;
                case 'Def_TxtFtWeight' , varargout{k} = sizes.txtFontWeight;
                case 'Lst_ColorMap'    , varargout{k} = colors.lstColorMap;
                case 'Def_UICBkColor'  , varargout{k} = colors.uicBkColor;
                case 'Def_TxtBkColor'  , varargout{k} = colors.txtBkColor;
                case 'Def_EdiBkColor'  , varargout{k} = colors.ediBkColor;
                case 'Def_Edi_ActBkColor' , varargout{k} = colors.ediActBkColor;
                case 'Def_Edi_InActBkColor' , varargout{k} = colors.ediInActBkColor;
                case 'Def_ShadowColor' , varargout{k} = colors.shadowColor;
                case 'Def_MsgBkColor' , varargout{k} = colors.msgBkColor;                    
                case 'Def_FraBkColor'  , varargout{k} = colors.fraBkColor;
                case 'Def_FigColor'    , varargout{k} = colors.figColor;
                case 'Def_DefColor'    , varargout{k} = colors.defColor;
                case 'Def_AxeColor'    , varargout{k} = colors.axeColor;
                case 'Def_AxeXColor'   , varargout{k} = colors.axeXColor;
                case 'Def_AxeYColor'   , varargout{k} = colors.axeYColor;
                case 'Def_AxeZColor'   , varargout{k} = colors.axeZColor;
                case 'Def_TxtColor'    , varargout{k} = colors.txtColor;
                case 'WTBX_Preferences' , ...
                        varargout{k} = Def_WGlob_Struct.preferences;
            end
        end

    case 'set'
        if initFLAG , Def_WGlob_Struct = mextglob('ini'); end
        nbin = nargin-1;
        for k=1:2:nbin
            switch varargin{k}
                case 'ShiftTop_Fig'
                    Def_WGlob_Struct.sizes.figShiftTop = varargin{k+1};
            end
        end
        setappdata(0,'Def_WGlob_Struct',Def_WGlob_Struct);
        if nargout>0 , varargout{1} = Def_WGlob_Struct; end        
end
%--------------------------------------------------------------------------
function  Def_WGlob_Struct = Get_Def_WGlob_Struct(varargin)

% Main Preference Mode.
%----------------------
prefMode = varargin{1};
switch prefMode
    case {'default','d'} , prefMode = -1;
    case {'k'}           , prefMode =  1;
    case {'w'}           , prefMode =  2;
    case {'r'}           , prefMode =  4;
    case {'b'}           , prefMode =  5;
    case {'g'}           , prefMode =  6;
    case {'y'}           , prefMode =  7;
    case {'s','std'}     , prefMode =  'std';
end

% Defaults for colors.
%---------------------
defColor = 'black';
figColor    = get(0,'DefaultFigureColor');
fraBkColor  = get(0,'DefaultUiPanelBackgroundColor');
uicBkColor  = get(0,'DefaultUicontrolBackgroundColor');
uicFontSize = get(0,'DefaultUicontrolFontSize');
ediBkColor      = [1 1 1];
ediActBkColor   = [1 1 1];
panTitleForColor = 'b';
txtBkColor = 0.6*[1 1 1];

% Defaults for Main preferences.
%-------------------------------
figTMP = figure('Visible','Off');
DefaultAxesFontName = get(figTMP,'DefaultAxesFontName');
DefaultTextFontName = get(figTMP,'DefaultTextFontName');
DefaultUipanelFontName = get(figTMP,'DefaultUipanelFontName');
delete(figTMP);
preferences = struct(...
    'oldPrefDef',false,      ...
    'figColor',figColor,     ...
    'fraBkColor',fraBkColor, ...
    'ediBkColor',ediBkColor, ...
    'ediActBkColor',ediBkColor, ...
    'ediInActBkColor',ediBkColor, ...
    'panTitleForColor',panTitleForColor, ...
    'panFontName',DefaultUipanelFontName, ...
    'panFontWeight','bold',   ...
    'uicFontWeight','normal', ...
    'uicFontSize',uicFontSize, ...
    'DefaultAxesFontName',DefaultAxesFontName, ...
    'DefaultTextFontName',DefaultTextFontName ...
    );

% Defaults for Fonts.
%--------------------
noBold = true;  % See noBold effect Below

%-------------------------------------------------------------
% No checking of for inputs.
%----------------------------
if nargin>1 , preferences.uicFontWeight = varargin{2}; end
if nargin>2 , preferences.panFontWeight = varargin{3}; end
%-------------------------------------------------------------

% Set sizes preferences.
%-----------------------
scrSize  = getMonitorSize;
termProp = scrSize(3:4);
%scrSize_STR =[int2str(termProp(1)) '_' int2str(termProp(2))];

% Default values.
figShiftTop = 50;
uicFontWeight = 'normal';
axeFontWeight = 'normal';
txtFontWeight = 'normal';
txtHeight     = 14; %High DPI 18
sliYProp      = 2/3;
%Win_WH_Ratio = 4/3;
%Scr_RATIO    = (scrSize(3)./scrSize(4))/Win_WH_Ratio;
%Win_WH_Ratio = Win_WH_Ratio*Scr_RATIO;
WHRatio = scrSize(3)/scrSize(4);

    if (scrSize(4) >= 1200 && WHRatio >=1.3)
        btnHeight = 24; btnWidth = 85; popWidth = 60;
        xSpacing  = 9;  ySpacing = 6;
        bdXLSpacing = 80; bdXRSpacing = 80; bdYSpacing = 80;
        posLX_Txtinaxe = 48; posRX_Txtinaxe = 28;
        fra_border  = 6;
        Win_WH_Ratio = 5/3;
        heightFACTOR = 1.2;
            %Fix for wide monitors, imac, 4k displays
            if WHRatio > 1.75
                Win_WH_Ratio = 1.8;
                heightFACTOR = 1.4;
            end
               
            if isunix
                axeFontSize = 10; txtFontSize = 10;uicFontSize = 10;
            else
                axeFontSize = 9; txtFontSize = 9; uicFontSize = 9;
            end
            
            win_height  = heightFACTOR*(21*btnHeight + 45*ySpacing);
            win_width   = Win_WH_Ratio*win_height;
            cmd_width   = win_width*0.25;
            win_left    = scrSize(3)-5-win_width;
            win_down    = scrSize(4)-win_height-figShiftTop;
            win_pos     = [win_left , win_down , win_width , win_height];
            
            
    elseif (scrSize(4) > 800 && scrSize(4) < 1200 && WHRatio >=1.3)
         btnHeight = 20; btnWidth = 70; popWidth = 50;
         xSpacing  = 9;  ySpacing = 6;  %High dpi 8
         bdXLSpacing = 80; bdXRSpacing = 50; bdYSpacing = 80;
         posLX_Txtinaxe = 48; posRX_Txtinaxe = 28;
         fra_border  = 6;
            if isunix
                axeFontSize = 9; txtFontSize = 9; uicFontSize = 9;
            else       
                axeFontSize = 8; txtFontSize = 8; uicFontSize = 8;
            end
            
            heightFACTOR = 1.2;
            sliYProp      = 2/3;
            Win_WH_Ratio = 5/3; 
            win_height  = heightFACTOR*(21*btnHeight + 45*ySpacing);
            win_width   = Win_WH_Ratio*win_height;
            win_left    = scrSize(3)-5-win_width;
            win_down    = scrSize(4)-win_height-figShiftTop;
            win_pos     = [win_left , win_down , win_width , win_height];
            cmd_width   = win_width*0.25;
            
    elseif (scrSize(4) >= 760 && scrSize(4) <=800 && WHRatio >=1.3)
        
        btnHeight = 20; btnWidth = 80; popWidth = 50;
        xSpacing  = 8;  ySpacing = 4; %9
        bdXLSpacing = 80; bdXRSpacing = 50; bdYSpacing = 80;
        posLX_Txtinaxe = 48; posRX_Txtinaxe = 28;
        fra_border = 6;
            if isunix
                axeFontSize = 9; txtFontSize = 9; uicFontSize = 9;
            else
                axeFontSize = 7; txtFontSize = 7; uicFontSize = 7;
            end
        heightFACTOR = 1.2;   % 1 
        Win_WH_Ratio = 4/3; 
        sliYProp      = 2/3;  %1
        win_height  = heightFACTOR*(21*btnHeight + 40*ySpacing);
        win_width   = Win_WH_Ratio*win_height;
        win_left    = scrSize(3)-5-win_width;
        win_down    = scrSize(4)-win_height-figShiftTop/3; % HIGH DPI /3
        win_pos     = [win_left , win_down , win_width , win_height];
        cmd_width   = win_width*0.28;  %.28

    elseif (scrSize(4) < 760 && WHRatio >=1.3)
        
        btnHeight = 20;
        btnWidth = 60;   popWidth = 55; %65
        xSpacing = 3; ySpacing = 4; 
        bdXLSpacing = 60; bdXRSpacing = 40; bdYSpacing = 20;
        posLX_Txtinaxe = 42; posRX_Txtinaxe = 25;
        fra_border = 2; 
            if isunix
                axeFontSize = 8; txtFontSize = 8; uicFontSize = 8;
            else
                axeFontSize = 7; txtFontSize = 7; uicFontSize = 7;
            end
        
        figShiftTop = 15;    
        heightFACTOR = 1;
        Win_WH_Ratio = 6/3;  %4/3
        Scr_RATIO    = (scrSize(3)./scrSize(4))/Win_WH_Ratio;
        Win_WH_Ratio = Win_WH_Ratio*Scr_RATIO;
        sliYProp      = 2/3;
        win_height  = heightFACTOR*(21*btnHeight + 38*ySpacing); 
        win_width   = Win_WH_Ratio*win_height;
        win_left    = scrSize(3)-5-win_width;
        win_down    = scrSize(4)-win_height-figShiftTop;
        win_pos     = [win_left , win_down , win_width , win_height];
        cmd_width   = win_width*0.30; %.30
        
    elseif (WHRatio < 1.35)
        btnHeight = 20; btnWidth = 80; popWidth = 50;
        xSpacing  = 8;  ySpacing = 5;
        bdXLSpacing = 80; bdXRSpacing = 50; bdYSpacing = 80;
        posLX_Txtinaxe = 48; posRX_Txtinaxe = 28;
        fra_border  = 6;
            if isunix
                axeFontSize = 8; txtFontSize = 8; uicFontSize = 8;
            else
                axeFontSize = 7; txtFontSize = 7; uicFontSize = 7;
            end
        heightFACTOR = 1.175;
        sliYProp      = 2/3;
        Win_WH_Ratio = 1.35;
        win_height  = heightFACTOR*(21*btnHeight + 38*ySpacing); 
        win_width   = Win_WH_Ratio*win_height;
        win_left    = scrSize(3)-5-win_width;
        win_down    = scrSize(4)-win_height-figShiftTop;
        win_pos     = [win_left , win_down , win_width , win_height];
        cmd_width   = win_width*0.30; %.30
    end
    
    
 


fra_width   = cmd_width - 2*fra_border;
xGra_ratio  = (win_width-cmd_width)/win_width;
bdXLSpacing = bdXLSpacing/scrSize(3);
bdXRSpacing = bdXRSpacing/scrSize(3);
bdYSpacing  = bdYSpacing/scrSize(4);

% NEW POSITION (WTBX 4.1);
win_pos(1:2) = win_pos(1:2)/2;
sizes = struct(...
    'figShiftTop',   figShiftTop,   ...
    'btnHeight',     btnHeight,     ...
    'btnWidth',      btnWidth,      ...
    'popWidth',      popWidth,      ...
    'xSpacing',      xSpacing,      ...
    'ySpacing',      ySpacing,      ...
    'bdXLSpacing',   bdXLSpacing,   ...
    'bdXRSpacing',   bdXRSpacing,   ...
    'bdYSpacing',    bdYSpacing,    ...
    'posLX_Txtinaxe',posLX_Txtinaxe, ...
    'posRX_Txtinaxe',posRX_Txtinaxe, ...
    'axeFontSize',   axeFontSize,   ...
    'txtFontSize',   txtFontSize,   ...
    'uicFontSize',   uicFontSize,   ...
    'uicFontWeight', uicFontWeight, ...
    'axeFontWeight', axeFontWeight, ...
    'txtFontWeight', txtFontWeight, ...
    'txtHeight',     txtHeight,     ...
    'sliYProp',      sliYProp,      ...
    'termProp',      termProp,      ...
    'Win_WH_Ratio',  Win_WH_Ratio,  ...
    'Win_Height',    win_height,    ...
    'Win_Width',     win_width,     ...
    'Win_Position',  win_pos,       ...
    'Cmd_Width',     cmd_width,     ...
    'Fra_Width',     fra_width,     ...
    'X_Graph_Ratio', xGra_ratio     ...
    );

% Set colors preferences.
%------------------------
iP = 4;
switch prefMode
    case -1     %'default'
        defColor = 'white';
        panTitleForColor = 'b';
        txtBkColor = 0.7*[1 1 1];

    case 0

    case {1,'black'}
        defColor = 'black';
        figColor = [0 0 0];
        panTitleForColor = 'y';

    case {2,'white'}
        defColor = 'white';
        figColor = [1 1 1];
        panTitleForColor = 'b';
        txtBkColor = [247/255 247/255 247/255];

    case {3,'oldDefaut'} % Old default
        figColor = [0.5 0.5 0.5];
        panTitleForColor = [0 0 1];
        preferences.oldPrefDef = true;

    case num2cell(iP:iP+3)      % IP = 4   (mode 4,5,6,7)
        defColor = 'white';
        switch prefMode
            case iP
                figColor = [0.99 0.91 0.79];
                panTitleForColor = 'r';
            case iP+1
                figColor = [0.70 0.78 1.00];
                panTitleForColor = 'b';
            case {iP+2}
                figColor = [0.86 1 0.86];
                panTitleForColor = [0 0.8 0];
            case {iP+3}
                figColor = [1 1 0.75];
                panTitleForColor = [0 0 1];
        end
        fraBkColor = figColor/1.25;
        txtBkColor = [247/255 247/255 247/255];

    case num2cell(iP+4:iP+7)   % IP = 4   (mode 8,9,10,11)
        defColor = 'black';
        switch prefMode
            case {iP+4}
                figColor = [0.4 0.27 0.27];  panTitleForColor = [1 0.5 0.5];
            case {iP+5}
                figColor = [0.27 0.4 0.27];  panTitleForColor = [0.5 1 0.5];
            case {iP+6}
                figColor = [0.20 0.30 0.50]; panTitleForColor = [0.7 0.7 1];
            case {iP+7}
                figColor = [0.7 0.3 0.2];    panTitleForColor = [1 1 0.5];
        end
        fraBkColor = max(min(figColor*2.5,1),panTitleForColor);
        txtBkColor = [247/255 247/255 247/255];

    case {12,13,14}
        switch prefMode
            case 12 , figColor = [0.3 0.4 0.5]; panTitleForColor = figColor*1.75;
            case 13 , figColor = [0.5 0.3 0.2]; panTitleForColor = [1 0.5 0.5];
            case 14 , figColor = [0.3 0.5 0.2]; panTitleForColor = [0 0.2 0];
        end
        fraBkColor = figColor*1.75;

    case {15,16}
        defColor = 'white';
        switch prefMode
            case  15 , figColor = [0.9 0.9 0.9]; panTitleForColor = 'r';
            case  16 , figColor = [0.7 0.7 0.7]; panTitleForColor = 'b';
        end
        fraBkColor = figColor/1.25;
        txtBkColor = [247/255 247/255 247/255];

    case 17
        defColor = 'black';
        figColor = [0.35 0.35 0.35]; panTitleForColor = 'y';
        fraBkColor = figColor*2.5;
        txtBkColor = [247/255 247/255 247/255];

    case 'test'
        defColor = 'black';
        figColor = [0.4 0.27 0.27];
        fraBkColor = figColor*2.5;
        panTitleForColor = [1 0.5 0.5];
        txtBkColor = [247/255 247/255 247/255];

    case {'std'}
        txtBkColor = [0.90 0.90 0.90];
        fraBkColor = [0.77 0.77 0.77];
end

if isequal(defColor,'black') 
    axeColor = [0 0 0]; txyz_Color = 'w';
else
    axeColor = [1 1 1]; txyz_Color = 'k';
end
ediInActBkColor = [0.95 0.90 0.85];
colors.defColor = defColor;
colors.figColor = figColor;
colors.fraBkColor  = fraBkColor;
colors.ediBkColor  = ediBkColor;
colors.ediActBkColor  = ediActBkColor;
colors.ediInActBkColor  = ediInActBkColor;
colors.uicBkColor  = uicBkColor;
colors.txtBkColor  = txtBkColor;
colors.lstColorMap = ...
    {...
    'pink','cool','gray','hot','jet','bone',      ...
    'copper','hsv','prism','1 - pink','1 - cool', ...
    '1 - gray','1 - hot','1 - jet','1 - bone',    ...
    'autumn','spring','winter','summer'           ...
    };
colors.axeColor  = axeColor;
colors.axeXColor = txyz_Color;
colors.axeYColor = txyz_Color;
colors.axeZColor = txyz_Color;
colors.txtColor  = txyz_Color;
colors.shadowColor = [0.7 0.7 0.7];
colors.msgBkColor  = [230 230 230]/255;

% Set bold preferences.
%----------------------
if nargin>1 && ~isequal(varargin{2},'normal') , noBold = false; end
if noBold , fontWeight = 'normal'; else fontWeight ='bold'; end
sizes.uicFontWeight = fontWeight;
sizes.axeFontWeight = fontWeight;
sizes.txtFontWeight = fontWeight;

% Set main preferences.
%----------------------
preferences.figColor = figColor;
preferences.fraBkColor = fraBkColor;
preferences.ediBkColor = ediBkColor;
preferences.ediActBkColor   = ediActBkColor;
preferences.ediInActBkColor = ediInActBkColor;
preferences.shadowColor = colors.shadowColor;
preferences.msgBkColor = colors.msgBkColor;
preferences.panTitleForColor = panTitleForColor;
preferences.uicFontSize = sizes.uicFontSize;
preferences.uicFontWeight = sizes.uicFontWeight;

Def_WGlob_Struct = struct('initMode',prefMode, ...
    'preferences',preferences,'sizes',sizes,'colors',colors);
%--------------------------------------------------------------------------
