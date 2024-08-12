function varargout = wp2ddeno(option,varargin)
%WP2DDENO Wavelet packets 2-D de-noising.
%   VARARGOUT = WP2DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
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
n_misc_loc = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
% ind_cfsMode    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

if ~isequal(option,'create') , win_denoise = varargin{1}; end
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
        win_name = getWavMSG('Wavelet:wp1d2dRF:NamWinDenoWP_2D');
        [win_denoise,pos_win,win_units,~,pos_frame0] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                                {mfilename,'cond'},1,1,0);
        set(win_denoise,'UserData',win_caller);
        if nargout>0 , varargout{1} = win_denoise; end

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_denoise, ...
            getWavMSG('Wavelet:commongui:HLP_DenoProc'),'DENO_PROCEDURE');
		wfighelp('addHelpItem',win_denoise, ...
            getWavMSG('Wavelet:commongui:HLP_AvailMeth'),'COMP_DENO_METHODS');

        % Menu construction for current figure.
        %--------------------------------------
		m_save  = wfigmngr('getmenus',win_denoise,'save');
        sav_menus(1) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:DenoImg'),    ...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)wp2ddeno('save_synt',    ...
            win_denoise )   ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:Str_Decomp'),     ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(~,~)wp2ddeno('save_dec',    ...
            win_denoise )  ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABDenoise')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('wp2ddeno',  ...
            win_denoise )  ...
            );
        wtbxappdata('set',win_denoise,'M_GenCode',m_gen);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting variables from wp2dtool figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        depth = treedpth(WP_Tree);
        [Img_Name,Wav_Name,Img_Size,Ent_Nam,Ent_Par] =  ...
                  wmemtool('rmb',win_caller,n_param_anal, ...
                                 ind_img_name,ind_wav_name, ...
                                 ind_img_size,    ...
                                 ind_ent_anal,ind_ent_par);
        vis_UTCOLMAP = wtbxappdata('get',win_caller,'vis_UTCOLMAP');
        wtbxappdata('set',win_denoise,'vis_UTCOLMAP',vis_UTCOLMAP);

        % General graphical parameters initialization.
        %--------------------------------------------
        dy = Y_Spacing;

        % Command part of the window.
        %============================
        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopINI},...
                    {'n_s',{Img_Name,Img_Size},'wav',Wav_Name,'lev',depth} ...
                    );

        % Entropy parameters.
        %--------------------
        ytopENT = toolPos(2)-4*dy;
        toolPos = utentpar('create_copy',win_denoise, ...
                    {'xloc',xlocINI,'top',ytopENT,...
                     'ent',{Ent_Nam,Ent_Par}} ...
                    );

        % Global De-noising tool.
        %------------------------        
        ytopTHR = toolPos(2)-4*dy;
        utthrwpd('create',win_denoise,'toolOPT','wpdeno2', ...
                 'xloc',xlocINI,'top',ytopTHR ...
                 );

        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
        utcolmap('create',win_denoise, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'enable','on');
        pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'UserData',prop_pal{3});
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));
        cbcolmap('Visible',win_denoise,vis_UTCOLMAP);

        % Axes construction.
        %===================
        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        ecx     = 0.04*pos_win(3);
        bdy     = 0.06*pos_win(4);
        % ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);

        % Building axes for original image.
        %----------------------------------
        x_axe  = bdx;
        w_axe  = (w_graph-ecx-3*bdx/2)/2;
        h_axe  = (h_graph-3*bdy)/2;
        y_axe  = y_graph+h_graph-h_axe-bdy;
        cx_ori = x_axe+w_axe/2;
        cy_ori = y_axe+h_axe/2;
        cx_den = cx_ori+w_axe+ecx;
        cy_den = cy_ori;
        [w_used,h_used] = wpropimg(Img_Size,w_axe,h_axe,'pixels');
        pos_axe  = [cx_ori-w_used/2 cy_ori-h_used/2 w_used h_used];
        axe_datas(1) = axes('Parent',win_denoise,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Box','On');

        % Displaying original image.
        %---------------------------
        Img_Anal  = get(wp2ddraw('r_orig',win_caller),'CData');
        hdl_datas = [NaN NaN];
        hdl_datas(1) = image([1 Img_Size(1)],[1,Img_Size(2)],Img_Anal,...
                             'Parent',axe_datas(1));
        wtitle(getWavMSG('Wavelet:commongui:OriImg'),'Parent',axe_datas(1));

        % Building axes for de-noised image.
        %-----------------------------------
        pos_axe = [cx_den-w_used/2 cy_den-h_used/2 w_used h_used];
        xylim   = get(axe_datas(1),{'XLim','YLim'});
        axe_datas(2) = axes('Parent',win_denoise,...
                            'Units',win_units,...
                            'Position',pos_axe,...
                            'Visible','off',...
                            'Box','On',...
                            'XLim',xylim{1},...
                            'YLim',xylim{2});

        % Initializing threshold.
        %------------------------
        [valTHR,maxTHR,cfs] = ...
            wp2ddeno('compute_GBL_THR',win_denoise,win_caller);
        utthrwpd('setThresh',win_denoise,[0,valTHR,maxTHR]);

        % Displaying perfos.
        %-------------------
        x_axe = bdx;
        y_axe = y_graph+bdy;
        pos_axe_perfo = [x_axe y_axe w_axe h_axe];
        x_axe = bdx+w_axe+ecx;
        y_axe = y_graph+bdy;
        pos_axe_histo = [x_axe y_axe w_axe h_axe];
        utthrwpd('displayPerf',win_denoise,pos_axe_perfo,pos_axe_histo,cfs);
        
        % Memory blocks update.
        %----------------------      
        utthrwpd('set',win_denoise,'handleORI',hdl_datas(1));        
        wmemtool('ini',win_denoise,n_misc_loc,nbLOC_1_stored);
        wmemtool('wmb',win_denoise,n_misc_loc,    ...
                       ind_sav_menus,sav_menus,   ...
                       ind_status,0,              ...
                       ind_win_caller,win_caller, ...
                       ind_axe_datas,axe_datas,   ...
                       ind_hdl_datas,hdl_datas    ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas;
        dynvtool('init',win_denoise,[],axe_cmd,[],[1 1]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);
        set(win_denoise,'Visible','On');                
 
        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'denoise'
        wp2ddeno('clear_GRAPHICS',win_denoise);

        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Getting memory blocks.
        %-----------------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        Img_Size = wmemtool('rmb',win_caller,n_param_anal,ind_img_size);

        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        [numMeth,meth,threshold,sorh] = utthrwpd('get_GBL_par',win_denoise); %#ok<ASGLU>
        thrParams = {sorh,'nobest',threshold,1};
        [C_Img,C_Tree] = wpdencmp(WP_Tree,thrParams{:}); C_Data = [];

        % Displaying de-noised image.
        %----------------------------
        img_deno = hdl_datas(2);
        if ~ishandle(img_deno)
            xylim = get(axe_datas(1),{'XLim','YLim'});
            img_deno = image([1 Img_Size(1)],[1,Img_Size(2)],...
                wd2uiorui2d('d2uint',C_Img),'Parent',axe_datas(2));
            set(axe_datas(2),'XLim',xylim{1},'YLim',xylim{2});
            hdl_datas(2) = img_deno;
            utthrwpd('set',win_denoise,'handleTHR',hdl_datas(2));
            wmemtool('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        else
            set(img_deno,'CData',wd2uiorui2d('d2uint',C_Img));
        end
        set(findobj(axe_datas(2)),'Visible','on');       
        wtitle(getWavMSG('Wavelet:commongui:DenoImg'),'Parent',axe_datas(2));

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value, ...
                 {C_Img,C_Tree,C_Data,threshold});
        wp2ddeno('enable_menus',win_denoise,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        pause(0.01)
        [numMeth,meth] = utthrwpd('get_GBL_par',win_denoise); %#ok<ASGLU>
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        [valTHR,maxTHR,cfs] = wthrmngr('wp2ddenoGBL',meth,WP_Tree);
        if   nargout==1
            varargout = {valTHR};
        else
            varargout = {valTHR,maxTHR,cfs};
        end

    case 'update_GBL_meth'
        wp2ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = wp2ddeno('compute_GBL_THR',win_denoise,win_caller);
        utthrwpd('update_GBL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        % Disable save Menus.
        %--------------------
        wp2ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        axe_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_axe_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        axe_deno = axe_datas(2);
        if strcmpi(get(axe_deno,'Visible'),'on')
            set(findobj(axe_deno),'Visible','off');
            wtitle(getWavMSG('Wavelet:commongui:OriImg'),'Parent',axe_datas(1));
            drawnow
        end

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_denoise,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);        
        utthrwpd('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

	case 'save_synt'
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); 
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        X = round(thrDATA{1});
        valTHR = thrDATA{4};
        utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Deno_Img'), ...
            win_denoise,X,'wname',wname,'valTHR',valTHR);

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                            '*.wp2',getWavMSG('Wavelet:wp1d2dRF:SaveWP2D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        map = cbcolmap('get',win_caller,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_caller,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors); %#ok<NASGU>
        end
        data_name = wmemtool('rmb',win_caller,n_param_anal,ind_img_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp2'; filename = [name ext];
        end
        saveStr = {'tree_struct','map','data_name','valTHR'};
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr{:});
        catch %#ok<CTCH>
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans({win_denoise,getWavMSG('Wavelet:wp1d2dRF:WinDenoWP_2D')},...
                       getWavMSG('Wavelet:commongui:UpdateSI'),2,'cancel');
        end
        switch status
            case 1
              wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));
              thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
              img_deno = hdl_datas(2);
              wp2dmngr('return_deno',win_caller,status,img_deno);
              wwaiting('off',win_denoise);

            case 0 , wp2dmngr('return_deno',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
