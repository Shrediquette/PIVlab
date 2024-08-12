function varargout = wtbutils(option,varargin)
%WTBUTILS Wavelet Toolbox (Resources) Utilities.
%   OUT1 = wtbutils(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-May-99.
%   Last Revision 18-Jun-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

scrDIM = getMonitorSize;
switch option
    case 'colors'
        type = varargin{1};
        DefColor = mextglob('get','Def_DefColor');
        blackFLG = isequal(DefColor(1),'b');
        switch type
            case 'sig'  % TYPE = 'sig'  - signal color.
                varargout{1} = [1 0 0];     % Red
                
            case 'ssig' % TYPE = 'ssig' - synthesized signal color.
                if blackFLG
                    varargout{1} = [1 1 0];       % Yellow
                else
                    varargout{1} = [1 0 1]/1.75;  % Dark Magenta
                    
                end
                
            case 'app'  % TYPE = 'app'  - approximations colors.
                % in2 = NB Colors or 'flag'
                %--------------------------
                if blackFLG
                    varargout{1} = [0 1 1];       % Cyan
                else
                    varargout{1} = [0 0 1]/1.05;  % Dark Blue
                end
                if length(varargin)>1
                    if ischar(varargin{2}) , return; end
                    nbCOL = varargin{2};
                    varargout{1} = ...
                        wtbutils('colors','scaled',varargout{1},nbCOL);
                    if blackFLG , varargout{1}(:,2) = 0.75; end
                end
                
            case 'det'  % TYPE = 'det'  - details colors.
                % in2 = NB Colors or 'flag'
                %--------------------------
                if blackFLG
                    varargout{1} = [0 1 0];      % Green
                else
                    varargout{1} = [0 0.5 0];    % Dark Green
                end
                if length(varargin)>1
                    if ischar(varargin{2}) , return; end
                    varargout{1} = ...
                        wtbutils('colors','scaled',varargout{1},varargin{2});
                end
                
            case 'scaled'  % TYPE = 'scaled' - scaled colors
                % in2 = basic color [R G B]
                % in3 = NB Colors
                %--------------------------
                baseCOL = varargin{2};
                nbCOL   = varargin{3};
                out1 = baseCOL;
                dcol = (1-baseCOL);
                if sum((0<dcol) & (dcol<1))==0
                    dcol = dcol/nbCOL;
                    out1 = out1(ones(1,nbCOL),:);
                    for k=1:nbCOL-1
                        out1(k,:) = out1(k,:)+dcol.^(1/(nbCOL+1-k));
                    end
                    out1 = max(0,min(out1,1));
                else
                    dcol(dcol==1)= 0;
                    dcol = dcol/max(1,nbCOL-1);
                    out1 = (0:nbCOL-1)'*dcol+baseCOL(ones(1,nbCOL),:);
                    out1 = flipud(out1);
                end
                varargout{1} = out1;
                
            case 'stem'
                if blackFLG
                    varargout{1} = [1 1 0];      % Yellow
                else
                    varargout{1} = [0.9 0.8 0];  % Dark Yellow
                end
                
            case 'Col_THR_GBL'  % [col_linTHR,Col_linNOR,Col_LinZER]
                if blackFLG
                    varargout = {[1 1 0],[1 0 1],[0 1 1]};
                else
                    varargout = {[0 0 0],[1 0 1],[0 1 1]};
                end
                
            case 'linTHR'
                if blackFLG
                    varargout = {[1 1 0]};
                else
                    varargout = {[0 0 0]};
                end
                
            case 'stem_filters'
                if blackFLG
                    varargout = {[1 1 0]};   % Yellow
                else
                    varargout = {[0 0 1]};
                end
                
            case 'coefs'
                varargout = {[1 1 0]};
            case 'res'
                if blackFLG
                    varargout = {[1 0.70 0.28]};      % Orange
                else
                    varargout = {[1 0.70 0.28]/1.1};  % Dark Orange
                end
                
            case 'tree'
                varargout = {[1 1 1],[1 1 0]};  % OBSOLETE
                
            case {'cw1d'}
                if length(varargin)<2
                    varargout = {[1 0 0],[0 1 0],[0 1 1]}; % Red,Green,Cyan
                end
                switch varargin{2}
                    case 'sig'
                        varargout{1} = [1 0 0];   % Red
                    case 'lin'
                        varargout{1} = [0 1 0];   % Green
                    case 'spy'
                        varargout{1} = [0 1 1];   % Cyan
                end
                
            case {'dw1d'}
                switch varargin{2}
                    case 'sepcfs' , varargout{1} = [1 0 1];  % Magenta
                end
                
            case {'sw2d'}
                switch varargin{2}
                    case 'histRES' , varargout{1} = [1 0.70 0.28]; % Orange
                end
                
            case {'wp1d'}
                switch varargin{2}
                    case 'node'   , varargout{1} = [0 1 1];       % Cyan
                    case 'hist'   , varargout{1} = [1 0 1];       % Magenta
                    case 'recons' , varargout{1} = [1 0.70 0.28]; % Orange
                end
                
            case {'wp2d'}
                switch varargin{2}
                    case 'hist' , varargout{1} = [1 0 1];  % Magenta
                end
                
            case {'wdre'}
                struct_COL = struct( ...
                    'sigColor',[1 0 0],'denColor',[1 0 0], ...
                    'appColor',[0 1 1],'detColor',[0 1 0], ...
                    'cfsColor',[0 1 0],'estColor',[1 1 0]  ...
                    );
                if ~blackFLG
                    struct_COL.('appColor') = [0 1 1]/1.05;  % Dark Cyan
                    struct_COL.('detColor') = [0 0.8 0];     % Dark Green
                    struct_COL.('estColor') = [1 0 1]/1.75;  % Dark Magenta
                end
                varargout = {struct_COL};
                
            case {'wmden'}
                sigColor = [1 0 0];
                if ~blackFLG
                    denColor = [0 0 1];
                else
                    denColor = [1 1 0];
                end
                varargout = {sigColor,denColor};
                
            otherwise
                errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        
    case 'wputils'
        axeFontSize = mextglob('get','Def_AxeFontSize');
        type = varargin{1}(1);
        if length(varargin)>1 , axe_xcol = varargin{2}; end
        switch type
            case 'p'    % type = 'plottree'
                %--------------------------------------------------------
                % out1 = txt_color , out2 = lin_color , out3 = ftn_size
                %--------------------------------------------------------
                C1 = abs(axe_xcol-[0 0 1]); % Yellow
                varargout = {C1,axe_xcol,axeFontSize};
                
            case 't'    % type = 'tree_op'
                %--------------------------------------------------------
                % out1 = txt_color , out2 = sel_color , out3 = ftn_size
                %--------------------------------------------------------
                if isequal(axe_xcol,[1 1 1])
                    C1 = abs(axe_xcol-[0 0 1]);   % Yellow
                    C2 = [0 1 0];                 % Green
                else
                    C1 = abs(axe_xcol-[0 0 1]); % Blue
                    C2 = [1 0 0];               % Red
                end
                varargout = {C1, C2, axeFontSize};
                
            case 's'    % type = 'ss_node'
                %--------------------------------------------------------
                % out1 = txt_color , out2 = pack_color , out3 = ftn_size
                %--------------------------------------------------------
                col = [1 0 1];       % Magenta
                varargout = {col,col,axeFontSize};
        end
        
    case 'title_PREFS'
        WTBX_Preferences = mextglob('get','WTBX_Preferences');
        TitColor = WTBX_Preferences.panTitleForColor;
        FontName = WTBX_Preferences.DefaultAxesFontName;
        varargout = {TitColor,'bold',FontName};
        
    case 'dw1d_DISP_PREFS'
        if scrDIM(4)<=600
            dyLow = 0;
            mulH = 1;
        else
            dyLow = 3*mextglob('get','Y_Spacing');
            mulH = 1.5;
        end
        varargout = {dyLow,mulH};
        
    case 'dw1d_DEC_PREFS'
        if scrDIM(4)<= 600
            fontsize = 11;
        else
            fontsize = 13;
        end
        varargout = {fontsize};
        
    case {'cw1d_PREFS','cwim_PREFS'}
        [dy,btnHeight] = mextglob('get','Y_Spacing','Def_Btn_Height');
        if scrDIM(4)<= 600
            dy = 3;  % dy=4 override mextglob setting
            dy_POS_CCM      = 4*dy;      dh_CCM = 2*dy;
            dy_POS_FRA_AXES = 2*dy; %2*dy;
            dh_FRA_AXES = 5*dy; % 3*dy HIGH DPI
            chk_Height  = btnHeight; pus_Height = btnHeight;
            
        elseif scrDIM(4)<= 768
            dy_POS_CCM      = 3*dy;      dh_CCM = 3*dy;
            dy_POS_FRA_AXES = 2*dy; dh_FRA_AXES = 3*dy;
            chk_Height  = btnHeight; pus_Height = btnHeight;
            
        elseif scrDIM(4)<= 900
            dy = 6;
            dy_POS_CCM      = 3*dy;      dh_CCM = 3*dy;
            dy_POS_FRA_AXES = 2*dy; dh_FRA_AXES = 3*dy;
            chk_Height  = 1.25*btnHeight; pus_Height = 1.25*btnHeight;
            
        elseif scrDIM(4)<= 1024
            dy = 8;
            dy_POS_CCM      = 3*dy;      dh_CCM = 3*dy;
            dy_POS_FRA_AXES = 2*dy; dh_FRA_AXES = 3*dy;
            chk_Height  = 1.5*btnHeight; pus_Height = 1.5*btnHeight;
            
        elseif scrDIM(4)> 1199  % (1600 x 1200)
            dy = 8;
            dy_POS_CCM      = 3*dy;      dh_CCM = 3*dy;
            dy_POS_FRA_AXES = 2*dy; dh_FRA_AXES = 3*dy;
            chk_Height  = 1.5*btnHeight; pus_Height = 1.5*btnHeight;
            
        else
            dy = 8;
            dy_POS_CCM      = 3*dy;      dh_CCM = 3*dy;
            dy_POS_FRA_AXES = 2*dy; dh_FRA_AXES = 3*dy;
            chk_Height  = btnHeight; pus_Height = btnHeight;
        end
        varargout = ...
            {dy_POS_CCM , dh_CCM , dy_POS_FRA_AXES , dh_FRA_AXES , ...
            chk_Height , pus_Height};
        
    case 'dw2d_PREFS'
        DefColor = mextglob('get','Def_DefColor');
        blackFLG = isequal(DefColor(1),'b');
        if blackFLG
            dw2d_PREFS = struct(...
                'Col_BoxAxeSel',   [1 1 0] , ...
                'Col_BoxTitleSel', [0 1 0] , ...
                'Col_ArrowFrm',    [1 1 1] , ...
                'Col_ArrowTxt' ,   [1 1 0] , ...
                'Wid_LineSel' ,    2         ...
                );
        else
            dw2d_PREFS = struct(...
                'Col_BoxAxeSel',   [1 1 0] ,   ...
                'Col_BoxTitleSel', [0 0 1] ,   ...
                'Col_ArrowFrm',    [1 1 1]/2 , ...
                'Col_ArrowTxt' ,   [1 0 1] ,   ...
                'Wid_LineSel' ,    2           ...
                );
        end
        WTBX_Preferences = mextglob('get','WTBX_Preferences');
        dw2d_PREFS.Col_ArrowTxt = WTBX_Preferences.panTitleForColor ;
        varargout = {dw2d_PREFS};
        
    case 'dynV_PREFS'
        if isunix
            infoFontSize = 9;
        else
            infoFontSize = 8;
        end
        if     scrDIM(3)<= 800
            plusWidth = 1;
            d_WidthMax = 100;
        elseif scrDIM(3)<= 1024
            plusWidth = 4;
            d_WidthMax = 50;
        else
            plusWidth = 2;
            d_WidthMax = 110;
        end
        if scrDIM(4)<= 600
            infoFontSize = 7;
        end
        varargout = {plusWidth,d_WidthMax,infoFontSize};
        
    case 'deno1D_PREFS'
        if  scrDIM(4)<= 600
            bdy = 2;dyLEV = 1;
            mulHeight = 1;
        elseif scrDIM(4)<= 768
            bdy = 4;
            dyLEV = 4;
            mulHeight = 1.5;
        elseif scrDIM(4)<= 864
            bdy = 4;
            dyLEV = 4;
            mulHeight = 1.5;
        else
            bdy = 6;
            dyLEV = 6;
            mulHeight = 1.5;
        end
        if isempty(varargin), varargout = {bdy,dyLEV,mulHeight}; return; end
        switch varargin{1}
            case 'yParams'   , varargout = {bdy,dyLEV};
            case 'dyLEV'     , varargout = {dyLEV};
            case 'mulHeight' , varargout = {mulHeight};
            otherwise        , varargout = {bdy,dyLEV,mulHeight};
        end
        
    case 'comp1D_PREFS'
        bdy = 2;
        if scrDIM(4)<= 600
            dyLEV = 0;      % 800 x 600 (H = 513)    Pb level 12
        elseif scrDIM(4)<= 768
            if scrDIM(3)<=1024
                dyLEV = 0;  % 1024 x 768 (H = 645)
            else
                dyLEV = 1;    % 1280 x 720 (H = 677) , 1280 x 768 (H = 630)
            end
        elseif scrDIM(4)<= 864  % 1152 x 864 (H = 677)
            dyLEV = 2;
        else
            bdy = 6; dyLEV = 6; % 1280 x 960 (H = 757) , 1280 x 1024 (H = 757)
        end
        varargout = {bdy,dyLEV};
        
    case 'deno2D_PREFS'
        btnHeight = mextglob('get','Def_Btn_Height');
        if     scrDIM(4)<= 600
            bdy = 2; dyLEV = 2;
        elseif scrDIM(4)<= 768
            bdy = 4; dyLEV = 4;
        elseif scrDIM(4)<= 1024
            bdy = 6; dyLEV = 6;
        else
            bdy = 6; dyLEV = 6;
        end
        if isempty(varargin) , varargout = {bdy,dyLEV,btnHeight}; return; end
        switch varargin{1}
            case 'params'    , varargout = {bdy,dyLEV,btnHeight};
            case 'dyLEV'     , varargout = {dyLEV};
            case 'btnHeight' , varargout = {btnHeight};
            otherwise        , varargout = {bdy,dyLEV,btnHeight};
        end
        
    case {'utthrgbl_PREFS','utthrwpd_PREFS'}
        btnHeight = mextglob('get','Def_Btn_Height');
        if     scrDIM(4)<= 600
            bdy = 2; dyLEV = 2;
        elseif scrDIM(4)<= 768
            bdy = 4; dyLEV = 4;
        elseif scrDIM(4)<= 1024
            bdy = 6; dyLEV = 6;
        else
            bdy = 6; dyLEV = 6;
        end
        if isempty(varargin) , varargout = {bdy,dyLEV,btnHeight}; return; end
        switch varargin{1}
            case 'params'    , varargout = {bdy,dyLEV,btnHeight};
            case 'dyLEV'     , varargout = {dyLEV};
            case 'btnHeight' , varargout = {btnHeight};
            otherwise        , varargout = {bdy,dyLEV,btnHeight};
        end
        
    case 'utnbCFS_PREFS'
        if     scrDIM(4)<= 600
            bdy = 2; dyLEV = 2; mulHeight = 1;
        elseif scrDIM(4)<= 768
            bdy = 4; dyLEV = 3; mulHeight = 1.5;
        else
            bdy = 4; dyLEV = 4; mulHeight = 1.5;
        end
        if isempty(varargin) , varargout = {bdy,dyLEV,mulHeight}; return; end
        switch varargin{1}
            case 'yParams'   , varargout = {bdy,dyLEV};
            case 'dyLEV'     , varargout = {dyLEV};
            case 'mulHeight' , varargout = {mulHeight};
            otherwise        , varargout = {bdy,dyLEV,mulHeight};
        end
        
    case 'utSTATS_PREFS'
        if     scrDIM(4)<= 600  , minSize = 7;
        elseif scrDIM(4)<= 768
            if isunix
                minSize = 10;
            else
                minSize = 8;
            end
        elseif scrDIM(3)<= 1024
            if isunix
                minSize = 10;
            else
                minSize = 8;
            end
        elseif scrDIM(3)<= 1280
            minSize = Inf;
        else
            minSize = Inf;
        end
        varargout = {minSize};
        
    case 'extension_PREFS'
        if     scrDIM(3)<= 800
            deltaX = 10;
        elseif scrDIM(3)<= 1024
            deltaX = 2;
        elseif scrDIM(3)<= 1280
            deltaX = 2;
        else
            deltaX = 2;
        end
        varargout = {deltaX};
end
