function varargout = dw2dcomp(option,varargin)
%DW2DCOMP Discrete wavelet 2-D compression.
%   VARARGOUT = DW2DCOMP(OPTION,VARARGIN)
              
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
% ind_img_t_name = 4;
ind_img_size   = 5;
ind_nbcolors   = 6;
% ind_act_option = 7;
% ind_simg_type  = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2.1 and MB2.2.
%-----------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB1 (local).
%-------------
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_pop_mod    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

if ~isequal(option,'create') , win_compress = varargin{1}; end                
switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Btn_Height,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get','Def_Btn_Height','Y_Spacing','Def_FraBkColor');

        % Calling figure.
        %----------------
        win_caller = varargin{1};

        % Window initialization.
        %----------------------
        win_name =  getWavMSG('Wavelet:dw2dRF:NamWinCMP_2D');
        [win_compress,pos_win,win_units,~,pos_frame0] = ...
                 wfigmngr('create',win_name,'',...
                     'ExtFig_CompDeno',{mfilename,'cond'});
        set(win_compress,'UserData',win_caller,'Tag','DW2DCOMP');
        varargout{1} = win_compress;

		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_compress, ...
            getWavMSG('Wavelet:dw2dRF:HLP_ImgComp'),'DW2D_COMP_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_compress, ...
            getWavMSG('Wavelet:dw2dRF:HLP_CompProc'),'COMP_PROCEDURE');
		wfighelp('addHelpItem',win_compress, ...
            getWavMSG('Wavelet:dw2dRF:HLP_AvailMeth'),'COMP_DENO_METHODS');
		wfighelp('addHelpItem',win_compress, ...
            getWavMSG('Wavelet:dw2dRF:HLP_CompImg'),'COMP_IMAGES');

		% Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_compress,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Comp_Img'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2dcomp('save_synt', win_compress)  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_Coefficients'),   ...
            'Position',2,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2dcomp('save_cfs', win_compress)  ...
            );
        sav_menus(3) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:dw2dRF:Lab_Decomposition'),  ...
            'Position',3,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)dw2dcomp('save_dec', win_compress) ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABCompress')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('dw2dcomp', win_compress)  ...
            );
        wtbxappdata('set',win_compress,'M_GenCode',m_gen);
        

        % Begin waiting.
        %---------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal] = ...
        wmemtool('rmb',win_caller,n_param_anal, ...
            ind_img_name,   ...
            ind_img_size,   ...
            ind_wav_name,   ...
            ind_lev_anal    ...
            );
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        isBior = wavemngr('isbior',Wav_Fam);
        
        % To manage colormap tool for truecolor images.
        %----------------------------------------------
        vis_UTCOLMAP = wtbxappdata('get',win_caller,'vis_UTCOLMAP');
        wtbxappdata('set',win_compress,'vis_UTCOLMAP',vis_UTCOLMAP);

        % General parameters initialization.
        %-----------------------------------
        dy = Y_Spacing;
        dirval  = ['h';'d';'v'];
        str_pop_mod = {getWavMSG('Wavelet:dw2dRF:GLB_Thr'),...
            getWavMSG('Wavelet:dw2dRF:ByLev_Thr')};

        % Command & Graphic parts (common & global thresholding).
        %========================================================
        comFigProp = {'Parent',win_compress,'Units',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',Lev_Anal} ...
                    );

        % Popup for mode.
        %----------------
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-4*dy-h_uic;
        pos_pop_mod = [x_uic, y_uic, w_uic, h_uic];            
        pop_mod = uicontrol(comFigProp{:},...
            'Style','Popup',...
            'Position',pos_pop_mod,...
            'UserData',1,...
            'String',str_pop_mod...
            );
        cba_pop_mod = @(~,~)dw2dcomp('change_mode', ...
                          win_compress , pop_mod);
        set(pop_mod,'Callback',cba_pop_mod);

        % Global Compression tools.
        %-------------------------
        ytopTHR = pos_pop_mod(2)-4*dy;
        utthrgbl('create',win_compress,'toolOPT','dw2dcomp', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior,   ...
                 'caller',mfilename ...
                 );
        % Adding colormap GUI.
        %---------------------
        briflag = (Lev_Anal<6); 
        if Lev_Anal<6
            pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
            prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
            utcolmap('create',win_compress, ...
                     'xloc',xlocINI, ...
                     'bkcolor',Def_FraBkColor, ...
                     'briflag',briflag, ...
                     'enable','on');
            pop_pal_loc = cbcolmap('get',win_compress,'pop_pal');
            set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                            'UserData',prop_pal{3});
            set(win_compress,'Colormap',get(win_caller,'Colormap'));
            cbcolmap('Visible',win_compress,vis_UTCOLMAP);
        end
 
        
        % Displaying the window title.
        %-----------------------------
        strX = sprintf('%.0f',Img_Size(2));
        strY = sprintf('%.0f',Img_Size(1));
        str_nb_val   = [' (' strX ' x ' strY ')'];
        str_wintitle = getWavMSG('Wavelet:dw2dRF:Str_Win_Title',...
            Img_Name,str_nb_val,Lev_Anal,Wav_Name);
        wfigtitl('String',win_compress,str_wintitle,'on');
        drawnow


        % Common axes properties.
        %------------------------
        comAxeProp = [...
            comFigProp,    ...
            'Units',win_units,...
            'Box','On',       ...
            'Visible','off'   ...
            ];


        % General graphical parameters initialization.
        %--------------------------------------------
        bdx_l   = 0.10*pos_win(3);
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        w_graph = pos_frame0(1);
        if Lev_Anal<6
            bdy = 0.07*pos_win(4);
            ecy = 0.03*pos_win(4);
            div = 2.5;
        else
            bdy     = 0.06*pos_win(4);
            ecy     = 0.02*pos_win(4);
            div = 3.5;
        end
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        
        
        % Building axes for original image.
        %----------------------------------
        x_axe           = bdx;
        w_axe           = (w_graph-ecx-3*bdx/2)/2;
        h_axe           = (h_graph-bdy)/div;
        y_axe           = y_graph+h_graph-h_axe-bdy;
        cx_ori          = x_axe+w_axe/2;
        cy_ori          = y_axe+h_axe/2;
        cx_cmp          = cx_ori+w_axe+ecx;
        cy_cmp          = cy_ori;
        [w_used,h_used] = wpropimg(Img_Size,w_axe,h_axe,'pixels');
        pos_axe         = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1)    = axes(comAxeProp{:},'Position',pos_axe);
        axe_orig        = axe_datas(1);
        
        
        % Displaying original image.
        %---------------------------
        Img_Anal  = get(dw2drwcd('r_orig',win_caller),'CData');
        hdl_datas = [NaN;NaN];
        set(win_compress,'Colormap',get(win_caller,'Colormap'));
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal, ...
                            'Parent',axe_orig);
        wtitle(getWavMSG('Wavelet:dw2dRF:Ori_Img'),'Parent',axe_orig);

        % Building axes for compressed image.
        %------------------------------------
        pos_axe = [cx_cmp-w_used/2 cy_cmp-h_used/2 w_used h_used];
        xylim   = get(axe_orig,{'XLim','YLim'});
        axe_datas(2) = axes(comAxeProp{:},...
                            'Position',pos_axe,'XLim',xylim{1},'YLim',xylim{2});
        axe_comp = axe_datas(2);

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            dw2dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

        % Displaying perfos & legend.
        %----------------------------
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        w_graph = pos_frame0(1);
        w_axe  = (w_graph-ecx-3*bdx/2)/2;
        h_axe  = (h_graph-3*bdy)/2;
        x_axe = bdx;
        y_axe = y_graph+bdy;
        pos_axe_perfo = [x_axe y_axe w_axe h_axe];
        x_axe = bdx+w_axe+ecx;
        y_axe = y_graph+w_axe/3+bdy;
        h_axe = w_axe/3;
        pos_axe_legend = [x_axe y_axe w_axe h_axe];
        utthrgbl('displayPerf',win_compress, ...
                  pos_axe_perfo,pos_axe_legend,thresVALUES,n0SCR,rl2SCR,valTHR);
        [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
        utthrgbl('set',win_compress,'perfo',[perfl2,perf0]);
        drawnow

        % Command & Graphic parts (by Level thresholding).
        %=================================================
        % Compression tool.
        %-------------------
        utthrw2d('create',win_compress, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',-1, ...
                 'Visible','off', ...
                 'enable','on', ...
                 'levmax',Lev_Anal, ...
                 'levmaxMAX',Lev_Anal, ...
                 'isbior',isBior,  ...
                 'toolOPT','comp' ...
                 );

        % Building axes for histograms.
        %------------------------------
        x_axe    = bdx;
        y_axe    = y_graph+bdy;
        h_axe_I  = (h_graph-bdy)/div;        
        h_axe    = (h_graph-h_axe_I-3*bdy-(Lev_Anal-1)*ecy)/Lev_Anal;
        w_axe    = (w_graph-2*ecx-3*bdx/2)/3;
        pos_axe  = [x_axe y_axe w_axe h_axe];
        axe_hist = zeros(3,Lev_Anal);
        for k = 1:Lev_Anal
            pos_axe(1) = bdx_l;
            pos_axe(2) = y_graph+bdy+(k-1)*(h_axe+ecy);
            for direct=1:3
                axe_hist(direct,k) = axes(comAxeProp{:},'Position',pos_axe);
                pos_axe(1) = pos_axe(1)+pos_axe(3)+ecx;
            end
        end
        utthrw2d('set',win_compress,'axes',axe_hist);
        drawnow

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(3,Lev_Anal);
        valTHR = dw2dcomp('compute_LVL_THR',win_compress,win_caller);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        for d=1:3
            dir = dirval(d);
            for i=Lev_Anal:-1:1
                c   = detcoef2(dir,coefs,sizes,i);
                tmp = max(abs(c(:)));
                if tmp<eps
                    maxTHR(d,i) = 1;
                else
                    maxTHR(d,i) = 1.1*tmp;
                end
            end
        end
        valTHR = min(maxTHR,valTHR);

        % Displaying details coefficients histograms.
        %--------------------------------------------
        dirDef   = 1;
        fontsize = wmachdep('FontSize','normal');
        col_det  = wtbutils('colors','det',Lev_Anal);
        nb_bins  = 50;
        axeXColor = get(win_compress,'DefaultAxesXColor');        
        for level = 1:Lev_Anal
            for direct=1:3
                axeAct  = axe_hist(direct,level);
                dir = dirval(direct);
                curr_img   = detcoef2(dir,coefs,sizes,level);
                curr_color = col_det(level,:);
                his        = wgethist(curr_img(:),nb_bins);
                his(2,:)   = his(2,:)/length(curr_img(:));
                wplothis(axeAct,his,curr_color);
                if direct==dirDef
                    txt_hist(direct) = ...
                    txtinaxe('create',['L_' sprintf('%.0f',level)],...
                             axeAct,'left','on',...
                             'bold',fontsize); %#ok<AGROW>
                    set(txt_hist(direct),'Color',axeXColor);
                end
                if level==1
                    xlab = getWavMSG(['Wavelet:dw2dRF:Dir_Det_' dir]);
                    wxlabel(xlab,'Color',axeXColor,'Parent',axeAct);
                end
                thr_val = valTHR(direct,level);
                thr_max = maxTHR(direct,level);
                ylim    = get(axeAct,'YLim');
                utthrw2d('plot_dec',win_compress,dirDef, ...
                          {thr_max,thr_val,ylim,direct,level,axeAct})
                xmax = 1.1*max([thr_max, max(abs(his(1,:)))]);
                set(axeAct,'XLim',[-xmax xmax]);
                set(findall(axeAct),'Visible','off');
            end
        end

        % Initialization of Compression structure.
        %----------------------------------------
        utthrw2d('set',win_compress,'valthr',valTHR,'maxthr',maxTHR);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelp('add_ContextMenu',win_compress,pop_mod,'DW2D_COMP_GUI');
		%-------------------------------------

        % Memory blocks update.
        %----------------------
        utthrgbl('set',win_compress,'handleORI',hdl_datas(1));
        utthrw2d('set',win_compress,'handleORI',hdl_datas(1));
        wmemtool('ini',win_compress,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_compress,n_misc_loc,  ...
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas,  ...
                       ind_pop_mod,pop_mod       ...
                       );
        wmemtool('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_orig axe_comp];
        axe_act = [];
        dynvtool('init',win_compress,[],axe_cmd,axe_act,[1 1],'','','','int');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_compress);
        set(win_compress,'Visible','On');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'compress'

        % Waiting message.
        %-----------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Clear & Get Handles.
        %----------------------
        dw2dcomp('clear_GRAPHICS',win_compress);
        [win_caller,pop_mod]  = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_win_caller,ind_pop_mod);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        axe_orig = axe_datas(1);
        axe_comp = axe_datas(2);

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Size,Wav_Name,Lev_Anal] = ...
         wmemtool('rmb',win_caller,n_param_anal, ...
                        ind_img_size, ...
                        ind_wav_name, ...
                        ind_lev_anal  ...
                        );
        coefs   = wmemtool('rmb',win_caller,n_coefs,1);
        sizes   = wmemtool('rmb',win_caller,n_sizes,1);
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        isBior  = wavemngr('isbior',Wav_Fam);

        % Compression.
        %-------------
        mode_val = get(pop_mod,'Value');
        switch mode_val
          case 1
            valTHR = utthrgbl('get',win_compress,'valthr');
            thrParams = {'gbl',coefs,sizes,Wav_Name,Lev_Anal,valTHR,'h',1};
          case 2
            valTHR = utthrw2d('get',win_compress,'valthr');
            thrParams = {'lvd',coefs,sizes,Wav_Name,Lev_Anal,valTHR,'h'};
        end
        [xc,cxc,lxc] = wdencmp(thrParams{:});
        clear thrParams
        
        switch mode_val
          case 1 , [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
          case 2 , perf0 = 100*(length(find(cxc==0))/length(cxc));
        end
        
        if isBior
            img_orig = hdl_datas(1);
            Img_Anal = get(img_orig,'CData');
            if ismatrix(Img_Anal)
                n_ori = norm(Img_Anal);
                n_cfs = norm(xc);
            else
                n_ori = norm(coefs);
                n_cfs = norm(cxc);
            end
        elseif mode_val==2
            n_ori = norm(coefs);
            n_cfs = norm(cxc);
        end
        
        if isBior || mode_val==2
            if n_ori>eps
                perfl2 = 100*(norm(n_cfs)/n_ori)^2;
            else
                perfl2 = 100; 
            end
        end
        
        % Displaying compressed image.
        %------------------------------
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'CData',wd2uiorui2d('d2uint',xc),'Visible','on');
        else
            hdl_comp = image([1 Img_Size(1)],[1,Img_Size(2)],...
                wd2uiorui2d('d2uint',xc),'Parent',axe_comp);
            hdl_datas(2) = hdl_comp;
            utthrgbl('set',win_compress,'handleTHR',hdl_comp);
            utthrw2d('set',win_compress,'handleTHR',hdl_comp);
            wmemtool('wmb',win_compress,n_misc_loc,ind_hdl_datas,hdl_datas);
        end
        xylim = get(axe_orig,{'XLim','YLim'});
        set(axe_comp,'XLim',xylim{1},'YLim',xylim{2},'Visible','on');

        % Set a text as a super title.
        %-----------------------------
        wtitle(getWavMSG('Wavelet:dw2dRF:Comp_Img'),'Parent',axe_comp)
        if isBior && ismatrix(Img_Anal)
            txt_comp = getString(message('Wavelet:dw2dRF:title_EnergyRatio',num2str(perfl2,'%5.2f'),num2str(perf0,'%5.2f')));
        else
            txt_comp = getString(message('Wavelet:dw2dRF:title_RetainedEnergy',num2str(perfl2,'%5.2f'),num2str(perf0,'%5.2f')));
        end

        wtxttitl(axe_comp,txt_comp);
        % Update the edit values (G492502)
        utthrgbl('set',win_compress,'perfo',[perfl2,perf0]);
        
        if mode_val==2
            utthrw2d('set',win_compress,'perfos',{perfl2,perf0});
        end 

        % Memory blocks & HG update.
        %---------------------------
        switch mode_val
          case 1 , valTHR = utthrgbl('get',win_compress,'valthr');
          case 2 , valTHR = utthrw2d('get',win_compress,'valthr');
        end
        wmemtool('wmb',win_compress,n_thrDATA,ind_value,{xc,cxc,lxc,valTHR});
        dw2dcomp('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'change_mode'
        pop_mod = varargin{2}(1);
        mod_val = get(pop_mod,'Value');
        old_mod = get(pop_mod,'UserData');
        if isequal(mod_val,old_mod) , return; end
        set(pop_mod,'UserData',mod_val);
        dw2dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        Lev_Anal = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);        
        switch mod_val
          case 1
              visGBL = 'on';  visLVL = 'off'; visMAP = 'on';
          case 2
            visGBL = 'off'; visLVL = 'on';
            if Lev_Anal>3
                visMAP = 'off';
            else
                visMAP = 'on';
            end
        end
        vis_UTCOLMAP = wtbxappdata('get',win_compress,'vis_UTCOLMAP');
        if strcmpi(vis_UTCOLMAP,'off') , visMAP = 'Off'; end
        if Lev_Anal<6 , cbcolmap('Visible',win_compress,visMAP); end
        utthrgbl('visible',win_compress,visGBL);
        utthrw2d('visible',win_compress,visLVL);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth] = utthrgbl('get_GBL_par',win_compress);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        thrFLAGS = 'dw2dcompGBL';
        switch numMeth
          case {1,3}
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngr(thrFLAGS,meth,coefs,sizes);
            if nargout==1
                varargout = {valTHR};
            else
                varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            img = get(dw2drwcd('r_orig',win_caller),'CData');
            valTHR = wthrmngr(thrFLAGS,meth,img);
            maxTHR = max(coefs(:));
            valTHR = min(valTHR,maxTHR);
            varargout = {valTHR};
        end

    case 'update_GBL_meth'
        dw2dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw2dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('update_GBL_meth',win_compress,valTHR);

    case 'show_LVL_perfos'
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        lev_anal = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);
        [numMeth,meth,scal,sorh] = utthrw2d('get_LVL_par',win_compress); %#ok<ASGLU>
        valTHR = utthrw2d('get',win_compress,'valTHR');
        [perfl2,perf0] = wscrupd(coefs,sizes,lev_anal,valTHR,sorh);      
        utthrw2d('set',win_compress,'perfos',{perfl2,perf0}); 

    case 'compute_LVL_THR'
        win_caller = varargin{2};
        [numMeth,meth,alfa,sorh] = utthrw2d('get_LVL_par',win_compress);
        coefs = wmemtool('rmb',win_caller,n_coefs,1);
        sizes = wmemtool('rmb',win_caller,n_sizes,1);
        level = wmemtool('rmb',win_caller,n_param_anal,ind_lev_anal);

        thrFLAGS = 'dw2dcompLVL';
        switch numMeth
          case {1,2,3,4,6} , valTHR = wthrmngr(thrFLAGS,meth,coefs,sizes,alfa);
          case 5          
            img = get(dw2drwcd('r_orig',win_caller),'CData');
            valTHR = wthrmngr(thrFLAGS,meth,img,level);
        end
        [perfl2,perf0] = wscrupd(coefs,sizes,level,valTHR,sorh);
        utthrw2d('set',win_compress,'perfos',{perfl2,perf0}); 
        varargout = {valTHR,perfl2,perf0};

    case 'update_LVL_meth'
        dw2dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = dw2dcomp('compute_LVL_THR',win_compress,win_caller);
        utthrw2d('update_LVL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_compress,n_misc_loc,ind_status);
        if status == 0 , return; end
 
        % Disable Toggles and Menus.
        %---------------------------
        dw2dcomp('enable_menus',win_compress,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_axe_datas);
        axe_comp = axe_datas(2);

        % Setting compressed axes invisible.
        %-----------------------------------
        set(findobj(axe_comp),'Visible','off');
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_compress,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_compress,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);
        utthrgbl('enable_tog_res',win_compress,enaVal);
        utthrw2d('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2)
            status = 1;
        else
            status = 0;
        end
        wmemtool('wmb',win_compress,n_misc_loc,ind_status,status);
        
	case 'save_synt'
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Comp_Img'), ...
            win_compress,X,'wname',wname,'valTHR',valTHR);
      
    case 'save_cfs'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                      '*.mat',getWavMSG('Wavelet:dw2dRF:Save2DCfs'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveCfs'));

        % Getting Analysis values.
        %-------------------------
        win_caller  = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_param_anal,ind_nbcolors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        sizes = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch 
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                           '*.wa2',getWavMSG('Wavelet:dw2dRF:SaveAnal_2D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveDec'));


        % Getting Analysis values.
        %-------------------------
        win_caller  = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        [wave_name,data_name,nb_colors] =    ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_nbcolors  ...
                               ); %#ok<ASGLU>
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map) , map = pink(nb_colors); end %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        coefs = thrDATA{2}; %#ok<NASGU>
        sizes = thrDATA{3}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<*CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_compress,...
                         getWavMSG('Wavelet:commongui:UpdateSI'),2,'cancel');
        end
        switch status
            case 1
              wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitCompute'));
              thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_hdl_datas);
              img_comp  = hdl_datas(2);
              dw2dmngr('return_comp',win_caller,status,img_comp);
              wwaiting('off',win_compress);

            case 0 , dw2dmngr('return_comp',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end


    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
