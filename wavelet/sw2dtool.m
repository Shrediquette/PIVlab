function varargout = sw2dtool(option,varargin)
%SW2DTOOL Stationary Wavelet Transform 2-D tool.
%   VARARGOUT = SW2DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Mar-1998.
%   Copyright 1995-2020 The MathWorks, Inc.


% DDUX data logging
if nargin == 0 || nargin > 0 && ischar(option) && strcmpi(option,'create')
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "sw2dtool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 5;
def_lev_anal = 5;
def_nbcolors = 255;
str_dir_det  = ['h';'d';'v'];

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_membloc1    = 'MB_1';
ind_status    = 1;
ind_sav_menu  = 2;
ind_filename  = 3;
ind_pathname  = 4;
ind_img_name  = 5;
ind_img_t_nam = 6;
ind_NB_lev    = 7;
ind_wave      = 8;
nb1_stored    = 8;

% MB2.
%-----
n_membloc2   = 'MB_2';
ind_pus_dec  = 1;
ind_axe_hdl  = 2;
ind_txt_hdl  = 3;
ind_gra_area = 4;
nb2_stored   = 4;

% MB3.
%-----
n_membloc3 = 'MB_3';
ind_coefs  = 1;
% nb3_stored = 1;

if ~isequal(option,'create') , win_tool = varargin{1}; end
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing');

        % Window initialization.
        %-----------------------
        win_title = getWavMSG('Wavelet:divGUIRF:SW2D_Name');
        [win_tool,pos_win,win_units,~,...
           pos_frame0,Pos_Graphic_Area] = ...
             wfigmngr('create',win_title,winAttrb,...
                'ExtFig_WTMOTION',mfilename,1,1,0);
        set(win_tool,'Tag','WIN_sw2dtool')    
        if nargout>0 , varargout{1} = win_tool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_tool, ...
			getWavMSG('Wavelet:divGUIRF:II_D_Anal_Deno'),'SW2D_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_tool, ...
            getWavMSG('Wavelet:divGUIRF:SWT'),'SWT');
		wfighelp('addHelpItem',win_tool, ...
            getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');
		wfighelp('addHelpItem',win_tool, ...
            getWavMSG('Wavelet:commongui:HLP_LoadSave'),'SW2D_LOADSAVE');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngr('getmenus',win_tool,'file');
        uimenu(m_files, ...
            'Label',getWavMSG('Wavelet:commongui:Load_Image'), ...
            'Position',1,'Tag','Load_Img', ...
            'Callback',@(~,~)sw2dtool('load', win_tool)  ...
            );
        m_save = uimenu(m_files,...
            'Label',getWavMSG('Wavelet:commongui:SavDenImg'),...
            'Position',2,'Enable','Off',  ...
            'Tag','Save_Img', ...
            'Callback',@(~,~)sw2dtool('save', win_tool) ...
            );
        
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getWavMSG('Wavelet:commongui:GenerateMATLABDenoise'), ...
            'Position',pos+1,              ...
            'Enable','Off',                ...
            'Separator','On',              ...
            'Tag','Generate',               ...
            'Callback',                    ...
            @(~,~)wsaveprocess('sw2dtool', win_tool)  ...
            );
        wtbxappdata('set',win_tool,'M_GenCode',m_gen);
        
        m_demo = uimenu(m_files, ...
            'Label',getWavMSG('Wavelet:commongui:Lab_Example'), ...
            'Tag','Examples','Position',3);
        m_demoIDX = uimenu(m_demo, ...
            'Label',getWavMSG('Wavelet:commongui:Lab_IndImg'),...
            'Tag','Ind_Img','Position',1);
        m_demoCOL = uimenu(m_demo, ...
            'Label',getWavMSG('Wavelet:commongui:Lab_ColImg'),...
            'Tag','Col_Img','Position',2);
        uimenu(m_files, ...
            'Label',getWavMSG('Wavelet:commongui:Str_ImpImg'),'Position',4, ...
            'Enable','On','Separator','On',...
            'Tag','Import', ...
            'Callback',@(~,~)sw2dtool('load', win_tool,'wrks')  ...
            );
        m_exp_sig = uimenu(m_files, ...
            'Label',getWavMSG('Wavelet:commongui:Str_ExpImg'),'Position',5, ...
            'Enable','Off','Separator','Off',...
            'Tag','Export', ...
            'Callback',@(~,~)sw2dtool('exp_wrks', win_tool)  ...
            );
                   
        demoSET = {...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_Nwoman')   , ...
                'noiswom'  , 'haar', 3 , {'penallo',46.12} , 'BW' ; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_Nwoman')   , ...
                'noiswom'  , 'haar', 5 , {'penallo',48.62} , 'BW' ; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_Nwoman')   , ...
                'noiswom'  , 'db3' , 4 , {'penallo',NaN}   , 'BW'; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_NBarb')    , ...
                'nbarb1'   , 'db1' , 4 , {} , 'BW'; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_NSinsin')  , ...
                'noissi2d' , 'db1' , 2 , {} , 'BW'; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_jellyfish'), ...
                'jellyfish256' , 'db1' , 3 ,  {'penalhi',38} , 'COL'; ... 
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_woodsculp')    , ...
                'woodsculp256.jpg' , 'haar' , 4 , {'penalhi',38} , 'COL'; ...
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_NoisArmsCOL'), ...
                'noisarms.jpg' , 'db1' , 3 ,  {'penallo',88} , 'COL'; ...                 
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_NoisFlower'), ...
                'noisflower.jpg' , 'db1' , 3 ,  {'penallo',130} , 'COL'; ... 
          getWavMSG('Wavelet:moreMSGRF:EX2D_Name_NoisPeppers')    , ...
                'noiswpepper.jpg' , 'haar' , 4 , {'penalhi',160} , 'COL'; ...                
          };

        nbDEM = size(demoSET,1);
        for k=1:nbDEM
            nam = demoSET{k,1};
            fil = demoSET{k,2};
            wav = demoSET{k,3};
            lev = demoSET{k,4};
            par = demoSET{k,5};
            optIMG = demoSET{k,6};
            libel = getWavMSG('Wavelet:divGUIRF:WT_Example',wav,lev,nam);
            action = @(~,~)sw2dtool('demo', win_tool, fil , wav , lev, par, optIMG );
            if k==8 
                Sep = 'On'; 
            else
                Sep = 'Off';
            end
            if k<6 
                par = m_demoIDX; 
            else
                par = m_demoCOL;
            end
            uimenu(par,'Label',libel,'Separator',Sep,'Callback',action);
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitInit'));

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing-3; %-3
        str_pus_dec = getWavMSG('Wavelet:commongui:Str_DecImg');

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create',win_tool, ...
            'xloc',xlocINI,'top',ytopINI,...
            'Enable','off',        ...
            'wtype','dwt',         ...
            'deflev',def_lev_anal, ...
            'maxlev',max_lev_anal  ...
            );

        % Decompose pushbutton.
        %----------------------
        h_uic = 3*Def_Btn_Height/2;
        y_uic = toolPos(2)-h_uic-2*dy;
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        pos_pus_dec = [x_uic, y_uic, w_uic, h_uic];
        pus_dec = uicontrol(...
            'Parent',win_tool,      ...
            'Style','pushbutton',   ...
            'Units',win_units,       ...
            'Position',pos_pus_dec, ...
            'String',str_pus_dec,   ...
            'Enable','off',         ...
            'Tag','Pus_Dec',        ...
            'Interruptible','On'    ...
            );

        % Denoising tool.
        %-----------------
        ytopTHR = pos_pus_dec(2)-4*dy;
        utthrw2d('create',win_tool, ...
            'xloc',xlocINI,'top',ytopTHR,...
            'ydir',-1, ...
            'levmax',def_lev_anal,    ...
            'levmaxMAX',max_lev_anal, ...
            'status','Off',  ...
            'toolOPT','deno' ...
            );

        % Adding colormap GUI.
        %---------------------
        briflag = (max_lev_anal<6); 
        utcolmap('create',win_tool, ...
                 'xloc',xlocINI, ...
                 'briflag',briflag, ...
                 'Enable','off');

        % Callbacks update.
        %------------------
        hdl_den = utthrw2d('handles',win_tool);
        utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
        pop_lev = utanapar('handles',win_tool,'lev');

        cba_pop_lev = @(~,~)sw2dtool('update_level',win_tool, pop_lev);
        cba_pus_dec = @(~,~)sw2dtool('decompose',win_tool, pop_lev);
        set(pop_lev,'Callback',cba_pop_lev);
        set(pus_dec,'Callback',cba_pus_dec);

        % General graphical parameters initialization.
        %--------------------------------------------
        txtfontsize = 14;

        % Axes construction parameters.
        %------------------------------
        NB_lev    = max_lev_anal;
        bdx       = 0.08*pos_win(3);
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.08*pos_win(4);
        ecy_mid_2 = ecy_up;
        ecy_down  = ecy_up;
        ecy_det   = (0.04*pos_win(4))/1.4;
        w_gra_rem = Pos_Graphic_Area(3);
        h_gra_rem = Pos_Graphic_Area(4);
        w_left    = (w_gra_rem-3*bdx)/2;
        w_right   = w_left;
        w_medium  = w_left;
        w_detail  = (w_gra_rem-4*bdx)/3+bdx/2;
        x_left    = bdx;
        x_right   = x_left+w_left+5*bdx/4;
        x_medium  = (w_gra_rem-w_medium)/2;
        h_min     = h_gra_rem/4;
        h_max     = h_gra_rem/3;
        h_image   = (h_min*(NB_lev-1)+h_max*(max_lev_anal-NB_lev))/(max_lev_anal-1);
        h_histo   = h_gra_rem/8;
        h_gra_rem = h_gra_rem-h_histo-h_image-ecy_up-ecy_mid_1-ecy_mid_2;
        h_detail  = (h_gra_rem-ecy_down-(NB_lev-1)*ecy_det)/NB_lev;
        y_low_ini = pos_win(4);

        % Building data axes.
        %--------------------
        commonProp   = {...
           'Parent',win_tool,...
           'Visible','off',  ...
           'Units',win_units,...
           'Box','On'...
           };
        y_low_ini   = y_low_ini-h_image-ecy_up;
        pos_left    = [x_left y_low_ini w_left h_image];
        axe_left_1  = axes(commonProp{:},'Position',pos_left);
        pos_right   = [x_right y_low_ini w_right h_image];
        axe_right_1 = axes(commonProp{:},'Position',pos_right);

        y_low_ini   = y_low_ini-h_histo-ecy_mid_1;
        pos_medium  = [x_medium y_low_ini w_medium h_histo];
        axe_medium  = axes(commonProp{:},'Position',pos_medium);
        y_low_ini   = y_low_ini-ecy_mid_2+ecy_det;

        % Building histograms axes.
        %==========================
        axe_hist = zeros(3,NB_lev);
        commonProp = {commonProp{:},...
            'XTickLabelMode','manual','XTickLabel',[]}; %#ok<CCAT>

        % Building axes on the left part.
        %-------------------------------    
        txt_left = zeros(NB_lev,1);
        x_left   = bdx;
        y_left   = y_low_ini;
        pos_left = [x_left y_left w_detail h_detail];
        for j = 1:NB_lev
            k = NB_lev-j+1;
            pos_left(2) = pos_left(2)-pos_left(4)-ecy_det;
            axe_hist(1,k) = axes(commonProp{:}, ...
                                'Position',pos_left,'NextPlot','add'); %#ok<*LAXES>
            str_txt     = ['L' wnsubstr(k)];
            txt_left(k) = txtinaxe('create',str_txt, ...
                             axe_hist(1,k),'l','off','bold',txtfontsize);
        end

        % Building details axes on the middle part.
        %----------------------------------------
        x_mid   = x_left+w_detail+bdx/2;
        y_mid   = y_low_ini;
        pos_mid = [x_mid y_mid w_detail h_detail];
        for k = 1:NB_lev
            j = NB_lev-j+1;
            pos_mid(2)    = pos_mid(2)-pos_mid(4)-ecy_det;
            axe_hist(2,k) = axes(commonProp{:},'Position',pos_mid);
        end
        
        % Building details axes on the right part.
        %-----------------------------------------
        x_right   = x_mid+w_detail+bdx/2;
        y_right   = y_low_ini;
        pos_right = [x_right y_right w_detail h_detail];
        for j = 1:NB_lev
            k = NB_lev-j+1;
            pos_right(2)  = pos_right(2)-pos_right(4)-ecy_det;
            axe_hist(3,k) = axes(commonProp{:},'Position',pos_right);
        end

        %  Normalization.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_tool, ...
            Pos_Graphic_Area,'On');
        drawnow

        % Memory blocks update.
        %----------------------
        axes_hdl = {axe_left_1,axe_right_1,axe_medium,axe_hist};
        utthrw2d('set',win_tool,'axes',axe_hist);
        wmemtool('ini',win_tool,n_membloc1,nb1_stored);
        wmemtool('ini',win_tool,n_membloc2,nb2_stored);
        wmemtool('wmb',win_tool,n_membloc1, ...
            ind_status,0,        ...
            ind_sav_menu,m_save  ...
            );
        wtbxappdata('set',win_tool,'m_exp_sig',m_exp_sig);
        wmemtool('wmb',win_tool,n_membloc2, ...
            ind_pus_dec,pus_dec, ...
            ind_axe_hdl,axes_hdl,...
            ind_gra_area,Pos_Graphic_Area, ...
            ind_txt_hdl,txt_left ...
            );

        % End waiting.
        %---------------
        wwaiting('off',win_tool);

    case {'load','demo'}
        % Loading file.
        %--------------
        switch option
            case 'load'
                if length(varargin)<2       % LOAD IMAGE
                    imgFileType = getimgfiletype;
                    [imgInfos,img_ori,map,ok] = ...
                        utguidiv('load_img',win_tool,imgFileType, ...
                        getWavMSG('Wavelet:commongui:Load_Image'), ...
                        def_nbcolors);
                else
                    [imgInfos,img_ori,ok] = wtbximport('2d');
                    map = pink(def_nbcolors);
                end
                
            case 'demo'
                img_Name = deblank(varargin{2});
                wav_Name = deblank(varargin{3});
                lev_Anal = varargin{4};
                par_Demo = varargin{5};
                if length(varargin)<6
                    optIMG ='';
                else
                    optIMG = varargin{6};
                end
                [~,~,ext] = fileparts(img_Name);
                if isempty(ext)
                    filename = [img_Name '.mat'];
                else
                    filename = img_Name;
                end                
                pathname = utguidiv('WTB_DemoPath',filename);
                [imgInfos,img_ori,map,ok] = utguidiv('load_dem2D',win_tool, ...
                    pathname,filename,def_nbcolors,optIMG);
        end
        if ~ok, return; end
        flagIDX = length(size(img_ori))<3;
        setfigNAME(win_tool,flagIDX)
        

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitClean'));

        % Storing values. 
        %-----------------
        wmemtool('wmb',win_tool,n_membloc1, ...
            ind_status,0,        ...
            ind_filename,imgInfos.filename,  ...
            ind_pathname,imgInfos.pathname,  ...
            ind_img_name,imgInfos.name,      ...
            ind_img_t_nam,imgInfos.true_name ...
            );

        % Cleaning and setting GUI. 
        %--------------------------
        cbanapar('Enable',win_tool,'Off');
        dynvtool('stop',win_tool);
        ax_hdl  = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);
        ax_hdl  = [ax_hdl{1:3},ax_hdl{4}(:)'];
        obj2del = [findobj(ax_hdl,'Type','line');  ...
                   findobj(ax_hdl,'Type','patch'); ...
                   findobj(ax_hdl,'Type','image')];
        delete(obj2del)
        utthrw2d('clean_thr',win_tool);

        % Setting analysis  & GUI values.
        %--------------------------------
        levm   = wmaxlev(imgInfos.size(1:2),'haar');
        levmax = min(levm,max_lev_anal);
        if isequal(imgInfos.true_name,'X')
            img_Name = imgInfos.name;
        else
            img_Name = imgInfos.true_name;
        end
        if isequal(option,'demo')
            anaPar = {'wav',wav_Name};
        else
            lev_Anal = def_lev_anal;
            anaPar = {};
        end
        strlev = int2str((1:levmax)');
        anaPar = {anaPar{:},'n_s',{img_Name,imgInfos.size}, ...
                  'lev',{'String',strlev,'Value',lev_Anal}}; %#ok<CCAT>
        cbanapar('set',win_tool,anaPar{:});
        NB_ColorsInPal = size(map,1);
        if imgInfos.self_map 
            arg = map; 
        else
            arg = []; 
        end
        cbcolmap('set',win_tool,'pal',{'pink',NB_ColorsInPal,'self',arg});
        if length(imgInfos.size)>2
            vis_UTCOLMAP = 'Off';
        else
            vis_UTCOLMAP = 'On';
        end
        cbcolmap('Visible',win_tool,vis_UTCOLMAP);
        utthrw2d('set',win_tool,'position_bis',{1,lev_Anal})

        % Enabling HDLG.
        %---------------
        sw2dtool('Enable',win_tool,'ini','on');

        % Setting axes. 
        %--------------
        sw2dtool('set_axes',win_tool);

        % Initial drawing
        %----------------
        axe_hdl = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);
        axe_ori = axe_hdl{1};
        hdl_ori = image([1 imgInfos.size(1)],[1 imgInfos.size(2)], ...
            wd2uiorui2d('d2uint',img_ori),'Parent',axe_ori, ...
            'Tag','Img_ORI');
        wtitle(getWavMSG('Wavelet:divGUIRF:OriImg_I'),'Parent',axe_ori)
        utthrw2d('set',win_tool,'handleORI',hdl_ori);

        % Analyze and De-noise.
        %----------------------
        if isequal(option,'demo')
            sw2dtool('decompose',win_tool);
            if ~isempty(par_Demo)
                den_Meth = par_Demo{1};
                if length(par_Demo)>1
                    thr_Val  = par_Demo{2};
                else
                    thr_Val  = NaN;
                end
                if isequal(den_Meth,'penallo') || ...
                        isequal(den_Meth,'penalhi')
                    utthrw2d('demo',win_tool,'swt2',den_Meth,thr_Val);
                end
            end
            sw2dtool('denoise',win_tool);
        end
        cbanapar('Enable',win_tool,'On');

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'save'
        % Get de-noised signal.
        %----------------------
        hdl_den = utthrw2d('get',win_tool,'handleTHR');
        X = get(hdl_den,'CData');
        
        [wname,Lev_Anal] = wmemtool('rmb',win_tool,n_membloc1, ...
                ind_wave,ind_NB_lev); 
        valTHR = utthrw2d('get',win_tool,'allvalthr');
        valTHR = valTHR(:,1:Lev_Anal); 
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Deno_Img'),...
            win_tool,X,'wname',wname,'valTHR',valTHR);

    case 'exp_wrks'
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:Str_Image'));
        hdl_den = utthrw2d('get',win_tool,'handleTHR');
        X = get(hdl_den,'CData');
        wtbxexport(X,'name','sig_2D','title', ...
            getWavMSG('Wavelet:commongui:WaitExport'));
        wwaiting('off',win_tool);        
        
    case 'decompose'
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Get handles analysis parameters.
        %---------------------------------
        [wname,Lev_Anal] = cbanapar('get',win_tool,'wav','lev');
        hdl_ori = utthrw2d('get',win_tool,'handleORI');
        img_ori = get(hdl_ori,'CData');
        siz_ori = size(img_ori);
        siz_ori = siz_ori(1:2);
        pow = 2^Lev_Anal;
        if any(rem(siz_ori,pow))
            siz_sug = ceil(siz_ori/pow)*pow;
            wwaiting('off',win_tool);
            oriStr = ['(' int2str(siz_ori(1)) ',' int2str(siz_ori(2)) ')'];
            sugStr = ['(' int2str(siz_sug(1)) ',' int2str(siz_sug(2)) ')'];
            msg = getWavMSG('Wavelet:moreMSGRF:SWT_size_MSG',...
                        Lev_Anal,oriStr,sugStr);
            errargt(mfilename,msg,'msg');
            return
        end        


        % Clean HDLG.
        %---------------
        utthrw2d('clean_thr',win_tool);

        % Get Handles.
        %--------------------------------------------------------
        % ax_hdl = {axe_left_1 axe_right_1 axe_medium  axe_hist}
        %--------------------------------------------------------
        ax_hdl = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);

        % Clean axes.
        %------------
        axe_hist = ax_hdl{4};
        axes2clean = [ax_hdl{2};ax_hdl{3};axe_hist(:)];
        obj2del = [findobj(axes2clean,'Type','line');   ...
                   findobj(axes2clean,'Type','image');  ...
                   findobj(axes2clean,'Type','patch')   ...
                   ];
        delete(obj2del)
        set(axe_hist(:),'NextPlot','add')

        % Setting prog status.
        %----------------------
        wmemtool('wmb',win_tool,n_membloc1, ...
                       ind_status,1,ind_NB_lev,Lev_Anal,ind_wave,wname);

        % Clean reset axes limits.
        %-------------------------
        set([ax_hdl{1:2}],'XLim',[1 siz_ori(2)],'YLim',[1 siz_ori(1)])

        % Compute Decomposition.
        %------------------------
        wDEC = swt2(img_ori,Lev_Anal,wname);
        isRGB = ndims(wDEC) == 4 && size(wDEC,3) == 3;
        wmemtool('wmb',win_tool,n_membloc3,ind_coefs,wDEC);

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(3,Lev_Anal);
        valTHR = sw2dtool('compute_LVL_THR',win_tool);
        permDir = [1 3 2];
        index   = zeros(3,Lev_Anal);
        for k = 1:Lev_Anal
          for d=1:3 , index(d,k) = (permDir(d)-1)*Lev_Anal+k; end
        end
        for k=1:Lev_Anal
            for d=1:3
                ind = index(d,k);
                if isRGB 
                    curr_img = wDEC(:,:,:,ind); 
                else
                    curr_img = wDEC(:,:,ind);
                end
                curr_img = curr_img(:);
                tmp = max(abs(curr_img));
                if tmp<eps 
                    maxTHR(d,k) = 1; 
                else
                    maxTHR(d,k) = 1.1*tmp;
                end
            end
        end
        valTHR = min(maxTHR,valTHR);

        % Displaying details coefficients histograms.
        %--------------------------------------------
        dirDef   = 1;
        col_det  = wtbutils('colors','det',Lev_Anal);
        nb_bins  = 50;
        axeXColor = get(win_tool,'DefaultAxesXColor');
        for level = 1:Lev_Anal
            for direct=1:3
                ind = index(direct,level);
                if isRGB
                    curr_img = wDEC(:,:,:,ind); 
                else
                    curr_img = wDEC(:,:,ind);
                end
                curr_img = curr_img(:);
                axeAct   = axe_hist(direct,level);
                curr_color = col_det(level,:);
                his        = wgethist(curr_img,nb_bins);
                his(2,:)   = his(2,:)/length(curr_img);
                wplothis(axeAct,his,curr_color);
                if level>1
                    wxlabel('','Parent',axeAct);
                else
                    xlab = getWavMSG(['Wavelet:dw2dRF:Dir_Det_'  str_dir_det(direct)]);
                    wxlabel(xlab,'Color',axeXColor,'Parent',axeAct);
                end
                thr_val = valTHR(direct,level);
                thr_max = maxTHR(direct,level);
                ylim    = get(axeAct,'YLim');
                utthrw2d('plot_dec',win_tool,dirDef, ...
                          {thr_max,thr_val,ylim,direct,level,axeAct})
                xmax = 1.1*max([thr_max, max(abs(his(1,:)))]);
                set(axeAct,'XLim',[-xmax xmax]);
                set(findall(axeAct),'Visible','on');
            end
        end
        drawnow

        % Initialization of denoising structure.
        %----------------------------------------
        utthrw2d('set',win_tool,'valthr',valTHR,'maxthr',maxTHR);

        % Dynvtool Attachment.
        %---------------------
        axe_cmd = [ax_hdl{1:2}];
        dynvtool('init',win_tool,[],axe_cmd,[],[1 1],'','','','int')

        % Enabling HDLG.
        %---------------
        sw2dtool('Enable',win_tool,'dec','on');

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'denoise'
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Disable Denoising Tool.
        %-------------------------
        utthrw2d('Enable',win_tool,'off');

        % Get decomposition.
        %-------------------
        [wname,Lev_Anal] = wmemtool('rmb',win_tool,n_membloc1, ...
                                          ind_wave,ind_NB_lev);        
        wDEC = wmemtool('rmb',win_tool,n_membloc3,ind_coefs);
        isRGB = ndims(wDEC) == 3 && size(wDEC,3) == 3;
        valTHR = utthrw2d('get',win_tool,'allvalthr');
        valTHR = valTHR(:,1:Lev_Anal);
        rad_sof = wfindobj(win_tool,'tag','soft_Rad');
        v = get(rad_sof,'Value');
        if isequal(v,1) 
            typTHR = 's'; else 
            typTHR = 'h'; 
        end
        permDir = [1 3 2];
        for level = 1:Lev_Anal
            for kk=1:3
               ind = (permDir(kk)-1)*Lev_Anal+level;
               thr = valTHR(kk,level);
               if isRGB 
                   wDEC(:,:,:,ind) = wthresh(wDEC(:,:,:,ind),typTHR,thr);
               else
                   wDEC(:,:,ind) = wthresh(wDEC(:,:,ind),typTHR,thr);
               end
            end
        end

        % Plotting de-noised Image.
        %---------------------------
        img_den = iswt2(wDEC,wname);
        img_den = wd2uiorui2d('d2uint',img_den);
        axe_hdl = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);
        axe_ori = axe_hdl{1};
        axe_den = axe_hdl{2};
        axe_dif = axe_hdl{3};
        hdl_den = image(img_den,'Parent',axe_den,'Tag','Img_DEN');
        xylim   = get(axe_ori,{'XLim','YLim'});
        set(axe_den,'XLim',xylim{1},'YLim',xylim{2},'Visible','on');
        wtitle(getWavMSG('Wavelet:divGUIRF:Deno_I'),'Parent',axe_den);
        hdl_ori  = utthrw2d('get',win_tool,'handleORI');
        img_dif  = get(hdl_ori,'CData')-img_den;
        img_dif  = img_dif(:);
        nb_bins  = 80;
        color    = wtbutils('colors','sw2d','histRES');
        his      = wgethist(img_dif,nb_bins);
        his(2,:) = his(2,:)/length(img_dif);
        wplothis(axe_dif,his,color);
        wtitle(getWavMSG('Wavelet:divGUIRF:Hist_I_DI'),'Parent',axe_dif);

        % Memory blocks update.
        %----------------------
        utthrw2d('set',win_tool,'handleTHR',hdl_den);
        wmemtool('wmb',win_tool,n_membloc1,ind_status,1);

        % Dynvtool Attachment.
        %---------------------
        dynvtool('ini_his',win_tool,0);
        dynvtool('put',win_tool)

        % Enabling HDLG.
        %---------------
        utthrw2d('Enable',win_tool,'on');
        sw2dtool('Enable',win_tool,'den','on');

        % End waiting.
        %---------------
        wwaiting('off',win_tool);

    case 'update_level'
        pop_lev = varargin{2}(1);
        if ~ishandle(pop_lev)
            handles = guihandles(gcbf);
            pop_lev = handles.Pop_Lev;
        end
        lev_New  = get(pop_lev,'Value');
        [status,lev_Anal] = wmemtool('rmb',win_tool,n_membloc1,...
            ind_status,ind_NB_lev);
        utthrw2d('set',win_tool,'position_bis',{1,lev_New});
        sw2dtool('set_axes',win_tool);
        
        % Set axes Visibility
        %--------------------
        vis_InAxes = 'off';
        if isequal(lev_New,lev_Anal)
            switch status
                case -1 
                    sw2dtool('Enable',win_tool,'ini');
                case  0 
                    sw2dtool('Enable',win_tool,'dec');
                case  1 
                    vis_InAxes = 'on';
                    sw2dtool('Enable',win_tool,'dec','on');
                    sw2dtool('Enable',win_tool,'den','on');
            end
        else
            sw2dtool('Enable',win_tool,'ini');
        end
        
        % Get Handles.
        %--------------------------------------------------------
        % ax_hdl = {axe_left_1 axe_right_1 axe_medium  axe_hist}
        %--------------------------------------------------------
        ax_hdl  = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);
        axe_Off = [ax_hdl{2};ax_hdl{3}];
        obj_Off = [findobj(axe_Off,'Type','line');  ...
                   findobj(axe_Off,'Type','patch'); ...
                   findobj(axe_Off,'Type','image')];
        set(obj_Off,'Visible',vis_InAxes);
                
    case 'compute_LVL_THR'
        [numMeth,meth,alfa] = utthrw2d('get_LVL_par',win_tool); %#ok<ASGLU>
        wDEC = wmemtool('rmb',win_tool,n_membloc3,ind_coefs);
        varargout{1} = wthrmngr('sw2ddenoLVL',meth,wDEC,alfa);

    case 'update_LVL_meth'
        sw2dtool('clear_GRAPHICS',win_tool);
        valTHR = sw2dtool('compute_LVL_THR',win_tool);
        utthrw2d('update_LVL_meth',win_tool,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_tool,n_membloc1,ind_status);
        if status<1 , return; end

        % Disable Toggle and Menus.
        %---------------------------
        sw2dtool('Enable',win_tool,'den','off');

        % Get Handles.
        %-------------
        axe_hdl = wmemtool('rmb',win_tool,n_membloc2,ind_axe_hdl);
        axe_Off = [axe_hdl{2};axe_hdl{3}];
        obj_Off = [findobj(axe_Off,'Type','line');  ...
                   findobj(axe_Off,'Type','patch'); ...
                   findobj(axe_Off,'Type','image')];
        set(obj_Off,'Visible','off');

    case {'enable','Enable'}
        type  = varargin{2};
        m_save = wmemtool('rmb',win_tool,n_membloc1,ind_sav_menu);
        m_exp_sig = wtbxappdata('get',win_tool,'m_exp_sig');
        m_gen     = wtbxappdata('get',win_tool,'M_GenCode');
        m_SAV_EXP = [m_save,m_exp_sig,m_gen];        
        switch type 
          case 'ini'
            set(m_SAV_EXP,'Enable','off');
            pus_dec = wmemtool('rmb',win_tool,n_membloc2,ind_pus_dec);
            col_hdl = utcolmap('handles',win_tool,'cell');
            utthrw2d('status',win_tool,'off');
            set([pus_dec;double(col_hdl)],'Enable','on');

          case 'dec'
            nb_lev = wmemtool('rmb',win_tool,n_membloc1,ind_NB_lev);
            set(m_SAV_EXP,'Enable','off');
            utthrw2d('status',win_tool,'on');
            utthrw2d('Enable',win_tool,'on',1:nb_lev);
            wmemtool('wmb',win_tool,n_membloc1,ind_status,0);

          case 'den'
            enaVal = varargin{3};
            set(m_SAV_EXP,'Enable',enaVal);
            utthrw2d('enable_tog_res',win_tool,enaVal);
            if strncmpi(enaVal,'on',2) 
                status = 1; 
            else
                status = 0;
            end
            wmemtool('wmb',win_tool,n_membloc1,ind_status,status);
        end

    case 'set_axes'
        %*************************************************************%
        %** OPTION = 'set_axes' - Set axes positions and visibility **%
        %*************************************************************%
        pos_win = get(win_tool,'Position');
        [ax_hdl,Pos_Graphic_Area] = wmemtool('rmb',win_tool,n_membloc2,...
                                                   ind_axe_hdl,ind_gra_area);
        NB_lev = cbanapar('get',win_tool,'lev');

        % Hide axes
        %-----------
        ax_2_clean  = [ax_hdl{1:3},ax_hdl{4}(:)'];
        obj_in_axes = findobj(ax_2_clean);
        set(obj_in_axes,'Visible','off');

        % Plots.
        %--------------------------------------------------------
        % ax_hdl = {axe_left_1 axe_right_1 axe_medium  axe_hist} 
        %--------------------------------------------------------
        ax_l_1  = ax_hdl{1};
        ax_r_1  = ax_hdl{2};
        ax_med  = ax_hdl{3};
        ax_hist = ax_hdl{4};

        % General graphical parameters initialization.
        %---------------------------------------------
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.08*pos_win(4);
        ecy_mid_2 = ecy_up;
        ecy_down  = ecy_up;
        ecy_det   = (0.04*pos_win(4))/1.4;
        h_gra_rem = Pos_Graphic_Area(4);
        h_min     = h_gra_rem/4;
        h_max     = h_gra_rem/3;
        h_image   = (h_min*(NB_lev-1)+h_max*(max_lev_anal-NB_lev))/(max_lev_anal-1);
        h_histo   = h_gra_rem/8;
        h_gra_rem = h_gra_rem-h_histo-h_image-ecy_up-ecy_mid_1-ecy_mid_2;
        h_detail  = (h_gra_rem-ecy_down-(NB_lev-1)*ecy_det)/NB_lev;
        y_low_ini = 1;

        % Building data axes.
        %--------------------
        y_low_ini = y_low_ini-h_image-ecy_up;
        pos_axes  = get(ax_l_1,'Position');
        pos_axes([2 4]) = [y_low_ini h_image];
        set(ax_l_1,'Position',pos_axes);

        pos_axes = get(ax_r_1,'Position');
        pos_axes([2 4]) = [y_low_ini h_image];
        set(ax_r_1,'Position',pos_axes)

        y_low_ini = y_low_ini-h_histo-ecy_mid_1;
        pos_axes  = get(ax_med,'Position');
        pos_axes([2 4]) = [y_low_ini h_histo];
        set(ax_med,'Position',pos_axes)
        y_low_ini = y_low_ini-ecy_mid_2+ecy_det;

        % Position for histograms axes.
        %------------------------------   
        axeXColor = get(win_tool,'DefaultAxesXColor');        
        pos_y    = [y_low_ini , h_detail];
        axe_vis = zeros(1,3*NB_lev);
        idx_ax_act = 0;
        for level = NB_lev:-1:1
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            for direct=1:3
                idx_ax_act = idx_ax_act + 1;
                ax_act   = ax_hist(direct,level);
                pos_axes = get(ax_act,'Position');           
                pos_axes([2 4]) = pos_y;
                set(ax_act,'Position',pos_axes);
                axe_vis(idx_ax_act) = ax_act;
                if level>1
                    wxlabel('','Parent',ax_act);
                else
                    xlab = getWavMSG(['Wavelet:dw2dRF:Dir_Det_'  str_dir_det(direct)]);
                    wxlabel(xlab,'Color',axeXColor,'Parent',ax_act);
                end
            end           
        end
        axe_vis = [ax_l_1 , ax_r_1 , ax_med , axe_vis];

        % Setting axes visibility & title.
        %---------------------------------
        obj_in_axes_vis = findobj(axe_vis);
        set(obj_in_axes_vis,'Visible','on');
        wtitle(getWavMSG('Wavelet:divGUIRF:Img_I'),'Parent',ax_l_1);
        wtitle(getWavMSG('Wavelet:divGUIRF:Hist_I_DI'),'Parent',ax_med);
        wtitle(getWavMSG('Wavelet:divGUIRF:Deno_I'),'Parent',ax_r_1);
                    
    case 'close'

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

%--------------------------------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = getWavMSG('Wavelet:divGUIRF:SW2D_Nam_Ind');
else
    figNAME = getWavMSG('Wavelet:divGUIRF:SW2D_Nam_TC');
end
set(fig,'Name',figNAME);
%---------------------------------------------------------------------------

