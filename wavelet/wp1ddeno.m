function varargout = wp1ddeno(option,varargin)
%WP1DDENO Wavelet packets 1-D de-noising.
%   VARARGOUT = WP1DDENO(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.19.4.16 $ 

% Memory Blocks of stored values.
%================================
% MB1 (main window).
%-------------------
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
% ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
% ind_act_option = 7;
ind_thr_val    = 8;

% MB1 (local).
%-------------
n_misc_loc  = ['MB1_' mfilename];
ind_sav_menus  = 1;
ind_status     = 2;
ind_win_caller = 3;
ind_axe_datas  = 4;
ind_hdl_datas  = 5;
ind_cfsMode    = 6;
nbLOC_1_stored = 6;

% MB2 (local).
%-------------
n_thrDATA = 'thrDATA';
ind_value = 1;
nbLOC_2_stored = 1;

% Tag property (Main Window).
%----------------------------
tag_pop_colm = 'Txt_PopM';
tag_axe_cfs  = 'Axe_Cfs';

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
        pop = wfindobj(win_caller,'Style','popupmenu','Tag',tag_pop_colm);
        cfsMode = get(pop,'Value');

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:wp1d2dRF:NamWinDenoWP_1D');
        [win_denoise,pos_win,win_units,~,pos_frame0] = ...
            wfigmngr('create',win_name,'','ExtFig_CompDeno',...
            {mfilename,'cond'},1,1,0);
        set(win_denoise,'UserData',win_caller,'Tag','WP1D_DEN');
        if nargout>0 , varargout{1} = win_denoise; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_denoise, ...
            getWavMSG('Wavelet:commongui:HLP_SigComp'),'WP1D_DENO_GUI');

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
            'Label',getWavMSG('Wavelet:commongui:DenoSig'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)wp1ddeno('save_synt',    ...
            win_denoise)   ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:Str_Decomp'), ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(~,~)wp1ddeno('save_dec',    ...
            win_denoise)  ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABDenoise')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('wp1ddeno',  ...
            win_denoise)  ...
            );
        wtbxappdata('set',win_denoise,'M_GenCode',m_gen);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting variables from wp1dtool figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        depth = treedpth(WP_Tree);
        [Sig_Name,Sig_Size,Wav_Name,Ent_Nam,Ent_Par] =      ...
                 wmemtool('rmb',win_caller,n_param_anal, ...
                                ind_sig_name,ind_sig_size,...
                                ind_wav_name,ind_ent_anal,ind_ent_par);

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
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',depth} ...
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
        utthrwpd('create',win_denoise,'toolOPT','wpdeno1', ...
                 'xloc',xlocINI,'top',ytopTHR ...
                 );

        % View Compressed Signal in another window.
        %==========================================
        [Pus_EST,Tog_RES] = ...
            utthrwpd('get',win_denoise,'pus_est','tog_res');
        pos_Pus_EST = get(Pus_EST,'Position');
        pos_Tog_RES = get(Tog_RES,'Position');
        dx = pos_Tog_RES(1)-(pos_Pus_EST(1)+pos_Pus_EST(3));
        xleft = pos_Pus_EST(1)+dx/2;
        width = pos_Pus_EST(3)+pos_Tog_RES(3);
        pos_Pus_SigDorC = ...
            [xleft , pos_Pus_EST(2)-pos_Pus_EST(4)-3*dy , ...
             width , pos_Pus_EST(4)];
         
        Pus_SigDorC = uicontrol('Parent',win_denoise,...
                  'Style','pushbutton',...
                  'String',getWavMSG('Wavelet:commongui:ViewDS'), ...
                  'Units',win_units,...
                  'Position',pos_Pus_SigDorC, ...
                  'Enable','Off', ...
                  'BackgroundColor',get(Pus_EST,'BackgroundColor'), ...
                  'UserData','Compressed', ...
                  'Tag','Pus_SigDorC' ...
                  );

        cb_Pus_SigDorC = @(~,~)dw1dview_dorc(win_denoise);
        set(Pus_SigDorC,'Callback',cb_Pus_SigDorC);
        %==================================================================
             
             
        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
        utcolmap('create',win_denoise, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'briflag',0, ...
                 'Enable','on');
        pop_pal_loc = cbcolmap('get',win_denoise,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'UserData',prop_pal{3});
        set(win_denoise,'Colormap',get(win_caller,'Colormap'));

        % Axes construction.
        %===================
        % General graphical parameters initialization.
        %--------------------------------------------
        bdx     = 0.08*pos_win(3);
        bdy     = 0.06*pos_win(4);
        ecy     = 0.03*pos_win(4);
        y_graph = 2*Def_Btn_Height+dy;
        h_graph = pos_frame0(4)-y_graph;
        w_graph = pos_frame0(1);

        % Axes construction parameters.
        %------------------------------
        w_left     = (w_graph-3*bdx)/2;
        x_left     = bdx;
        w_right    = w_left;
        x_right    = x_left+w_left+5*bdx/4;
        n_axeright = 3;

        % Vertical separation.
        %---------------------
        w_fra   = 0.01*pos_win(3);
        x_fra   = (w_graph-w_fra)/2;
        uicontrol('Parent',win_denoise,...
                  'Style','frame',...
                  'Units',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'BackgroundColor',Def_FraBkColor ...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right = y_graph+bdy-ecy/2;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes('Parent',win_denoise,...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Box','On'...
                                );
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'Visible','off');

        % Computing and Drawing Original Signal.
        %---------------------------------------
        Sig_Anal = get(wp1ddraw('r_orig',win_caller),'YData');
        hdl_datas = [NaN NaN];
        axeAct = axe_datas(3);
        curr_color = wtbutils('colors','sig');
        xmin = 1;                       
        xmax = length(Sig_Anal);       
        hdl_datas(1) = line(xmin:xmax,Sig_Anal,...
                            'Color',curr_color, ...
                            'Parent',axeAct);
        wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axeAct);
        ylim = [min(Sig_Anal) max(Sig_Anal)];
        if ylim(1)==ylim(2) , ylim = ylim+[-0.01 0.01]; end
        set(axeAct,'XLim',[xmin xmax],'YLim',ylim);

        % Displaying original details coefficients.
        %------------------------------------------
        axe_handles = findobj(get(win_caller,'Children'),'flat','Type','axes');
        WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
        xylim = get(WP_Axe_Cfs,{'XLim','YLim'});
        commonProp = {...
            'XLim',xylim{1}, ...
            'YLim',xylim{2}, ...
            'YTickLabelMode','manual', ...
            'YTickLabel',[], ...
            'YTick',[],      ...
            'Box','On'       ...
            };
        axeAct = axe_datas(2);
        wtitle(getWavMSG('Wavelet:dw1dRF:OriCfs'),'Parent',axeAct);
        set(axeAct,commonProp{:});
        wpplotcf(WP_Tree,cfsMode,axeAct);
        set(axe_datas(1),commonProp{:});

        % Initializing threshold.
        %------------------------
        [valTHR,maxTHR,cfs] = wp1ddeno('compute_GBL_THR',win_denoise,win_caller);
        utthrwpd('setThresh',win_denoise,[0,valTHR,maxTHR]);

        % Displaying perfos.
        %-------------------
        y_axe = y_graph+bdy+3*h_right/2+3*ecy;
        h_axe = 3*h_right/2+ecy/2;
        pos_axe_perfo = [x_left y_axe w_left h_axe];
        y_axe = y_graph+bdy-ecy/2;
        h_axe = 3*h_right/2+ecy/2;
        pos_axe_histo = [x_left y_axe w_left h_axe];
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
                       ind_hdl_datas,hdl_datas,   ...
                       ind_cfsMode,cfsMode        ...
                       );
        wmemtool('ini',win_denoise,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas(3);
        axe_act = axe_datas(1:2);
        dynvtool('init',win_denoise,[],axe_cmd,axe_act,[1 0]);

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_denoise);
        set(win_denoise,'Visible','On');        

        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'denoise'
        wp1ddeno('clear_GRAPHICS',win_denoise);
 
        % Waiting message.
        %-----------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));

        % Getting memory blocks.
        %-----------------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');

        % De-noising depending on the selected thresholding mode.
        %--------------------------------------------------------
        [numMeth,meth,threshold,sorh] = utthrwpd('get_GBL_par',win_denoise); %#ok<ASGLU>
        thrParams = {sorh,'nobest',threshold,1};
        [C_Sig,C_Tree] = wpdencmp(WP_Tree,thrParams{:}); C_Data = [];

        % Displaying de-noised signal.
        %-----------------------------
        lin_deno = hdl_datas(2);
        if ~ishandle(lin_deno)
            curr_color  = wtbutils('colors','ssig');
            lin_deno = line(...
                            'Parent',axe_datas(3),...
                            'XData',1:length(C_Sig),...
                            'YData',C_Sig,...
                            'LineWidth',2,...
                            'Color',curr_color);
            hdl_datas(2) = lin_deno;
            utthrwpd('set',win_denoise,'handleTHR',hdl_datas(2));
            wmemtool('wmb',win_denoise,n_misc_loc,ind_hdl_datas,hdl_datas);
        else
            set(lin_deno,'YData',C_Sig,'Visible','on');
        end
        wtitle(getWavMSG('Wavelet:dw1dRF:OS_DS'),'Parent',axe_datas(3));

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_denoise,n_misc_loc,ind_cfsMode);
        axeAct = axe_datas(1);
        delete(findobj(axeAct,'Type','image'));
        wpplotcf(C_Tree,cfsMode,axeAct);
        xylim = get(axe_datas(2),{'XLim','YLim'});
        set(axeAct,'XLim',xylim{1},'YLim',xylim{2});
        wtitle(getWavMSG('Wavelet:commongui:ThrCfs'),'Parent',axeAct);
        set(findobj(axeAct),'Visible','on');       

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_denoise,n_thrDATA,ind_value,...
                 {C_Sig,C_Tree,C_Data,threshold});
        wp1ddeno('enable_menus',win_denoise,'on');
 
        % End waiting.
        %-------------
        wwaiting('off',win_denoise);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        pause(0.01)
        [numMeth,meth] = utthrwpd('get_GBL_par',win_denoise); %#ok<ASGLU>
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        [valTHR,maxTHR,cfs] = wthrmngr('wp1ddenoGBL',meth,WP_Tree);
        if   nargout==1
            varargout = {valTHR};
        else
            varargout = {valTHR,maxTHR,cfs};
        end

    case 'update_GBL_meth'
        wp1ddeno('clear_GRAPHICS',win_denoise);
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        valTHR = wp1ddeno('compute_GBL_THR',win_denoise,win_caller);
        utthrwpd('update_GBL_meth',win_denoise,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_denoise,n_misc_loc,ind_status);
        if status == 0 , return; end

        % Disable save Menus.
        %--------------------
        wp1ddeno('enable_menus',win_denoise,'off');

        % Get Handles.
        %-------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_denoise,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Setting the de-noised coefs axes invisible.
        %--------------------------------------------
        lin_deno = hdl_datas(2);
        if ishandle(lin_deno)
            vis = get(lin_deno,'Visible');
            if isequal(vis,'on')
                set(lin_deno,'Visible','off');
                wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axe_datas(3));
                set(findobj(axe_datas(1)),'Visible','off');       
            end
        end
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_denoise,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_denoise,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);        
        utthrwpd('enable_tog_res',win_denoise,enaVal);
        if strncmpi(enaVal,'on',2) , status = 1; else status = 0; end
        wmemtool('wmb',win_denoise,n_misc_loc,ind_status,status);

    case 'save_synt'

       % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                        '*.mat',getWavMSG('Wavelet:commongui:SaveDenSig'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        xc = thrDATA{1}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          saveStr = name;
          eval([saveStr '= xc ;']);
        catch %#ok<*CTCH>
          saveStr = 'xc';
        end
        wwaiting('off',win_denoise);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_denoise, ...
                          '*.wp1',getWavMSG('Wavelet:wp1d2dRF:SaveWP1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis parameters.
        %-----------------------------
        win_caller = wmemtool('rmb',win_denoise,n_misc_loc,ind_win_caller);
        data_name  = wmemtool('rmb',win_caller,n_param_anal,ind_sig_name); %#ok<NASGU>

        % Getting Analysis values.
        %-------------------------
        thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR  = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        saveStr = {'tree_struct','data_name','valTHR'};
        wwaiting('off',win_denoise);
        try
            save([pathname filename],saveStr{:});
        catch
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_denoise,n_misc_loc,...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans({win_denoise, ...
                getWavMSG('Wavelet:wp1d2dRF:WinDenoWP_1D')},...
                getWavMSG('Wavelet:commongui:UpdateSS'),2,'cancel');
        end
        switch status
          case 1
            wwaiting('msg',win_denoise,getWavMSG('Wavelet:commongui:WaitCompute'));
            thrDATA = wmemtool('rmb',win_denoise,n_thrDATA,ind_value);
            valTHR  = thrDATA{4};
            wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
            hdl_datas = wmemtool('rmb',win_denoise,n_misc_loc,ind_hdl_datas);
            lin_deno = hdl_datas(2);
            wp1dmngr('return_deno',win_caller,status,lin_deno);
            wwaiting('off',win_denoise);

          case 0 , wp1dmngr('return_deno',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
