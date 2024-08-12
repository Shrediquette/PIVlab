function varargout = wp1dcomp(option,varargin)
%WP1DCOMP Wavelet packets 1-D compression.
%   VARARGOUT = WP1DCOMP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.20.4.17 $ 

% Memory Blocks of stored values.
%================================
% MB1.
%-----
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
n_misc_loc = ['MB1_' mfilename];
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

% Tag property.
%--------------
tag_axetxt_perf = 'Txt_Perf';

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
        pop = wfindobj(win_caller,'Style','popupmenu','Tag',tag_pop_colm);
        cfsMode = get(pop,'Value');

        % Window initialization.
        %----------------------
        win_name = getWavMSG('Wavelet:wp1d2dRF:NamWinCompWP_1D');
        [win_compress,pos_win,win_units,~,pos_frame0] = ...
                    wfigmngr('create',win_name,'','ExtFig_CompDeno', ...
                        {mfilename,'cond'},1,1,0);
        set(win_compress,'UserData',win_caller,'Tag','WP1D_CMP');                    
        if nargout>0 , varargout{1} = win_compress; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_compress, ...
            getWavMSG('Wavelet:commongui:HLP_SigComp'),'WP1D_COMP_GUI');

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
            'Label',getWavMSG('Wavelet:commongui:CompSig'),...
            'Position',1,                   ...
            'Enable','Off',                 ...
            'Callback',                     ...
            @(~,~)wp1dcomp('save_synt', win_compress )  ...
            );
        sav_menus(2) = uimenu(m_save,...
            'Label',getWavMSG('Wavelet:commongui:Str_Decomp'), ...
            'Position',2,                  ...
            'Enable','Off',                ...
            'Callback',                    ...
            @(~,~)wp1dcomp('save_dec', win_compress) ...
            );
        m_file = get(m_save,'Parent');
        pos = get(m_save,'Position');
        m_gen = uimenu(m_file,...
            'Label',getString(message('Wavelet:commongui:GenerateMATLABCompress')), ...
            'Position',pos+1,                  ...
            'Enable','Off',                ...
            'Separator','Off',             ...
            'Callback',                    ...
            @(~,~)wsaveprocess('wp1dcomp', win_compress)  ...
            );
        wtbxappdata('set',win_compress,'M_GenCode',m_gen);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitInit'));

        % Getting variables from wp1dtool figure memory block.
        %-----------------------------------------------------
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        depth = treedpth(WP_Tree);
        [Sig_Name,Sig_Size,Wav_Name,Ent_Nam,Ent_Par] = ...
                wmemtool('rmb',win_caller,n_param_anal, ...
                               ind_sig_name,ind_sig_size,...
                               ind_wav_name,ind_ent_anal,ind_ent_par);
        Wav_Fam = wavemngr('fam_num',Wav_Name);
        isBior  = wavemngr('isbior',Wav_Fam);        

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
                    {'n_s',{Sig_Name,Sig_Size},'wav',Wav_Name,'lev',depth}...
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
        utthrgbl('create',win_compress,'toolOPT','wp1dcomp', ...
                 'xloc',xlocINI,'top',ytopTHR, ...
                 'isbior',isBior,   ...
                 'caller',mfilename ...
                 );
             
        % View Compressed Signal in another window.
        %==========================================
        [Pus_EST,Tog_RES] = ...
            utthrgbl('get',win_compress,'pus_est','tog_res');
        pos_Pus_EST = get(Pus_EST,'Position');
        pos_Tog_RES = get(Tog_RES,'Position');
        dx = pos_Tog_RES(1)-(pos_Pus_EST(1)+pos_Pus_EST(3));
        xleft = pos_Pus_EST(1)+dx/2;
        width = pos_Pus_EST(3)+pos_Tog_RES(3);
        pos_Pus_SigDorC = ...
            [xleft , pos_Pus_EST(2)-pos_Pus_EST(4)-3*dy , ...
             width , pos_Pus_EST(4)];
         
        Pus_SigDorC = uicontrol('Parent',win_compress,...
                  'Style','pushbutton',...
                  'String',getWavMSG('Wavelet:commongui:ViewCS'), ...
                  'Units',win_units,...
                  'Position',pos_Pus_SigDorC, ...
                  'Enable','Off', ...
                  'BackgroundColor',get(Pus_EST,'BackgroundColor'), ...
                  'UserData','Compressed', ...
                  'Tag','Pus_SigDorC' ...
                  );

        cb_Pus_SigDorC = @(~,~)dw1dview_dorc(win_compress);
        set(Pus_SigDorC,'Callback',cb_Pus_SigDorC);
        %==================================================================


        % Adding colormap GUI.
        %---------------------
        pop_pal_caller = cbcolmap('get',win_caller,'pop_pal');
        prop_pal = get(pop_pal_caller,{'String','Value','UserData'});
        utcolmap('create',win_compress, ...
                 'xloc',xlocINI, ...
                 'bkcolor',Def_FraBkColor, ...
                 'Enable','on',...
                 'briFlag',0);
        pop_pal_loc = cbcolmap('get',win_compress,'pop_pal');
        set(pop_pal_loc,'String',prop_pal{1},'Value',prop_pal{2}, ...
                        'UserData',prop_pal{3});
        set(win_compress,'Colormap',get(win_caller,'Colormap'));        

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
        uicontrol('Parent',win_compress,...
                  'Style','frame',...
                  'Units',win_units,...
                  'Position',[x_fra,y_graph,w_fra,h_graph],...
                  'BackgroundColor',Def_FraBkColor...
                  );

        % Building axes on the right part.
        %---------------------------------
        ecy_right = 2*ecy;
        h_right   =(h_graph-2*bdy-(n_axeright-1)*ecy_right)/n_axeright;
        y_right   = y_graph+2*bdy/3;
        axe_datas = zeros(1,n_axeright);
        pos_right = [x_right y_right w_right h_right];
        for k = 1:n_axeright
            axe_datas(k) = axes('Parent',win_compress,...
                                'Units',win_units,...
                                'Position',pos_right,...
                                'Box','On'...
                                );
            pos_right(2) = pos_right(2)+pos_right(4)+ecy_right;
        end
        set(axe_datas(1),'Visible','off');

        % Computing and drawing original signal.
        %---------------------------------------
        Signal_Anal = get(wp1ddraw('r_orig',win_caller),'YData');
        axeAct = axe_datas(3);
        curr_color   = wtbutils('colors','sig');
        hdl_datas    = [NaN ; NaN];
        hdl_datas(1) = line(...
                         1:length(Signal_Anal),Signal_Anal,...
                         'Color',curr_color,...
                         'Parent',axeAct);
        wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axeAct);
        xmin = 1;                       
        xmax = length(Signal_Anal);
        ylim = [min(Signal_Anal) max(Signal_Anal)];
        if abs(ylim(1)-ylim(2))<eps , ylim = ylim+0.01*[-1 1]; end
        set(axeAct,'XLim',[xmin xmax],'YLim',ylim);

        % Displaying original details coefficients.
        %------------------------------------------
        axe_handles = findobj(get(win_caller,'Children'),'flat','Type','axes');
        WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
        xylim   = get(WP_Axe_Cfs,{'XLim','YLim'});
        axeAct = axe_datas(2);
        commonProp = {...
            'XLim',xylim{1},           ...
            'YLim',xylim{2},           ...
            'YTickLabelMode','manual', ...
            'YTickLabel',[],           ...
            'YTick',[],                ...
            'Box','On'                 ...
            };
        set(axeAct,commonProp{:});
        wpplotcf(WP_Tree,cfsMode,axeAct);
        wtitle(getWavMSG('Wavelet:dw1dRF:OriCfs'),'Parent',axeAct);
        set(axe_datas(1),commonProp{:});

        % Initializing global threshold.
        %-------------------------------
        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
            wp1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('set',win_compress,'thrBOUNDS',[0,valTHR,maxTHR]);

        % Displaying perfos & legend.
        %----------------------------
        y_axe   = y_graph+2*bdy/3+h_right+ecy_right;
        h_axe   = 2*h_right+ecy_right;
        pos_axe_perfo = [x_left y_axe w_left h_axe];
        y_axe   = y_graph+h_right/2;
        h_axe   = h_right/2;
        pos_axe_legend = [x_left y_axe w_left h_axe];
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
                       ind_sav_menus,sav_menus,  ...
                       ind_status,0,             ...
                       ind_win_caller,win_caller,...
                       ind_cfsMode,cfsMode,      ...
                       ind_axe_datas,axe_datas,  ...
                       ind_hdl_datas,hdl_datas   ...
                       );
        wmemtool('ini',win_compress,n_thrDATA,nbLOC_2_stored);

        % Axes attachment.
        %-----------------
        axe_cmd = axe_datas(3);
        axe_act = axe_datas(1:2);
        dynvtool('init',win_compress,[],axe_cmd,axe_act,[1 0]);

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
        wp1dcomp('clear_GRAPHICS',win_compress);
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Getting memory blocks.
        %-----------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        Wav_Name = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name);
        isBior   = wavemngr('isbior',Wav_Name);

        % Compression.
        %-------------
        valTHR = utthrgbl('get',win_compress,'valthr');
        thrParams = {'h','nobest',valTHR,1};
        if isBior
            [C_Sig,C_Tree,perf0] = wpdencmp(WP_Tree,thrParams{:});
            C_Data = [];
            lin_sig  = hdl_datas(1);
            Sig_Anal = get(lin_sig,'YData');
            perfl2   = 100*(norm(C_Sig)/norm(Sig_Anal))^2;
            strPerfo = getWavMSG('Wavelet:commongui:EnerRat', ...
                num2str(perfl2,'%5.2f'), [num2str(perf0,'%5.2f') ' %']);
        else
            [C_Sig,C_Tree] = wpdencmp(WP_Tree,thrParams{:});
            C_Data = [];
            [perfl2,perf0] = utthrgbl('getPerfo',win_compress);
            strPerfo = getWavMSG('Wavelet:commongui:RetEner', ...
                num2str(perfl2,'%5.2f'), [num2str(perf0,'%5.2f') ' %']);
        end

        % Displaying compressed signal.
        %------------------------------
        axeCur = axe_datas(3);
        hdl_comp = hdl_datas(2);
        if ishandle(hdl_comp)
            set(hdl_comp,'YData',C_Sig,'Visible','on');
        else
            curr_color = wtbutils('colors','ssig');
            hdl_comp = line('XData',1:length(C_Sig),...
                            'YData',C_Sig,...
                            'Color',curr_color,...
                            'LineWidth',2,...                            
                            'Parent',axeCur);
            hdl_datas(2) = hdl_comp;
            utthrgbl('set',win_compress,'handleTHR',hdl_comp);
            wmemtool('wmb',win_compress,n_misc_loc,...
                           ind_hdl_datas,hdl_datas);
        end     

        % Set a text as a super title.
        %-----------------------------
        wtitle(getWavMSG('Wavelet:dw1dRF:OS_CS'),'Parent',axeCur);
        wtxttitl(axeCur,strPerfo,tag_axetxt_perf);

        % Displaying thresholded details coefficients.
        %---------------------------------------------
        cfsMode = wmemtool('rmb',win_compress,n_misc_loc,ind_cfsMode);
        delete(findobj(axe_datas(1),'Type','image'));
        wpplotcf(C_Tree,cfsMode,axe_datas(1));
        xylim = get(axe_datas(2),{'XLim','YLim'});
        set(axe_datas(1),'XLim',xylim{1},'YLim',xylim{2});
        wtitle(getWavMSG('Wavelet:commongui:ThrCfs'),'Parent',axe_datas(1));
        set(findobj(axe_datas(1)),'Visible','on');       

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',win_compress,n_thrDATA, ...
                       ind_value,{C_Sig,C_Tree,C_Data,valTHR});
        wp1dcomp('enable_menus',win_compress,'on');

        % End waiting.
        %-------------
        wwaiting('off',win_compress);

    case 'compute_GBL_THR'
        win_caller = varargin{2};
        [numMeth,meth] = utthrgbl('get_GBL_par',win_compress);
        WP_Tree = wtbxappdata('get',win_caller,'WP_Tree');
        thrFLAGS = 'wp1dcompGBL';
        switch numMeth
          case 1
            [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                wthrmngr(thrFLAGS,meth,WP_Tree);
            if nargout==1
                varargout = {valTHR};
            else
                varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
            end

          case 2
            sig    = get(wp1ddraw('r_orig',win_caller),'YData');
            valTHR = wthrmngr(thrFLAGS,meth,sig);
            cfs = read(WP_Tree,'allcfs');
            maxTHR = max(abs(cfs));
            valTHR = min(valTHR,maxTHR);
            if nargout>0 , varargout = {valTHR}; end
        end

    case 'update_GBL_meth'
        wp1dcomp('clear_GRAPHICS',win_compress);
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        valTHR = wp1dcomp('compute_GBL_THR',win_compress,win_caller);
        utthrgbl('update_GBL_meth',win_compress,valTHR);

    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_compress,n_misc_loc,ind_status);
        if status==0 , return; end

        % Disable save Menus.
        %--------------------
        wp1dcomp('enable_menus',win_compress,'off');

        % Get Handles.
        %-------------
        [axe_datas,hdl_datas] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                               ind_axe_datas,ind_hdl_datas);

        % Setting the compressed coefs axes invisible.
        %---------------------------------------------
        hdl_comp = hdl_datas(2);
        if  ishandle(hdl_comp)
            vis = get(hdl_comp,'Visible');
            if isequal(vis,'on')
               txt_perf = findobj(axe_datas(3),'Tag',tag_axetxt_perf);
               set([findobj(axe_datas(1));hdl_comp;txt_perf],'Visible','off');
               wtitle(getWavMSG('Wavelet:commongui:OriSig'),'Parent',axe_datas(3));
            end
        end
        drawnow

    case 'enable_menus'
        enaVal = varargin{2};
        sav_menus = wmemtool('rmb',win_compress,n_misc_loc,ind_sav_menus);
        m_gen     = wtbxappdata('get',win_compress,'M_GenCode');
        set([sav_menus,m_gen],'Enable',enaVal);
        utthrgbl('enable_tog_res',win_compress,enaVal);
        if strncmpi(enaVal,'on',2)
            status = 1;
        else
            status = 0;
        end
        wmemtool('wmb',win_compress,n_misc_loc,ind_status,status);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                            '*.mat',getWavMSG('Wavelet:commongui:SaveCmpSig'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSave'));

        % Getting Analysis values.
        %-------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        wname = wmemtool('rmb',win_caller,n_param_anal,ind_wav_name); %#ok<NASGU>
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
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
        wwaiting('off',win_compress);
        try
            save([pathname filename],saveStr,'valTHR','wname');
        catch
            errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'save_dec'

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_compress, ...
                          '*.wp1',getWavMSG('Wavelet:wp1d2dRF:SaveWP1D'));
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitSaveDec'));

        % Getting Analysis parameters.
        %-----------------------------
        win_caller = wmemtool('rmb',win_compress,n_misc_loc,ind_win_caller);
        data_name = wmemtool('rmb',win_caller,n_param_anal,ind_sig_name); %#ok<NASGU>

        % Getting Analysis values.
        %-------------------------
        thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
        tree_struct = thrDATA{2}; %#ok<NASGU>
        valTHR = thrDATA{4}; %#ok<NASGU>

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) || isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        saveStr = {'tree_struct','data_name','valTHR'};
        wwaiting('off',win_compress);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
        end

    case 'close'
        [status,win_caller] = wmemtool('rmb',win_compress,n_misc_loc, ...
                                             ind_status,ind_win_caller);
        if status==1
            % Test for Updating.
            %--------------------
            status = wwaitans(win_compress,...
                        getWavMSG('Wavelet:commongui:UpdateSS'),2,'cancel');
        end
        switch status
            case 1
              wwaiting('msg',win_compress,getWavMSG('Wavelet:commongui:WaitCompute'));
              thrDATA = wmemtool('rmb',win_compress,n_thrDATA,ind_value);
              valTHR  = thrDATA{4};
              wmemtool('wmb',win_caller,n_param_anal,ind_thr_val,valTHR);
              hdl_datas = wmemtool('rmb',win_compress,n_misc_loc,ind_hdl_datas);
              hdl_comp  = hdl_datas(2);
              wp1dmngr('return_comp',win_caller,status,hdl_comp);
              wwaiting('off',win_compress);

            case 0 , wp1dmngr('return_comp',win_caller,status);
        end
        if nargout>0 , varargout{1} = status; end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
