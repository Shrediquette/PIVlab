function varargout = wdretool(option,varargin)
%WDRETOOL Wavelet Density and Regression tool.
%   VARARGOUT = WDRETOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Dec-96.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 0
    iClose =  ~isempty(option) && ischar(option) && ...
    strcmpi(option,'close');
else
    iClose = false;
end
% DDUX data logging
if nargin == 0 || nargin > 0 && ~isempty(option) && ...
        (strcmpi(option,'createDEN') || strcmpi(option,'createREG') ...
        && ~iClose)
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "wdretool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
% Test inputs.
%-------------
if nargin==0 , option = 'createREG'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_membloc1   = 'MB_1';
ind_xdata    = 1;
ind_ydata    = 2;
ind_xbounds  = 3;
ind_filename = 4;
ind_pathname = 5;
ind_sig_name = 6;
nb2_stored   = 6;

% MB2.
%-----
n_membloc2   = 'MB_2';
ind_status   = 1;
ind_lin_den  = 2;
ind_gra_area = 3;
nb1_stored   = 3;

% MB3.
%-----
n_membloc3 = 'MB_3';
ind_coefs  = 1;
ind_longs  = 2;
ind_sig    = 3;
nb4_stored = 3;

% Default values.
%----------------
def_MinBIN = 64;
def_DefBIN = 256;
default_wave = 'sym4';
NB_max_lev = 8;
NB_def_lev = 5;
yLevelDir  = -1;

% Tag property.
%--------------
tag_ori = 'Sig';
tag_dat = 'Proc_Data';
tag_app = 'App';
tag_est = 'Est';

switch option
  case {'createDEN','createREG'}
  case 'close' 
  otherwise
    win_tool = varargin{1};
    handles  = wfigmngr('getValue',win_tool,'WDRE_handles');
    hdl_UIC  = handles.hdl_UIC;
    hdl_AXE  = handles.hdl_AXE;
    txt_hdl  = handles.hdl_TXT;
    hdl_MEN  = handles.hdl_MEN;
    men_sav  = hdl_MEN(end);
    m_exp_sig = wtbxappdata('get',win_tool,'m_exp_sig');    
    dummy    = struct2cell(hdl_UIC);
    [txt_bin,sli_bin,edi_bin,pus_dec,chk_den] = deal(dummy{:}); %#ok<ASGLU>
    axe_hdl  = struct2cell(hdl_AXE);
    [axe_L_1,axe_R_1,axe_L_2,axe_R_2,axe_cfs,axe_det,axe_app] =  ...
           deal(axe_hdl{:});
    axe_hdl  = cat(2,axe_hdl{:});
    colors   = wfigmngr('getValue',win_tool,'WDRE_colors');
    toolATTR = wfigmngr('getValue',win_tool,'WDRE_toolATTR');
    switch option
      case {'load','demo'}
      otherwise , toolMode = toolATTR.toolMode;
    end
end

