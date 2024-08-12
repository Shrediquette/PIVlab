function varargout = wp2dcomp(option,varargin)
%WP2DCOMP Wavelet packets 2-D compression.
%   VARARGOUT = WP2DCOMP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
% ind_img_t_name = 7;
% ind_act_option = 8;
ind_thr_val    = 9;
% nb1_stored     = 9;

% MB2 (main window).
%-------------------
n_wp_utils = 'WP_Utils';
% ind_tree_lin  = 1;
% ind_tree_txt  = 2;
% ind_type_txt  = 3;
% ind_sel_nodes = 4;
% ind_gra_area  = 5;
ind_nb_colors = 6;
% nb2_stored    = 6;

% MB1 (local).
%-------------
n_misc_loc = [ 'MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
nbLOC_1_stored = 5;

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
        win_name = getWavMSG('Wavelet:wp1d2dRF:NamWinCompWP_2D');
        [win_compress,pos_win,win_units,~,pos_frame0] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                        {mfilename,'cond'},1,1,0);
        set(win_compress,'UserData',win_caller);
        if nargout>0 , varargout{1} = win_compress; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_compress, ...
            getWavMSG('Wavelet:commongui:HLP_ImgComp'),'WP2D_COMP_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_compress, ...
            getWavMSG('Wavelet:commongui:HLP_CompProc'),'COMP_PROCEDURE');
		wfighelp('addHelpItem',win_compress, ...
            getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_compress,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:CompImg'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)wp2dcomp('save_synt', win_compress)  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:Str_Decomp'), ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(~,~)wp2dcomp('save_dec', win_compress)   ...
                              );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABCompress')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('wp2dcomp', win_compress)  ...
            );
        wtbxappdata('set',win_compress,'M_GenCode',m_gen);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting variables from wp2dtool figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        depth = treedpth(WP_Tree);
        [Img_Name,Wav_Name,Img_Size,Ent_Nam,Ent_Par] =  ...
                        wmemtool('rmb',win_caller,n_param_anal,   ...
                                       ind_img_name,ind_wav_name, ...
                                       ind_img_size,              ...
                                       ind_ent_anal,ind_ent_par);
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        isBior = wavemngr('isbior',Wav_Fam);
        vis_UTCOLMAP = wtbxappdata('get',win_caller,'vis_UTCOLMAP');
        wtbxappdata('set',win_compress,'vis_UTCOLMAP',vis_UTCOLMAP);        

        % General graphical parameters initialization.
        %---------------------------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',depth} ...
                    );

        % Entropy parameters.
        %--------------------
        ytopENT = toolPos(2)-dy;
        toolPos = utentpar('create_copy',win_compress, ...
                    {'xloc',xlocINI,'top',ytopENT,...
                     'ent',{Ent_Nam,Ent_Par}} ...
                    );

        % Global Compression tool.
        %-------------------------
        ytopTHR = toolPos(2)-4*dy;
        utthrgbl('create',win_compress,'toolOPT','wp2dcomp', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior,   ...
                 'caller',mfilename ...
                 );

        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
        utcolmap('create',win_compress, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'enable','on');
        pop_pal_loc = cbcolmap('get',win_compress,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'UserData',prop_pal{3});
        set(win_compress,'Colormap',get(win_caller,'Colormap')); 
        cbcolmap('Visible',win_compress,vis_UTCOLMAP);

        % Axes Construction.
        %===================
        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        bdy     = 0.06*pos_win(4);
        % ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph-Def_Btn_Height;
        w_graph = pos_frame0(1);

        % Building axes for original image.
        %----------------------------------
        x_axe  = bdx;
        w_axe  = (w_graph-ecx-3*bdx/2)/2;
        h_axe  = (h_graph-3*bdy)/2;
        y_axe  = y_graph+h_graph-h_axe-bdy;
        cx_ori = x_axe+w_axe/2;
        cy_ori = y_axe+h_axe/2;
        cx_cmp = cx_ori+w_axe+ecx;
        cy_cmp = cy_ori;
        [w_used,h_used] = wpropimg(Img_Size,w_axe,h_axe,'pixels');
        pos_axe      = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1) = axes(...
                            'Parent',win_compress,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Box','On');
        axe_orig = axe_datas(1);

        % Displaying original image.
        %---------------------------
        cdata = get(wp2ddraw('r_orig',win_caller),'CData');
        hdl_datas    = [NaN ; NaN];
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],cdata, ...
                             'Parent',axe_orig);
        clear cdata
        wtitle(getWavMSG('Wavelet:commongui:OriImg'),'Parent',axe_orig);

        % Building axes for compressed image.
        %------------------------------------
        pos_axe = [cx_cmp-w_used/2 cy_cmp-h_used/2 w_used h_used];
        xylim = get(axe_orig,{'XLim','YLim'});
        axe_datas(2) = axes(...
                            'Parent',win_compress,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Visible','off',...
                            'Box','On',...
                            'XLim',xylim{1},...
                            'YLim',xylim{2});
        axe_comp = axe_datas(2);

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            wp2dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

        % Displaying perfos & legend.
        %----------------------------
        x_axe     = bdx;
        y_axe     = y_graph+bdy;
        pos_axe_perfo = [x_axe y_axe w_axe h_axe];
        x_axe     = bdx+w_axe+ecx;
        y_axe     = y_graph+w_axe/3+bdy;
        h_axe     = w_axe/3;
        pos_axe_legend = [x_axe y_axe w_axe h_axe];
        utthrgbl('displayPerf',win_compress, ...
                  pos_axe_perfo,pos_axe_legend,thresVALUES,n0SCR,rl2SCR,valTHR);
        [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
        utthrgbl('set',win_compress,'perfo',[perfl2,perf0]);
        drawnow

        % Memory blocks update.
        %----------------------
        utthrgbl('set',win_compress,'handleORI',hdl_datas(1));
        wmemtool('ini',win_compress,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_compress,n_misc_loc,  ...
                       ind_status,0,             ...
                       ind_sav_menus,sav_menus,  ...
                       ind_win_caller,win_caller,...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas   ...
                       );
        wmemtool('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = [axe_orig axe_comp];
        dynvtool('init',win_compress,[],axe_cmd,[],[1 1]);

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

        % Handles.
        %---------
        wp2dcomp('clear_GRAPHICS',win_compress);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        axe_orig = axe_datas(1);
        axe_comp = axe_datas(2);

        % Getting memory blocks.
        %-----------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        [Img_Size,Wav_Name] = wmemtool('rmb',win_caller,n_param_anal,...
                                             ind_img_size,ind_wav_name);
        isBior = wavemngr('isbior',Wav_Name);

        % Compression.
        %-------------
        valTHR = utthrgbl('get',win_compress,'valthr');
        thrParams = {'h','nobest',valTHR,1};
        if isBior
            [C_Img,C_Tree,perf0] = wpdencmp(WP_Tree,thrParams{:});
            C_Data = [];
            img_orig = hdl_datas(1);
            Img_Anal = get(img_orig,'CData');
            normimg  = norm(double(Img_Anal(:)));
            if normimg<eps
                perfl2 = 100;
            else
                perfl2 = 100*(norm(C_Img(:))/normimg)^2;
            end
            strPerfo = getWavMSG('Wavelet:commongui:EnerRat', ...
                num2str(perfl2,'%5.2f'), [num2str(perf0,'%5.2f') ' %']);

        else
            [C_Img,C_Tree] = wpdencmp(WP_Tree,thrParams{:});
            C_Data = [];
            [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
            strPerfo = getWavMSG('Wavelet:commongui:RetEner', ...
                num2str(perfl2,'%5.2f'), [num2str(perf0,'%5.2f') ' %']);
        end

        % Displaying compressed image.
        %------------------------------
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'CData',wd2uiorui2d('d2uint',C_Img),'Visible','on');
        else
            hdl_comp = image([1 Img_Size(1)],[1,Img_Size(2)], ...
                wd2uiorui2d('d2uint',C_Img),'Parent',axe_comp);
            hdl_datas(2) = hdl_comp;
            utthrgbl('set',win_compress,'handleTHR',hdl_datas(2));
            wmemtool('wmb',win_compress,n_misc_loc,ind_hdl_datas,hdl_datas);
        end
        xylim = get(axe_orig,{'XLim','YLim'});
        set(axe_comp,'XLim',xylim{1},'YLim',xylim{2},'Visible','on');

        % Set a text as a super title.
        %-----------------------------
        wtitle(getWavMSG('Wavelet:commongui:CompImg'),'Parent',axe_comp);
        wtxttitl(axe_comp,strPerfo);

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_compress,n_thrDATA,ind_value, ...
                 {C_Img,C_Tree,C_Data,valTHR});
        wp2dcomp('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth] = utthrgbl('get_GBL_par',win_compress);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        thrFLAGS = 'wp2dcompGBL';
        switch numMeth
          case {1,3}
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngr(thrFLAGS,meth,WP_Tree);
            if nargout==1
                varargout = {valTHR};
            else
                varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            sig    = get(wp2ddraw('r_orig',win_caller),'CData');
            valTHR = wthrmngr(thrFLAGS,meth,sig);
            cfs = read(WP_Tree,'allcfs');
            maxTHR = max(abs(cfs));
            valTHR = min(valTHR,maxTHR);
            varargout = {valTHR};
        end

    case 'update_GBL_meth'
        wp2dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = wp2dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('update_GBL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_compress,n_misc_loc,ind_status);
        if status == 0 , return; end
        axe_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_axe_datas);
        wp2dcomp('enable_menus',win_compress,'off');
        axe_comp = axe_datas(2);
        set(findobj(axe_comp),'Visible','off');       
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_compress,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_compress,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);
        utthrgbl('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_compress,n_misc_loc,ind_status,status);

	case 'save_synt'
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Comp_Img'), ...
            win_compress,X,'wname',wname,'valTHR',valTHR);
        
    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                            '*.wp2',getWavMSG('Wavelet:wp1d2dRF:SaveWP2D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        data_name  = wmemtool('rmb',win_caller,n_param_anal,ind_img_name); %#ok<NASGU>
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp2'; filename = [name ext];
        end
        saveStr = {'tree_struct','map','data_name','valTHR'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
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
              wp2dmngr('return_comp',win_caller,status,img_comp);
              wwaiting('off',win_compress);

            case 0 , wp2dmngr('return_comp',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