switch option
    case {'createDEN','createREG'}

        % Parameters initialization.
        %---------------------------
        indic_vis_lev = getLevels(NB_max_lev,yLevelDir);

        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Y_Spacing, ...
         sliYProp,Def_EdiBkColor, Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Y_Spacing', ...
                'Sli_YProp','Def_EdiBkColor','Def_FraBkColor' ...
                );

        % Window initialization.
        %-----------------------
        switch option
          case 'createREG'
            win_title = getWavMSG('Wavelet:divGUIRF:Reg1D_Name');
            estiNAME  = 'esti_REG';
			figExtMode = 'ExtFig_Tool_1';			

          case 'createDEN'
            win_title = getWavMSG('Wavelet:divGUIRF:Esti1D_Name');
            estiNAME  = 'esti_DEN';
			figExtMode = 'ExtFig_WTMOTION';
        end
        [win_tool,pos_win,win_units,~,...
            pos_frame0,Pos_Graphic_Area] = ...
               wfigmngr('create',win_title,winAttrb,figExtMode,mfilename,1,1,0);
        if nargout>0 , varargout{1} = win_tool; end

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngr('getmenus',win_tool);
        switch option
          case 'createREG'

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',win_tool, ...
				getWavMSG('Wavelet:divGUIRF:Esti_RndDes'),'REGR_GUI');
			wfighelp('addHelpTool',win_tool, ...
				getWavMSG('Wavelet:divGUIRF:Esti_FixDes'),'REGF_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:divGUIRF:HLP_Reg'),'REG_EST');			
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:divGUIRF:VarAdapMeth'),'VARTHR');
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:commongui:HLP_LoadSave'),'REG_LOADSAVE');		

			m_load = wfigmngr('getmenus',win_tool,'load');  
            lab = getWavMSG('Wavelet:divGUIRF:Data_FixDes');
            men_fix = uimenu(m_load,...
                         'Label',lab,'Position',1, ...
                         'Callback',               ...
                         @(~,~)wdretool('load', win_tool,'fixreg') ...
                         );
            lab = getWavMSG('Wavelet:divGUIRF:Data_StoDes');
            men_sto = uimenu(m_load,...
                        'Label',lab,'Position',2, ...
                        'Callback',               ...
                        @(~,~)wdretool('load', win_tool,'storeg') ...
                        );
            men_den = [];
            men_sav = uimenu(m_files,...
                         'Label',getWavMSG('Wavelet:divGUIRF:Save_EstFun'),...
                         'Position',2,            ...
                         'Enable','Off',          ...
                         'Callback',              ...
                         @(~,~)wdretool('save', win_tool,'fun')...
                         );

            m_demo = uimenu(m_files,...
                        'Label',getWavMSG('Wavelet:commongui:Lab_Example'),...
                        'Tag','Examples','Position',3,'Separator','Off');
						 
            numDEM = 1;
            labDEM = getWavMSG('Wavelet:divGUIRF:FixDes');
            m_demo_1 = uimenu(m_demo, ...
                        'Label',labDEM,'Position',numDEM,'Separator','Off');

            demoSET = {...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_I') , ...
                    'ex1nfix'  , 'db2'  , 5 ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_II'),  ...
                    'ex2nfix'  , 'sym4' , 5 ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_III'), ...
                    'ex3nfix'  , 'db3'  , 5 ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks')  , ...
                    'noisbloc' , 'haar' , 5 ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler') , ...
                    'noisdopp' , 'db5'  , 5 ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps')   , ...
                    'noisbump' , 'db5'  , 5   ...
              };
            setDEMOS(m_demo_1,win_tool,demoSET,0)

            numDEM = 2;
            labDEM = getWavMSG('Wavelet:divGUIRF:FixDes_IntDep');
            m_demo_2 = uimenu(m_demo, ...
                        'Label',labDEM,'Position',numDEM,'Separator','Off');
            demoSET = {...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks_I') , ...
                    'nblocr1' , 'sym4', 5 , {3} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks_II') , ...
                    'nblocr2' , 'sym4', 5 , {3} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler_I') , ...
                    'ndoppr1' , 'sym4', 5 , {3} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_I') , ...
                    'nbumpr1' , 'sym4', 5 , {3} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_II') ,...
                    'nbumpr2' , 'sym4', 5 , {2} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_III') ,...
                    'nbumpr3' , 'sym4', 5 , {4} ; ...
              'fixreg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NElec') , ...
                    'nelec'   , 'sym4', 5 , {3}   ...
              };
            setDEMOS(m_demo_2,win_tool,demoSET,0)

            numDEM = 3;
            labDEM = getWavMSG('Wavelet:divGUIRF:StoDes');
            m_demo_3 = uimenu(m_demo,...
                        'Label',labDEM,'Position',numDEM,'Separator','On');
            demoSET = {...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_I')  , ...
                    'ex1nsto'  , 'sym4' ,5 ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_II') , ...
                    'ex2nsto'  , 'haar' ,5 ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_Example_III'), ...
                    'ex3nsto'  , 'db6'  ,5 ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler') , ...
                    'noisdopp' , 'db5'  ,5 ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps')   , ...
                    'noisbump' , 'db5'  ,5   ...
              };
            setDEMOS(m_demo_3,win_tool,demoSET,0)
 
            numDEM = 4;
            labDEM = getWavMSG('Wavelet:divGUIRF:StoDes_IntDep');
            m_demo_4 = uimenu(m_demo,'Label',labDEM,'Position',numDEM, ...
                        'Tag','StoDes_IntDep','Separator','Off');
                        
            demoSET = {...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks_I')  , ...
                    'snblocr1' , 'sym4', 5 , {3} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks_II') , ...
                    'snblocr2' , 'sym4', 5 , {3} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler_I') , ...
                    'sndoppr1' , 'sym4', 5 , {3} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_I') , ...
                    'snbumpr1' , 'sym4', 5 , {3} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_II') , ...
                    'snbumpr2' , 'sym4', 5 , {2} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps_III') , ...
                    'snbumpr3' , 'sym4', 5 , {4} ; ...
              'storeg' , getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NElec') , ...
                    'snelec'   , 'sym4', 5 , {3}   ...
              };
            setDEMOS(m_demo_4,win_tool,demoSET,0)
            uimenu(m_files,...
                'Label',getWavMSG('Wavelet:commongui:Lab_Import'), ...
                'Position',4,'Separator','On','Tag','Import', ...              ...
                'Callback',@(~,~)wdretool('load', win_tool, 'wrksreg',1) ...
                );
            m_exp_sig = uimenu(m_files, ...
                'Label',getWavMSG('Wavelet:divGUIRF:Str_ExportEstFun'),   ...
                'Position',5,'Enable','Off','Separator','Off','Tag','Export',...
                'Callback',@(~,~)wdretool('exp_wrks', win_tool, 'REG')  ...
                );

          case 'createDEN'

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',win_tool, ...
				getWavMSG('Wavelet:divGUIRF:OneDim_Est'),'EDEN_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:divGUIRF:VarAdapMeth'),'VARTHR');
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:commongui:HLP_LoadSave'),'EDEN_LOADSAVE');		
			wfighelp('addHelpItem',win_tool, ...
                getWavMSG('Wavelet:divGUIRF:HLP_EstDens'),'DENS_EST');		
            men_fix = [];
            men_sto = [];
            men_den = uimenu(m_files,...
                'Label',getWavMSG('Wavelet:divGUIRF:Load_DataDens'),...
                'Position',1, ...
                'Callback', ...            ...                
                @(~,~)wdretool('load', win_tool, 'denest'), ...
                'Tag', 'Load_File' ...
                );
            men_sav = uimenu(m_files,...
                'Label',getWavMSG('Wavelet:divGUIRF:Save_Dens'), ...
                'Position',2,           ...
                'Enable','Off',         ...
                'Callback',             ...
                @(~,~)wdretool('save', win_tool, 'den'), ...
                'Tag', 'Save_File' ...
                );
            demoSET = {...
              'denest' , 'ex1cusp1' , 'ex1cusp1' , 'sym4'  , 5 ; ...
              'denest' , 'ex2cusp1' , 'ex2cusp1' , 'sym6'  , 5 ; ...
              'denest' , 'ex1cusp2' , 'ex1cusp2' , 'sym4'  , 5 ; ...
              'denest' , 'ex2cusp2' , 'ex2cusp2' , 'coif1' , 5 ; ...
              'denest' , 'ex1gauss' , 'ex1gauss' , 'sym3'  , 5 ; ...
              'denest' , 'ex2gauss' , 'ex2gauss' , 'sym4'  , 5   ...
              };
            m_demo = uimenu(m_files,'Label', ...
                getWavMSG('Wavelet:commongui:Lab_Example'),'Position',3,...
                'Tag','Examples');
            setDEMOS(m_demo,win_tool,demoSET,0);
            uimenu(m_files,...
                'Label',getWavMSG('Wavelet:commongui:Lab_Import'),...
                'Position',4,'Separator','On','Tag','Import', ...
                'Callback',               ...
                @(~,~)wdretool('load', win_tool, 'denest',1) ...
                );
            m_exp_sig = uimenu(m_files, ...
                'Label',getWavMSG('Wavelet:divGUIRF:Str_ExpDens'),   ...
                'Position',5,'Enable','Off','Separator','Off','Tag','Export',...
                'Callback',@(~,~)wdretool('exp_wrks', win_tool, 'DEN')  ...
                );
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitInit'));

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);
        minimum_bin = 16;
        maximum_bin = 1024;
        default_bin = 256;

        % String property of objects.
        %----------------------------
        str_pus_dec = getWavMSG('Wavelet:commongui:Str_Decompose');
        str_chk_den = getWavMSG('Wavelet:divGUIRF:Ovr_EstFun');
        str_txt_bin = getWavMSG('Wavelet:commongui:Str_NbBinsAbr');
        str_edi_bin = sprintf('%.0f',default_bin);

        % Command part of the window.
        %============================
        comFigProp = {'Parent',win_tool,'Units',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create',win_tool, ...
                    'xloc',xlocINI,'top',ytopINI,...
                    'Enable','off',      ...
                    'wtype','dwt',       ...
                    'deflev',NB_def_lev, ...
                    'maxlev',NB_max_lev  ...
                    );
        utanapar('handles',win_tool,'lev');

        % Callbacks.
        %-----------
        cba_sli_bin = @(~,~)wdretool('upd_bin', win_tool, 'sli');
        cba_edi_bin = @(~,~)wdretool('upd_bin', win_tool, 'edi');
        cba_pus_dec = @(~,~)wdretool('decompose', win_tool );
        cba_chk_den = @(~,~)wdretool('show_lin_den', win_tool );

        % Bins settings.
        %---------------
        w_bas = toolPos(3)/48;        
        h_uic = Def_Btn_Height;

        w_uic = 11*w_bas;
        x_uic = toolPos(1);
        y_uic = toolPos(2)-h_uic-2*dy;
        pos_txt_bin = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        x_uic = x_uic+w_uic;
        w_uic = 27*w_bas;
        pos_sli_bin = [x_uic, y_uic+sli_dy, w_uic, sli_hi];

        x_uic = x_uic+w_uic+4;
        w_uic = 10*w_bas-4;
        pos_edi_bin = [x_uic, y_uic, w_uic, h_uic];
       
        txt_bin = uicontrol(comFigProp{:},...
            'Style','Text',...
            'Position',pos_txt_bin,...
            'HorizontalAlignment','left',...
            'BackgroundColor',Def_FraBkColor,...
            'String',str_txt_bin...
            );
 
        sli_bin = uicontrol(comFigProp{:},...
            'Style','Slider',...
            'Position',pos_sli_bin,...
            'Min',minimum_bin,...
            'Max',maximum_bin,...
            'Value',default_bin, ...
            'Enable','off', ...
            'Callback',cba_sli_bin ...
            );

        edi_bin = uicontrol(comFigProp{:},...
            'Style','Edit',...
            'BackgroundColor',Def_EdiBkColor,...
            'Position',pos_edi_bin,...
            'String',str_edi_bin,...
            'Enable','off',...
            'Callback',cba_edi_bin ...
            );

        % Decompose pushbutton.
        %----------------------
        h_uic = 3*Def_Btn_Height/2;
        y_uic = y_uic-h_uic-2*dy;
        w_uic = pos_frame0(3)/2;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        pos_pus_dec = [x_uic, y_uic, w_uic, h_uic];
        pus_dec = uicontrol(comFigProp{:},          ...
            'Style','pushbutton',   ...
            'Position',pos_pus_dec, ...
            'String',str_pus_dec,   ...
            'Enable','off',         ...
            'Interruptible','On',   ...
            'Tag','Pus_Dec',        ...
            'Callback',cba_pus_dec  ...
            );

        % Thresholding tool.
        %-------------------
        ytopTHR = pos_pus_dec(2)-2*dy;
        toolPos = utthrw1d('create',win_tool, ...
            'xloc',xlocINI,'top',ytopTHR,...
            'ydir',yLevelDir,       ...
            'levmax',NB_def_lev,    ...
            'levmaxMAX',NB_max_lev, ...
            'status','Off',         ...
            'toolOPT',estiNAME      ...
            );

        % Estimated Line(s) Check.
        %-------------------------
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
        pos_chk_den = [x_uic, y_uic+8, w_uic, h_uic/1.5]; % /1.5 high DPI y_uic+8
        if isequal(option,'createDEN') , vis = 'Off'; else vis = 'On'; end  
        chk_den = uicontrol(comFigProp{:},          ...
            'Style','checkbox',     ...
            'Visible',vis,          ...
            'Position',pos_chk_den, ...
            'String',str_chk_den,   ...
            'Enable','off',         ...
            'Callback',cba_chk_den  ...
            );

        % Callbacks update.
        %------------------
        hdl_den = utthrw1d('handles',win_tool);
        utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
        pop_lev = utanapar('handles',win_tool,'lev');
        tmp     = pop_lev;
        cba_pop_lev = @(~,~)wdretool('upd_lev', win_tool,  tmp );
        set(pop_lev,'Callback',cba_pop_lev);

        % General graphical parameters initialization.
        %--------------------------------------------
        txtLRProp = {'off','bold',14};

        % Axes construction parameters.
        %------------------------------
        NB_lev    = NB_max_lev;    % dummy
        w_gra_rem = Pos_Graphic_Area(3);
        h_gra_rem = Pos_Graphic_Area(4);
        ecx_left  = 0.08*pos_win(3);
        ecx_med   = 0.07*pos_win(3);
        ecx_right = 0.06*pos_win(3);
        w_axe     = (w_gra_rem-ecx_left-ecx_med-ecx_right)/2;
        x_cfs     = ecx_left;
        x_det     = x_cfs+w_axe+ecx_med;
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.07*pos_win(4);
        ecy_mid_2 = ecy_mid_1;
        ecy_mid_3 = ecy_mid_1;
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_down  = ecy_up;
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(NB_max_lev-NB_lev))/NB_max_lev;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+...
                    (NB_lev-1)*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = pos_win(4);

        % Building data axes.
        %--------------------
        comAxeProp = [comFigProp,'Visible','off','Box','On'];
        y_low_ini = y_low_ini-h_axe_std-ecy_up;
        pos_L_1   = [x_cfs y_low_ini w_axe h_axe_std];
        axe_L_1   = axes(comAxeProp{:},'Position',pos_L_1);
        pos_R_1   = [x_det y_low_ini w_axe h_axe_std];
        axe_R_1   = axes(comAxeProp{:},'Position',pos_R_1);
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_1;
        pos_L_2   = [x_cfs y_low_ini w_axe h_axe_std];
        axe_L_2   = axes(comAxeProp{:},'Position',pos_L_2);
        pos_R_2   = [x_det y_low_ini w_axe h_axe_std];
        axe_R_2   = axes(comAxeProp{:},'Position',pos_R_2);
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_2;

        % Building approximation axes on the right part.
        %-----------------------------------------------
        pos_app = [x_det y_low_ini w_axe h_detail];
        axe_app = axes(comAxeProp{:},'Position',pos_app);
        str_txt = ['a' wnsubstr(abs(NB_max_lev))];
        txt_app = txtinaxe('create',str_txt,axe_app,'r',txtLRProp{:});
        y_low_ini = y_low_ini-h_detail-ecy_mid_3+ecy_det;

        % Building details axes on the left part.
        %----------------------------------------
        comAxePropMore = [...
          comAxeProp,'XTickLabelMode','manual','XTickLabel',' '];
        axe_cfs = zeros(1,NB_max_lev);
        txt_cfs = zeros(1,NB_max_lev);
        y_cfs   = y_low_ini;
        pos_cfs = [x_cfs y_cfs w_axe h_detail];
        for j = 1:NB_max_lev
            k = indic_vis_lev(j);
            pos_cfs(2) = pos_cfs(2)-pos_cfs(4)-ecy_det;
            axe_cfs(k) = axes(comAxePropMore{:},'Position',pos_cfs); %#ok<*LAXES>
            str_txt    = ['d' wnsubstr(k)];
            txt_cfs(k) = txtinaxe('create',str_txt,axe_cfs(k),'l',txtLRProp{:});
            set(txt_cfs(k),'UserData',k,'Tag','');
        end
        utthrw1d('set',win_tool,'axes',axe_cfs);

        % Building details axes on the right part.
        %-----------------------------------------
        axe_det = zeros(1,NB_max_lev);
        txt_det = zeros(1,NB_max_lev);
        y_det   = y_low_ini;
        pos_det = [x_det y_det w_axe h_detail];
        for j = 1:NB_max_lev
            k = indic_vis_lev(j);
            pos_det(2) = pos_det(2)-pos_det(4)-ecy_det;
            axe_det(k) = axes(comAxePropMore{:},'Position',pos_det);
            str_txt    = ['d' wnsubstr(k)];
            txt_det(k) = txtinaxe('create',str_txt,axe_det(k),'r',txtLRProp{:});
        end

        %  Normalization.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_tool, ...
            Pos_Graphic_Area,'On');
        drawnow

        % Set default wavelet.
        %---------------------
        cbanapar('set',win_tool,'wav',default_wave);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BINS  = [txt_bin,sli_bin,edi_bin];
		switch option
			case 'createDEN' , helpName = 'EDEN_BINS';
			case 'createREG' , helpName = 'REG_BINS';
		end
		wfighelp('add_ContextMenu',win_tool,hdl_BINS,helpName);		
		%-------------------------------------
		
        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_tool,n_membloc2,nb1_stored);
        wmemtool('ini',win_tool,n_membloc1,nb2_stored);
        wmemtool('ini',win_tool,n_membloc3,nb4_stored);
        wmemtool('wmb',win_tool,n_membloc2,...
                                ind_status,0,        ...
                                ind_lin_den,[NaN,NaN], ...
                                ind_gra_area,Pos_Graphic_Area ...
                                );
        fields = {'txt_bin','sli_bin','edi_bin','pus_dec','chk_den'};
        values = {txt_bin,sli_bin,edi_bin,pus_dec,chk_den};
        hdl_UIC = cell2struct(values,fields,2);
        hdl_MEN = [men_fix ; men_sto ; men_den ; men_sav];
        wtbxappdata('set',win_tool,'m_exp_sig',m_exp_sig);
        fields = {...
          'axe_L_1' , 'axe_R_1' , 'axe_L_2' , 'axe_R_2' ,  ...
          'axe_cfs' , 'axe_det' , 'axe_app' ...
          };
        values = {...
          axe_L_1 , axe_R_1 , axe_L_2 , axe_R_2 ,  ...
          axe_cfs , axe_det , axe_app ...
           };
        hdl_AXE = cell2struct(values,fields,2);
        hdl_TXT = [NaN  NaN  NaN  NaN  txt_cfs txt_det double(txt_app)];
        handles = struct(...
            'hdl_MEN',hdl_MEN, ...
            'hdl_UIC',hdl_UIC, ...
            'hdl_AXE',hdl_AXE, ...
            'hdl_TXT',hdl_TXT  ...
            );
        wfigmngr('storeValue',win_tool,'WDRE_handles',handles);

        %-----------------------------------------------------------------
        % colors = struct( ...
        %   'sigColor',[1 0 0],'denColor',[1 0 0],'appColor',[0 1 1], ...
        %   'detColor',[0 1 0],'cfsColor',[0 1 0],'estColor',[1 1 0]  ...
        %   );
        %-----------------------------------------------------------------

        colors = wtbutils('colors','wdre');
        wfigmngr('storeValue',win_tool,'WDRE_colors',colors);

        toolATTR = struct('toolMode','','toolState','',...
            'level',[],'wname','','NBClasses',[]);
        wfigmngr('storeValue',win_tool,'WDRE_toolATTR',toolATTR);

        % End waiting.
        %---------------
        wwaiting('off',win_tool);

    case {'load','demo'}
        tool_OPT = varargin{2};
        loadFLAG = true;
        switch option
          case 'load'
            switch tool_OPT
              case 'denest'
                  dialName = getWavMSG('Wavelet:divGUIRF:Load_EstDen');
              case 'fixreg'
                  dialName = getWavMSG('Wavelet:divGUIRF:Load_FixDes');
              case 'storeg'
                  dialName = getWavMSG('Wavelet:divGUIRF:Load_StoDes');
            end
            if isequal(tool_OPT,'denest') && length(varargin)>2
                [sigInfos,xdata,ok] = wtbximport('1d');
                loadFLAG = false;
                
            elseif isequal(tool_OPT,'wrksreg')
                [ok,input_VAL,sig_Name] = wtbximport('reg');
                % [sigInfos,xdata,ok] = wtbximport('1d');
                loadFLAG = false;
                
            else
                [filename,pathname,ok] = ...
                    utguidiv('test_load',win_tool,'*.mat',dialName);
            end
            if ~ok, return; end

          case 'demo'
            sig_Name = deblank(varargin{3});
            wav_Name = deblank(varargin{4});
            lev_Anal = varargin{5};
            if length(varargin)>5  && ~isempty(varargin{6})
                parDemo = varargin{6};
            else
                parDemo = '';
            end
            filename = [sig_Name '.mat'];
            pathname = utguidiv('WTB_DemoPath',filename);
        end

        if loadFLAG
            % Loading file.
            %--------------
            wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitLoad'));
            fullName = fullfile(pathname,filename);
            [fileStruct,err] = wfileinf(fullName);
            if ~err
                try
                    load_STRUCT = load(fullName,'-mat');
                catch 
                    err = 1;
                    msg = getWavMSG('Wavelet:commongui:ErrLoadFile_2',filename);
                end
            end
            if ~err
                % Keep only numeric values.
                %--------------------------
                dum = struct2cell(fileStruct);
                dumClass = dum(4,:);
                idxClass = ~strcmp(dumClass,'double') & ...
                    ~strcmp(dumClass,'uint8') & ...
                    ~strcmp(dumClass,'sparse');                
                fileStruct(idxClass) = [];
                err = isempty(fileStruct);
            end

            if ~err
                % Keep only one dim values.
                %--------------------------
                dum = struct2cell(fileStruct);
                dumSize = dum(2,:);
                dumSize = cat(1,dumSize{:});
                mini    = min(dumSize,[],2);
                maxi    = max(dumSize,[],2);
                fileStruct(mini~=1 | maxi<2) = [];
                err = isempty(fileStruct);
            end

            if ~err
                err = 1;
                switch tool_OPT
                    case 'denest'
                        xdata = load_STRUCT.(fileStruct(1).name);
                        ydata = ones(size(xdata));
                        err = 0;

                    case {'fixreg','storeg'}
                        % Seek X and Y values.
                        %---------------------
                        dum = struct2cell(fileStruct);
                        dum = lower(dum(1,:));
                        idxVarSET = 1:length(dum);
                        flagX = 0;
                        flagY = 0;
                        idx_Xdata = find(strcmp(dum,'xdata'),1,'first');
                        if ~isempty(idx_Xdata)
                            flagX = 1;
                            idxVarSET = setdiff(idxVarSET,idx_Xdata);
                        else
                            idxSET = find(strncmp('x',dum,1),1,'first');
                            if ~isempty(idxSET)
                                flagX = 1;
                                idx_Xdata = idxSET(1);
                                idxVarSET = setdiff(idxVarSET,idx_Xdata);
                            end
                        end
                        idx_Ydata = find(strcmp(dum,'ydata'),1,'first');
                        if ~isempty(idx_Ydata)
                            flagY = 1;
                            idxVarSET = setdiff(idxVarSET,idx_Ydata);
                        else
                            idxSET = find(strncmp('y',dum,1),1,'first');
                            if ~isempty(idxSET)
                                flagY = 1;
                                idx_Ydata = idxSET(1);
                                idxVarSET = setdiff(idxVarSET,idx_Ydata);
                            end
                        end
                        if ~flagX && ~isempty(idxVarSET)
                            flagX = 1;
                            idx_Xdata = idxVarSET(1);
                            idxVarSET(1) = [];
                        end
                        if ~flagY && ~isempty(idxVarSET)
                            flagY = 1;
                            idx_Ydata = idxVarSET(1);
                        end
                        if ~isempty(idx_Xdata)
                            xdata = load_STRUCT.(fileStruct(idx_Xdata).name);
                        end
                        if ~isempty(idx_Ydata)
                            ydata = load_STRUCT.(fileStruct(idx_Ydata).name);
                        end
                        if flagX && ~flagY
                            flagY = 1;
                            ydata = xdata;
                            xdata = 1:length(ydata);

                        elseif flagY && ~flagX
                            flagX = 1;
                            xdata = 1:length(ydata);
                        end
                        if flagX && flagY && (length(xdata)==length(ydata))
                            err = 0;
                        end
                end
            end
            if err
                msg = getWavMSG('Wavelet:commongui:ErrLoadFile_3');
            elseif ~isreal(xdata) || ~isreal(ydata)
                msg = { ...
                    getWavMSG('Wavelet:commongui:ErrLoadFile_4',filename),' '};
                err = 1;
            end
            if err
                wwaiting('off',win_tool);
                errordlg(msg, ...
                    getWavMSG('Wavelet:commongui:LoadERROR'),'modal');
                return
            end
            sig_Name = strtok(filename,'.');
            
        elseif isequal(tool_OPT,'denest')
            ydata = ones(size(xdata));
            filename = sigInfos.filename;
            pathname = sigInfos.pathname;
            sig_Name = sigInfos.name;
            
        elseif isequal(tool_OPT,'wrksreg')
           xdata = input_VAL.xdata; 
           ydata = input_VAL.ydata;
           filename = '';
           pathname = '';
           tool_OPT = 'storeg';
        end
        sig_Size = length(xdata);
        xbounds  = [min(xdata),max(xdata)];

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitClean'));

        % Tool Settings.
        %---------------
        levm   = wmaxlev(sig_Size,'haar');
        levmax = min(levm,NB_max_lev);
        if isequal(option,'demo')
            anaPar = {'wav',wav_Name};
        else
            wav_Name = cbanapar('get',win_tool,'wav');
            lev_Anal = NB_def_lev;
            anaPar = {};
        end
        strlev = int2str((1:levmax)');
        anaPar = {anaPar{:},'n_s',{sig_Name,sig_Size}, ...
                  'lev',{'String',strlev,'Value',lev_Anal}}; %#ok<CCAT>
        defaultBIN = min([def_DefBIN,fix(sig_Size/4)]);
        minBIN     = min([def_MinBIN,defaultBIN]);            
        maxBIN     = sig_Size;     

        % Store tool settings & analysis parameters.
        %------------------------------------------- 
        toolATTR.toolMode  = tool_OPT;
        toolATTR.toolState = 'ini';
        toolATTR.level     = lev_Anal;
        toolATTR.wname     = wav_Name;
        toolATTR.NBClasses = defaultBIN;
        wfigmngr('storeValue',win_tool,'WDRE_toolATTR',toolATTR);

        % Store analysis parameters.
        %--------------------------- 
        wmemtool('wmb',win_tool,n_membloc2,ind_status,0);
 
        wmemtool('wmb',win_tool,n_membloc1,   ...
                       ind_filename,filename, ...
                       ind_pathname,pathname, ...
                       ind_sig_name,sig_Name, ...
                       ind_xdata,xdata, ...
                       ind_ydata,ydata, ...
                       ind_xbounds,xbounds ...
                       );

        % Clean , Set analysis & GUI values.
        %-----------------------------------
        dynvtool('stop',win_tool)
        utthrset('stop',win_tool);
        wdretool('clean',win_tool,option);
        cbanapar('set',win_tool,anaPar{:});

        % Set bins.
        %-----------
        set(sli_bin,'Min',minBIN,'Value',defaultBIN,'Max',maxBIN)
        set(edi_bin,'String',int2str(defaultBIN));

        % Setting axes and UIC. 
        %----------------------
        wdretool('position',win_tool,lev_Anal);
        wdretool('Enable',win_tool,'ini','on');
        wdretool('set_axes',win_tool);

        % Plot.
        %------
        color   = colors.sigColor;
        linProp = {...
            'Parent',axe_L_1, ...
            'Color',color,    ...
            'LineStyle','none',...
            'Marker','o',     ...
            'MarkerSize',2,   ...
            'MarkerEdgeColor',color, ...
            'MarkerFaceColor',color, ...
            'Tag',tag_ori     ...
            };
        
        switch tool_OPT
          case 'denest'
            xval = linspace(xbounds(1),xbounds(2),sig_Size);
            line(linProp{:},'XData',xval,'YData',xdata);
            ylim = getylim(xdata);
            set(axe_L_1,'XLim',xbounds,'YLim',ylim,'XTick',[],'XTickLabel',[])
            wtitle(getWavMSG('Wavelet:commongui:Str_Data'),'Parent',axe_L_1)
            color  = colors.denColor;
            his    = wgethist(xdata,minBIN);
            wplothis(axe_L_2,his,color);
            strTitle = getWavMSG('Wavelet:divGUIRF:X_NbBinHis',minBIN);
            wtitle(strTitle,'Parent',axe_L_2)
            wdretool('set_Bins',win_tool);
            
          case {'fixreg','storeg'}
            lin_ori = line(linProp{:},'XData',xdata,'YData',ydata);
            utthrw1d('set',win_tool,'handleORI',lin_ori);
            ylim = getylim(ydata);
            set(axe_L_1,'YLim',ylim)          
            wtitle(getWavMSG('Wavelet:divGUIRF:Data_XY'),'Parent',axe_L_1)
            if tool_OPT(1)=='s' , wdretool('set_Bins',win_tool); end
        end

        % Plotting Processed data.
        %------------------------
        wdretool('plot_Processed_Data',win_tool);

        % if DEMO, analyze and estimate.
        %-------------------------------
        if isequal(option,'demo')
            wdretool('decompose',win_tool);
            if ~isempty(parDemo)
                 utthrw1d('demo',win_tool,'wdre',parDemo);
            end
            wdretool('estimate',win_tool);
            wdretool('show_lin_den',win_tool,'On')
        end
        cbanapar('Enable',win_tool,'On');

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'save'
        % Testing file.
        %--------------
        switch toolMode
          case {'fixreg','storeg'}
              dialName = getWavMSG('Wavelet:divGUIRF:Save_EstFun');
          case 'denest'
              dialName = getWavMSG('Wavelet:divGUIRF:Save_EstDen');
        end
        [filename,pathname,ok] = utguidiv('test_save',win_tool, ...
                                     '*.mat',dialName);
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitSave')); 

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end

        % Get de-noising parameters & de-noised signal.
        %-----------------------------------------------
        toolATTR = wfigmngr('getValue',win_tool,'WDRE_toolATTR');
        NB_lev = toolATTR.level;
        wname  = toolATTR.wname; %#ok<NASGU>
        [thrStruct,hdl_den] = utthrw1d('get',win_tool,...
                                 'thrstruct','handleTHR');
        thrParams = {thrStruct(1:NB_lev).thrParams}; %#ok<NASGU>
        xdata = get(hdl_den,'XData'); %#ok<NASGU>
        ydata = get(hdl_den,'YData'); %#ok<NASGU>
        try
          save([pathname filename],'xdata','ydata','thrParams','wname');
        catch %#ok<*CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end
   
        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'exp_wrks'
        type_EXP = varargin{2};
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitExportDat'));
        switch type_EXP
            case 'DEN'
                varNAM = 'dens_EST';
            case 'REG'
                varNAM = 'est_FUN';
        end
        hdl_den = utthrw1d('get',win_tool,'handleTHR');
        xdata = get(hdl_den,'XData');
        ydata = get(hdl_den,'YData');
        S = struct('xdata',xdata,'ydata',ydata);
        wtbxexport(S,'name',varNAM,'title',type_EXP);
        wwaiting('off',win_tool);        
        
    case 'decompose'
    
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Clean HDLG.
        %---------------
        utthrw1d('clean_thr',win_tool);
        wdretool('show_lin_den',win_tool,'off')

        % Get analyzis parameters.
        %-------------------------
        [wname,NB_lev] = cbanapar('get',win_tool,'wav','lev');
        NBClasses = round(get(sli_bin,'Value'));

        % Tool Settings.
        %---------------
        toolATTR.toolState = 'dec';
        toolATTR.level     = NB_lev;
        toolATTR.wname     = wname;
        toolATTR.NBClasses = NBClasses;
        wfigmngr('storeValue',win_tool,'WDRE_toolATTR',toolATTR);

        % Get Handles.
        %-------------
        indic_vis_lev = getLevels(NB_lev,yLevelDir);

        % Clean axes
        %------------
        axes2clean = [axe_R_2,axe_cfs,axe_det,axe_app];
        obj2del = findobj(axes2clean,'Type','line');
        delete(obj2del)

        % Get X bounds values.
        %---------------------
        xbounds = wmemtool('rmb',win_tool,n_membloc1,ind_xbounds);        
        xmin = xbounds(1);  xmax = xbounds(2);

        % Compute.
        %---------
        sig_pro = wmemtool('rmb',win_tool,n_membloc3,ind_sig);
        [coefs,longs] = wavedec(sig_pro,NB_lev,wname);
        % [det,app] = getFullDecTec(coefs,longs,wname,NB_lev);
        wmemtool('wmb',win_tool,n_membloc3, ...
                       ind_coefs,coefs, ...
                       ind_longs,longs ...
                       );

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,NB_lev);
        for k = 1:NB_lev
            maxTHR(k) = max(abs(detcoef(coefs,longs,k)));
        end
        valTHR = wdretool('compute_LVL_THR',win_tool);
        valTHR = min(valTHR,maxTHR);

        % Plotting Coefficients.
        %-----------------------
        hdl_lines = NaN*ones(NB_max_lev,1);
        color = colors.cfsColor;
        len   = longs(end);
        viewSTEMS = 1;
        if viewSTEMS 
           dummy =  wfilters(wname);
           lf = length(dummy);
        end
        x_cfs = linspace(xbounds(1),xbounds(2),len);
        for j = 1:NB_lev
            k       = indic_vis_lev(j);
            axe_act = axe_cfs(k);
            cfs = detcoef(coefs,longs,k);
            tag = ['cfs_' int2str(k)];
            ybounds = [-valTHR(k) , valTHR(k) , -maxTHR(k) , maxTHR(k)];            
            if ~viewSTEMS
                cfs = cfs(ones(1,2^k),:);
                cfs = wkeep1(cfs(:)',len);                
                hdl_lines(k) = plotline(axe_act,x_cfs,cfs,color,tag,0.5,ybounds);
            else
                ld = length(cfs);
                xd = coefsLOC(1:ld,k,lf,len);                
                x_tmp = x_cfs(xd);               
                hh = plotstem(axe_act,x_tmp,cfs,color,1,tag,ybounds);
                hdl_lines(k) = hh(3);
            end
            utthrw1d('plot_dec',win_tool,k,{maxTHR(k),valTHR(k),xmin,xmax,k});
        end

        i_axe_cfs_max = indic_vis_lev(NB_lev);
        xt = get(axe_app,{'XTick','XTickLabel'});
        set([axe_det,axe_cfs],'XTick',[],'XTickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
           'XTick',xt{1},'XTickLabel',xt{2}, ...
           'XtickMode','auto','XTickLabelMode','auto' ...
           );
        set(axe_hdl,'XLim',[xmin xmax])
        set(txt_hdl(end),'String',['a' wnsubstr(abs(NB_lev))]);
  
        % Dynvtool Attachment.
        %---------------------
        if ~isequal(toolMode,'denest')
           axe_IND = []; axe_CMD = axe_hdl;       
        else
           axe_IND = axe_hdl(1); axe_CMD = axe_hdl(2:end);
        end
        dynvtool('init',win_tool,axe_IND,axe_CMD,[],[1 0],'','','')

        % Initialization of Denoising structure.
        %---------------------------------------
        utthrw1d('set',win_tool,...
            'thrstruct',{xmin,xmax,valTHR,hdl_lines},'intdepthr',[]);

        % Enabling HDLG.
        %---------------
        wdretool('Enable',win_tool,'dec','on');

        % Setting prog status.
        %----------------------
        wmemtool('wmb',win_tool,n_membloc2,ind_status,1);

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'estimate'
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Disable De-noising Tool.
        %---------------------------
        utthrw1d('Enable',win_tool,'off');

        % Read Tool Memory Block.
        %-----------------------
        [coefs,longs] = wmemtool('rmb',win_tool,n_membloc3,ind_coefs,ind_longs);
        NB_lev    = toolATTR.level;
        wname     = toolATTR.wname;
        NBClasses = toolATTR.NBClasses;
        indic_vis_lev = getLevels(NB_lev,yLevelDir);

        % De-noising & Plot de-noised signal.
        %------------------------------------
        cden = utthrw1d('den_M2',win_tool,coefs,longs);
        xbounds = wmemtool('rmb',win_tool,n_membloc1,ind_xbounds);
        xmin = xbounds(1); xmax = xbounds(2);
        xval = linspace(xmin,xmax,NBClasses);
        [det,app,sig_est] = getFullDecTec(cden,longs,wname,NB_lev);

        % Reset dynvtool.
        %----------------
        dynvtool('get',win_tool,0,'force');

        % Plotting details.
        %------------------
        color = colors.detColor;
        for j = 1:NB_lev
            k   = indic_vis_lev(j);
            tag = ['det_' int2str(k)];
            plotline(axe_det(k),xval,det(k,:),color,tag);
        end

        % Plotting approximation.
        %------------------------
        color = colors.appColor;
        plotline(axe_app,xval,app,color,tag_app);
        set(txt_hdl(end),'String',['a' wnsubstr(abs(NB_lev))]);

        % Plotting Estimation.
        %---------------------
        color = colors.estColor;
        if ~isequal(toolMode,'denest')
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            set(lin_den,'YData',sig_est);
        end
        lin_den = plotline(axe_R_2,xval,sig_est,color,tag_est);
        i_axe_cfs_max = indic_vis_lev(NB_lev);
        xt = get(axe_app,{'XTick','XTickLabel'});
        set([axe_det,axe_cfs],'XTick',[],'XTickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
           'XTick',xt{1},'XTickLabel',xt{2}, ...
           'XtickMode','auto','XTickLabelMode','auto' ...
           );

        % Dynvtool Attachment.
        %---------------------
        if ~isequal(toolMode,'denest')
           axe_IND = []; axe_CMD = axe_hdl;       
        else
           axe_IND = axe_hdl(1); axe_CMD = axe_hdl(2:end);
        end
        dynvtool('init',win_tool,axe_IND,axe_CMD,[],[1 0],'','','')

        % Enabling HDLG.
        %---------------
        utthrw1d('set',win_tool,'handleTHR',lin_den);
        utthrw1d('Enable',win_tool,'on');
        wdretool('Enable',win_tool,'den','on');

        % Storing tool State.
        %--------------------
        toolATTR.toolState = 'den';
        wfigmngr('storeValue',win_tool,'WDRE_toolATTR',toolATTR);
        
        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'show_lin_den'
        if isequal(toolMode,'denest') , return; end
        lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
        ok = ishandle(lin_den(1));
        if length(varargin)>1
            vis = lower(varargin{2});
            if isequal(vis,'on') && ok , val = 1; else val = 0; end 
            set(chk_den,'Value',val);
        else
            vis = getonoff(get(chk_den,'Value'));
            if ~ok , set(chk_den,'Value',0); end
        end
        
        if ok , set(lin_den,'Visible',vis); end
        wtitle(getWavMSG('Wavelet:divGUIRF:Data_XY'),'Parent',axe_L_1)
        wtitle(getWavMSG('Wavelet:divGUIRF:ProcessData_XY'),'Parent',axe_R_1)

    case 'position'
        NB_lev  = varargin{2};
        set(chk_den,'Visible','off');
        pos_old = utthrw1d('get',win_tool,'position');
        utthrw1d('set',win_tool,'position',{1,NB_lev})
        pos_new = utthrw1d('get',win_tool,'position');
        ytrans  = pos_new(2)-pos_old(2);
        pos_chk = get(chk_den,'Position');
        pos_chk(2) = pos_chk(2)+ytrans;
        switch toolMode
          case 'denest' , vis_chk = 'off';
          otherwise ,     vis_chk = 'on';
        end
        set(chk_den,'Position',pos_chk,'Visible',vis_chk);

    case 'upd_lev'
        pop_lev = varargin{2};
        if ~ishandle(pop_lev)
            handles = guihandles(gcbf);
            pop_lev = handles.Pop_Lev;
        end
        lev_New = get(pop_lev,'Value');
        wdretool('position',win_tool,lev_New);
        wdretool('set_axes',win_tool);
        lev_Anal = toolATTR.level;
        flagView = 2;
        if isequal(lev_New,lev_Anal)
            state =  toolATTR.toolState;
            switch state
                case 'ini' 
                    flagView = 1;
                    wdretool('Enable',win_tool,'ini');
                case 'dec'  
                    wdretool('Enable',win_tool,'dec');
                case 'den' 
                    val = get(chk_den,'Value');
                    wdretool('Enable',win_tool,'dec','on');
                    wdretool('Enable',win_tool,'den','on');
                    set(chk_den,'Value',val);
            end
        else
            flagView = 0;
            wdretool('Enable',win_tool,'ini');
        end
        if flagView<2
            wdretool('show_lin_den',win_tool,'off')
            axe_off = [axe_R_2,axe_app,axe_det];
            axe_off = axe_off(ishandle(axe_off));
            lin_Off = findobj(axe_off,'Type','line');
            set(lin_Off,'Visible','off');
        end

    case 'upd_bin'
        typ_upd = varargin{2};
        switch typ_upd
          case 'sli'
            nbOld = round(str2num(get(edi_bin,'String')));
            nbNew = round(get(sli_bin,'Value'));

          case 'edi'
            sliVal = get(sli_bin,{'Min','Value','Max'});
            minNb = sliVal{1};
            nbOld = sliVal{2};
            maxNb = sliVal{3};
            nbNew = round(str2num(get(edi_bin,'String')));
            if isempty(nbNew) || (nbNew<minNb) || (nbNew>maxNb)
               nbNew = nbOld;
            end
        end
        set(edi_bin,'String',int2str(nbNew));
        set(sli_bin,'Value',nbNew)
        if isequal(nbNew,nbOld) , return; end
        wdretool('clean',win_tool,'bin');

    case 'compute_LVL_THR'
        [numMeth,meth,alfa] = utthrw1d('get_LVL_par',win_tool); %#ok<ASGLU>
        [coefs,longs] = wmemtool('rmb',win_tool,n_membloc3,ind_coefs,ind_longs);
        switch toolMode
          case 'denest'
            varargout{1}  = wthrmngr('dw1ddenoDEN',meth,coefs,longs,alfa); 
          case {'fixreg','storeg'}
            varargout{1}  = wthrmngr('dw1ddenoLVL',meth,coefs,longs,alfa);
        end

    case 'update_LVL_meth'
        wdretool('clear_GRAPHICS',win_tool);
        valTHR = wdretool('compute_LVL_THR',win_tool);
        utthrw1d('update_LVL_meth',win_tool,valTHR);
 
    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_tool,n_membloc2,ind_status);
        if status<1 , return; end

        wdretool('Enable',win_tool,'den','off');
        wdretool('show_lin_den',win_tool,'off')
        axe_off = [axe_R_2,axe_app,axe_det];
        axe_off = axe_off(ishandle(axe_off));
        lin_Off = findobj(axe_off,'Type','line');
        set(lin_Off,'Visible','off');

    case {'enable','Enable'}
        type = varargin{2};
        if length(varargin)>2 , enaVal = varargin{3}; else enaVal = 'on'; end
        switch type
          case 'ini'
            set([men_sav;m_exp_sig;chk_den],'Enable','off');
            utthrw1d('status',win_tool,'off');
            set([pus_dec;sli_bin;edi_bin],'Enable','on');

          case 'dec'
            NB_lev = toolATTR.level;
            set(chk_den,'Value',0);
            set([men_sav;m_exp_sig;chk_den],'Enable','off');
            utthrw1d('status',win_tool,'on');
            utthrw1d('Enable',win_tool,'on');
            utthrw1d('Enable',win_tool,enaVal,1:NB_lev);

          case 'den'
            set([men_sav;m_exp_sig;chk_den],'Enable',enaVal);
            utthrw1d('enable_tog_res',win_tool,enaVal);
            if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
            wmemtool('wmb',win_tool,n_membloc2,ind_status,status);
        end

    case 'clean'
        calling_opt = varargin{2};        
        wdretool('show_lin_den',win_tool,'off')
        lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
        lin_den = lin_den(ishandle(lin_den));
        delete(lin_den);
        wmemtool('wmb',win_tool,n_membloc2,ind_lin_den,[NaN,NaN]); 
        switch calling_opt
          case {'load','demo'}
            obj2del = [findobj(axe_hdl,'Type','line'); ...
                       findobj(axe_hdl,'Type','patch')];
            delete(obj2del)
            switch toolMode
              case 'fixreg'
                win_title = getWavMSG('Wavelet:divGUIRF:Reg1D_FixDes');
                set(win_tool,'Name',win_title);
              case 'storeg'
                win_title = getWavMSG('Wavelet:divGUIRF:Reg1D_StoDes');
                set(win_tool,'Name',win_title);
            end
            sig_name = wmemtool('rmb',win_tool,n_membloc1,ind_sig_name);
            cbanapar('set',win_tool,'nam',sig_name);
            utthrw1d('clean_thr',win_tool);

          case 'bin'
            switch toolMode
              case 'denest'  , axetoClean = axe_hdl([2,4:end]);
              case {'fixreg','storeg'} , axetoClean = axe_hdl(2:end);
            end
            obj2del = [findobj(axetoClean,'Type','line'); ...
                       findobj(axetoClean,'Type','patch')];
            delete(obj2del)
            wdretool('set_Bins',win_tool);
            wdretool('plot_Processed_Data',win_tool);
            wdretool('Enable',win_tool,'ini');
        end

    case 'set_Bins'
        xdata  = wmemtool('rmb',win_tool,n_membloc1,ind_xdata);
        nbBINS = get(sli_bin,'Value');
        toolATTR.NBClasses = nbBINS;
        wfigmngr('storeValue',win_tool,'WDRE_toolATTR',toolATTR);
        switch toolMode
          case 'denest'
            color  = colors.denColor;
            his    = wgethist(xdata,nbBINS);
            wplothis(axe_R_1,his,color);
            wtitle(getWavMSG('Wavelet:divGUIRF:Binned_Data'),'Parent',axe_R_1)

          case 'fixreg'

          case 'storeg'
            color  = colors.denColor;
            his    = wgethist(xdata,nbBINS);
            wplothis(axe_L_2,his,color);
            wtitle(getWavMSG('Wavelet:divGUIRF:Hist_of_X'),'Parent',axe_L_2)
        end

    case 'plot_Processed_Data'
        [xdata,ydata] = wmemtool('rmb',win_tool,n_membloc1, ...
                                       ind_xdata,ind_ydata);
        [sig_pro,xval] = wedenreg(toolATTR,xdata,ydata);
        wmemtool('wmb',win_tool,n_membloc3,ind_sig,sig_pro);
   
        % Plotting Processed data & initial Estimation(s).
        %-------------------------------------------------        
        switch toolMode
          case {'fixreg','storeg'}
            color = colors.sigColor;
            plotline(axe_R_1,xval,sig_pro,color,tag_dat);            
            color = colors.estColor;
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            lin_den(1) = plotline(axe_L_1,xval,sig_pro,color,'',2);
            lin_den(2) = plotline(axe_R_1,xval,sig_pro,color,'',2);
            set(lin_den(1:2),'Visible','Off');
            ylim = getylim(ydata);
            set(axe_L_1,'YLim',ylim);
            wmemtool('wmb',win_tool,n_membloc2,ind_lin_den,lin_den);
            hdl_est = plotline(axe_R_2,xval,sig_pro,color,tag_est,2);
            set(hdl_est,'Visible','Off');
            set(axe_hdl,'XLim',[xval(1) xval(end)]);

          case {'denest'}
 
        end

    case 'set_axes'
        %*************************************************************%
        %** OPTION = 'set_axes' - Set axes positions and visibility **%
        %*************************************************************%
        if strcmp(toolMode,'nul') , return; end
        Pos_Graphic_Area = wmemtool('rmb',win_tool,n_membloc2,ind_gra_area);
        
        % Hide axes
        %-----------
        if ~isequal(toolMode,'denest')
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            if ishandle(lin_den(1)) , vis_den = get(lin_den(1),'Visible'); end
        end
        obj_in_axes = findobj(axe_hdl);
        set(obj_in_axes,'Visible','off');

        % Parameters initialization.
        %---------------------------
        NB_lev = cbanapar('get',win_tool,'lev');
        indic_vis_lev = getLevels(NB_lev,yLevelDir);
 
        % General graphical parameters initialization.
        %---------------------------------------------
        pos_win   = get(win_tool,'Position');
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.07*pos_win(4);
        ecy_mid_2 = ecy_mid_1;
        ecy_mid_3 = ecy_mid_1;
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_down  = ecy_up;
        h_gra_rem = Pos_Graphic_Area(4);
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(NB_max_lev-NB_lev))/NB_max_lev;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+...
                    (NB_lev-1)*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = 1;

        % Building data axes.
        %--------------------
        y_low_ini = y_low_ini-h_axe_std-ecy_up;
        pos_L_1 = get(axe_L_1,'Position');
        pos_L_1([2 4]) = [y_low_ini h_axe_std];
        set(axe_L_1,'Position',pos_L_1);
        pos_R_1 = get(axe_R_1,'Position');
        pos_R_1([2 4]) = [y_low_ini h_axe_std];
        set(axe_R_1,'Position',pos_R_1);
        axe_vis = [axe_L_1,axe_R_1];
        
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_1;
        pos_L_2  = get(axe_L_2,'Position');
        pos_L_2([2 4]) = [y_low_ini h_axe_std];
        set(axe_L_2,'Position',pos_L_2)
        pos_R_2  = get(axe_R_2,'Position');
        pos_R_2([2 4]) = [y_low_ini h_axe_std];
        set(axe_R_2,'Position',pos_R_2)
        switch toolMode
          case 'denest' , axe_vis = [axe_vis,axe_L_2,axe_R_2];
          case 'fixreg' , axe_vis = [axe_vis,axe_R_2];
          case 'storeg' , axe_vis = [axe_vis,axe_L_2,axe_R_2];
        end

        % Position for approximation axes on the right part.
        %---------------------------------------------------
        y_low_ini = y_low_ini-h_detail-ecy_mid_2;
        pos_axes = pos_R_2;
        pos_y   = [y_low_ini , h_detail];
        pos_axes([2 4]) = pos_y;
        set(axe_app,'Position',pos_axes);
        axe_vis = [axe_vis,axe_app];
        y_low_ini = y_low_ini-ecy_mid_3+ecy_det;

        % Position for details axes on the left part.
        %--------------------------------------------          
        pos_y  = [y_low_ini , h_detail];
        for j = 1:NB_lev
            i_axe    = indic_vis_lev(j);
            axe_act  = axe_cfs(i_axe);
            pos_axes = get(axe_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(axe_act,'Position',pos_axes);
            axe_vis = [axe_vis axe_act]; %#ok<AGROW>
        end
        i_axe_cfs_min = indic_vis_lev(1);
        i_axe_cfs_max = indic_vis_lev(NB_lev);

        % Position for details axes on the right part.
        %---------------------------------------------
        pos_y   = [y_low_ini , h_detail];
        for j = 1:NB_lev
            i_axe    = indic_vis_lev(j);
            axe_act  = axe_det(i_axe);
            pos_axes = get(axe_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(axe_act,'Position',pos_axes);
            axe_vis  = [axe_vis axe_act]; %#ok<AGROW>
        end
        i_axe_det_min = indic_vis_lev(1);

        % Modification of app_text.
        %--------------------------
        status = wmemtool('rmb',win_tool,n_membloc2,ind_status);
        if status==0
            txt_app = txt_hdl(end);
            num_app = NB_lev;
            set(txt_app,'String',['a' wnsubstr(abs(num_app))]);
        end

        % Set axes.
        %-----------
        xt = get(axe_L_1,{'XTick','XTickLabel'});
        ind_axe_cfs = (i_axe_cfs_min:i_axe_cfs_max-1);
        set(axe_cfs(ind_axe_cfs),'XTick',[],'XTickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
            'XTick',xt{1},'XTickLabel',xt{2} , ...
            'XtickMode','auto','XTickLabelMode','auto' ...
            )
        titles = get([axe_cfs;axe_det],'title');
        titles = cat(1,titles{:});
        set(titles,'String','');
        obj_in_axes_vis = findobj(axe_vis);
        set(obj_in_axes_vis,'Visible','on');
        if ~isequal(toolMode,'denest')
            if ishandle(lin_den(1)) , set(lin_den,'Visible',vis_den); end
        end
       %  hdl_den = utthrw1d('get',win_tool,'handleTHR')
       %  set(hdl_den,'Color','g')
        
        % Setting axes title
        %--------------------
        switch toolMode
          case 'fixreg'
            wtitle(getWavMSG('Wavelet:divGUIRF:Data_XY'),'Parent',axe_L_1);
            wtitle(getWavMSG('Wavelet:divGUIRF:RegEst_YfX'),'Parent',axe_R_2);

          case 'storeg'
            wtitle(getWavMSG('Wavelet:divGUIRF:Data_XY'),'Parent',axe_L_1)
            wtitle(getWavMSG('Wavelet:divGUIRF:Hist_of_X'),'Parent',axe_L_2);
            wtitle(getWavMSG('Wavelet:divGUIRF:RegEst_YfX'),'Parent',axe_R_2);
            wtitle(getWavMSG('Wavelet:divGUIRF:ProcessData_XY'),'Parent',axe_R_1);

          case 'denest'
            wtitle(getWavMSG('Wavelet:commongui:Str_Data'),'Parent',axe_L_1);
            wtitle(getWavMSG('Wavelet:divGUIRF:X_NbBinHis',def_MinBIN),'Parent',axe_L_2);
            wtitle(getWavMSG('Wavelet:divGUIRF:Binned_Data'),'Parent',axe_R_1);
            wtitle(getWavMSG('Wavelet:divGUIRF:DenEstimate'),'Parent',axe_R_2);
        end
        wtitle(getWavMSG('Wavelet:commongui:Str_Details_Cfs'),'Parent',axe_cfs(i_axe_cfs_min));
        wtitle(getWavMSG('Wavelet:commongui:Str_Details'),'Parent',axe_det(i_axe_det_min));
        wtitle(getWavMSG('Wavelet:commongui:Str_Approximation'),'Parent',axe_app);

    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
function setDEMOS(m_demo,str_numwin,demoSET,sepFlag)

[nbDEM,nbVAL] = size(demoSET);
for k=1:nbDEM
    typ = demoSET{k,1};
    nam = demoSET{k,2};
    fil = demoSET{k,3};
    wav = demoSET{k,4};
    len = length(wav);
    wavDum = [wav , blanks(4-len)];
    lev = demoSET{k,5};
    if nbVAL>5
        par = demoSET{k,6};
    else
        par = [];
    end
    libel = getWavMSG('Wavelet:divGUIRF:WT_Example',wavDum,lev,nam);
    action = @(~,~)wdretool('demo', str_numwin,  ...
              typ , fil , wav  , lev , par );
    if sepFlag && (k==1)
        sep = 'on';
    else
        sep = 'off';
    end
    uimenu(m_demo,'Label',libel,'Separator',sep,'Callback',action);
end
%-----------------------------------------------------------------------------%
function indic_vis_lev = getLevels(level,yDir)

indic_vis_lev = (1:level)';
if yDir==-1 , indic_vis_lev = flipud(indic_vis_lev); end
%-----------------------------------------------------------------------------%
function [det,app,sig] = getFullDecTec(coefs,longs,wname,level)

det  = wrmcoef('d',coefs,longs,wname,1:level);
app  = wrcoef('a',coefs,longs,wname,level);
if nargout<3 , return; end
sig  = waverec(coefs,longs,wname);
%-----------------------------------------------------------------------------%
function ylim = getylim(sig)

mini = min(sig);
maxi = max(sig);
dy   = maxi-mini;
tol  = sqrt(eps);
if abs(dy)<tol
    maxi = maxi+tol;
    mini = mini-tol;
end
ylim = [mini maxi]+0.05*dy*[-1 1];
%-----------------------------------------------------------------------------%
function ll = plotline(axe,x,y,color,tag,LW,ylimplus)

if nargin<6 , LW = 0.5; end
vis = get(axe,'Visible');
ll = findobj(axe,'Type','line','Tag',tag);
if isempty(ll)
     ll = line(...
            'Parent',axe,'XData',x,'YData',y, ...
            'Color',color,'Visible',vis,'LineWidth',LW,'Tag',tag);
else
     set(ll,'XData',x,'YData',y,'Color',color,'Visible',vis,'Tag',tag);
end
if nargin<7
    ylim = getylim(y);
else
    ylim = getylim([y(:) ; ylimplus(:)]);
end
set(axe,'YLim',ylim);
%-----------------------------------------------------------------------------%
function loc = coefsLOC(idx,lev,lf,lx)
%COEFSLOC coefficient location

up  = idx;
low = idx;
for j=1:lev
    low = 2*low+1-lf;
    up  = 2*up;
end
loc = max(1,min(lx,round((low+up)/2)));
%-----------------------------------------------------------------------------%
function h = plotstem(axe,x,y,color,flgzero,tag,ylimplus)
%PLOTSTEM Plot discrete sequence data.

vis = get(axe,'Visible');
xAxeColor = get(axe,'XColor');
q = [min(x) max(x)];
h = NaN*ones(1,4);
h(1) = line(...
    'XData',[q(1) q(2)],'YData',[0 0],...
    'Parent',axe,'Color',xAxeColor ...
    );

indZ = find(abs(y)<eps);
xZ   = x(indZ);
yZ   = y(indZ);
x(indZ) = [];
y(indZ) = [];

n = length(x);
if n>0
    MSize = 3; Mtype = 'o';
    MarkerEdgeColor = color;
    MarkerFaceColor = color;
    xx = [x;x;NaN*ones(size(x))];
    yy = [zeros(1,n);y;NaN*ones(size(y))];
    h(2) = line(...
        'XData',xx(:),'YData',yy(:),...
        'Parent',axe,'LineStyle',...
        '-','Color',color...
        );
    h(3) = line(...
        'XData',x,'YData',y,...
        'Parent',axe,...
        'Marker',Mtype, ...
        'MarkerEdgeColor',MarkerEdgeColor, ...
        'MarkerFaceColor',MarkerFaceColor, ...
        'MarkerSize',MSize, ...
        'LineStyle','none',...
        'Color',color ...
        );
end

nZ = length(xZ);
if flgzero && (nZ>0)
    MSize = 3; Mtype = 'o';
    h(4) = line(...
        'XData',xZ,'YData',yZ,...
        'Parent',axe,...
        'Marker',Mtype, ...
        'MarkerEdgeColor',xAxeColor, ...
        'MarkerFaceColor',xAxeColor, ...
        'MarkerSize',MSize, ...
        'LineStyle','none',...
        'Color',xAxeColor...
        );
end

set(h(ishandle(h)),'Visible',vis,'Tag',tag);
if nargin<7
    ylim = getylim(y);
else
    ylim = getylim([y(:) ; ylimplus(:)]);
end
set(axe,'YLim',ylim);
%-----------------------------------------------------------------------------%
%=============================================================================%


%=============================================================================%
function [ysig,xsig,coefs,longs] = wedenreg(toolATTR,x,y)
%WEDENREG Density and Regression Estimation.

%== Initialisation ==========================================================%
toolMode  = toolATTR.toolMode;
level     = toolATTR.level;
wname     = toolATTR.wname;
NBClasses = toolATTR.NBClasses;
if nargin<3 , y = ones(size(x)); end
%============================================================================%

%== Traitement sur les couples (Xm,Ym) ======================================%
interpol = 0; % pas d'interpolation.
[sx,sy] = prepxy(toolMode,x,y,NBClasses,interpol);
ind_sx  = find(sx>0);
%============================================================================%

%============================================================================%
% Calcul de la grille en x.
%-------------------------
xmin = min(x);
xmax = max(x);
xsig = (0:NBClasses-1)/(NBClasses-1);
xsig = (xmax-xmin)*xsig+xmin;
%============================================================================%

%============================================================================%
% Normalization & Processed Data.
%-------------------------------
switch toolMode
    case {'denest'}
        ysig = sy;
        delta = xsig(2)-xsig(1);
        integ = sum(ysig)*delta;
        ysig = ysig/integ;
        
    case {'fixreg','storeg'}
        ysig = zeros(size(sx));
        ysig(ind_sx) = sy(ind_sx)./sx(ind_sx);
end

% Decomposition of processed signal.
%-----------------------------------
if nargout>2
    [coefs,longs] = wavedec(ysig,level,wname);
end
%============================================================================%
% INTERNAL FUNCTIONS for WEDENREG
%============================================================================%
%----------------------------------------------------------------------------%
function [sx,sy] = prepxy(option,x,y,NBClasses,interpol)
%PREPXY Traitement des couples (X,Y)
%   
%   [sx,sy] = prepxy(option,x,y,NBClasses,interpol)
%
%   Entrees:
%       option    = 'denest','fixreg','storeg'
%       (x,y)     = couples des donnees (y==1 pour 'estidens') 
%       NBClasses = Nombre de classes de la grille sur [0,1].
%                   La grille sur l'intervalle [0,1] est:
%                   xgrid = [0.5:NBClasses-0.5]/NBClasses
%
%   Sorties:
%       sx = nombre d'element dans chaque classe.
%       sy = somme des elements de chaque classe.
%               (sy == sx pour 'denest' )

%----------------------------------------%
% On change l'intervalle.                %
% On travaille sur l'intervalle [0,1]    %
%----------------------------------------%
xmin  = min(x);
xmax  = max(x);
x     = (x-xmin)/(xmax-xmin);
I1    = find(x==1);
x(I1) = x(I1)-eps;

%----------------------------------------%
% La grille sur l'intervalle [0,1] est : %
% xf = [0.5:NBClasses-0.5]/NBClasses     %
%----------------------------------------%
ex = round(NBClasses*x+0.5); 

%----------------------------------------%
% Recherche des valeurs repetees et      %
% manquantes de ex.                      %
% Calcul des sommes des valeurs de y     %
% pour chaque ex distinct.               %
%----------------------------------------%
lx = length(ex);
sx = full(sum(sparse(1:lx,ex,1,lx,NBClasses)));

switch option
   case 'denest' , sy = sx;
   case 'fixreg' , sy = full(sum(sparse(1:lx,ex,y,lx,NBClasses)));
   case 'storeg'
     sy = full(sum(sparse(1:lx,ex,y,lx,NBClasses)));
     if nargin<5 , return; end

     % PROBLEME DES VALEURS MANQUANTES: interpol = 1;
     %----------------------------------------------
     if interpol
         % Interpolation lineaire pour les trous.
         Ind_0  = find(sx==0);
         Ind_sx = (find(sx>0))';
         for k=1:length(Ind_0)
             Ik = Ind_0(k);
             av = find(Ind_sx<Ik);
             ap = find(Ind_sx>Ik);
             Iav = Ind_sx(av(length(av)));
             Iap = Ind_sx(ap(1));
             sy(Ik) = ( (sy(Iap)*(Ik-Iav))/sx(Iap)+ ...
                        (sy(Iav)*(Iap-Ik))/sx(Iav) )/(Iap-Iav);
             sx(Ik) = 1;
         end
     end
end
%----------------------------------------------------------------------------%
%============================================================================%
